#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Lens-as-gate offline replay, third reader: Jev's typed-decision API
# (POST https://api.typesafe.ai/v1/systemone, model jev-latest). Same 16 noul
# questions, same trials, and the same state construction as the jev-router
# run (full task text + full diff, app code first, 24,000-char cap) so the
# three readers compare on equal footing.
#
#   TYPESAFE_API_KEY=... ruby bench/lemans/pilot/replay/jev-systemone-replay.rb \
#     bench/lemans/pilot/replay/laya-replay-2026-09-24.csv > bench/lemans/pilot/replay/jev-systemone-replay-<date>.csv
#
# Jev's docs: literal reading, name the state fields the question is about,
# no counting. The state is therefore an object with named fields rather
# than one blob, and each question names the field it reads.

require "net/http"
require "json"
require "csv"
require "pathname"

ROOT = Pathname(__dir__).join("../../../..").expand_path
PILOT = ROOT.join("bench/lemans/pilot")
TASK_CHARS = (ENV["TASK_CHARS"] || 6000).to_i
DIFF_CHARS = (ENV["DIFF_CHARS"] || 24_000).to_i
THREADS = (ENV["THREADS"] || 4).to_i
MODEL = ENV["JEV_MODEL"] || "jev-latest"
KEY = ENV.fetch("TYPESAFE_API_KEY")

ITEMS = {
  "sql_injection" => "Does the diff build database conditions with placeholders or hash conditions rather than interpolating values into SQL strings?",
  "n_plus_one" => "Does the diff eager-load associations it iterates over, avoiding one query per record?",
  "mass_assignment" => "Does the diff allowlist request parameters before writing them to models?",
  "unique_index" => "Does the diff pair any uniqueness validation with a unique database index?",
  "bulk_bypass" => "Does the diff use bulk write methods that skip validations and callbacks only where that is clearly intentional?",
  "callback_side_effects" => "Does the diff keep external side effects out of save callbacks and place them after the transaction commits?",
  "job_arguments" => "Does the diff pass records to background jobs safely and handle a record that is gone when the job runs?",
  "csrf" => "Does the diff keep request forgery protection in place for non-read actions?",
  "strong_params" => "Does the diff add any new attribute to the controller's parameter allowlist?",
  "cache_deps" => "Does the diff declare the template dependencies of any cached view fragment it touches?",
  "after_commit" => "Does the diff trigger emails, jobs, or external calls only after the database transaction commits?",
  "sensitive_data" => "Does the diff keep sensitive values out of logs and plain cookies?",
  "batching" => "Does the diff iterate large record sets in batches rather than loading them all into memory?",
  "path_safety" => "Does the diff validate redirect targets and file paths built from user input?",
  "enqueue_after_commit" => "Does the diff enqueue background jobs only after the surrounding transaction commits?",
  "comparator" => "Does the diff correctly and completely implement what the request asks for?"
}.freeze

QUESTIONS = ITEMS.to_h { |k, q| [k, { "type" => "noul", "instructions" => q }] }.freeze

def task_text(task)
  PILOT.join("baseline/tasks", task, "instruction.md").read.sub(/\A---\s*\n.*?\n---\s*\n/m, "").strip[0, TASK_CHARS]
end

def diff_text(patch)
  chunks = patch.split(/^diff --git /).drop(1).map { |c| [c[/^\+\+\+ b\/(.+)$/, 1].to_s, "diff --git #{c}"] }
  rank = ->(f) { f.start_with?("app/", "lib/", "config/", "db/") ? 0 : (f.start_with?("test/") ? 1 : 2) }
  body = chunks.sort_by { |f, _| rank.(f) }.map(&:last).join
  body.length > DIFF_CHARS ? body[0, DIFF_CHARS] + "\n[diff truncated]" : body
end

def ask(task, patch)
  uri = URI("https://api.typesafe.ai/v1/systemone")
  req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{KEY}")
  req.body = { state: { request: task_text(task), diff: diff_text(patch) }, model: MODEL, questions: QUESTIONS }.to_json
  attempt = 0
  loop do
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 120) { |h| h.request(req) }
    case res.code
    when "200"
      data = JSON.parse(res.body)
      answers = data["answers"] || data["results"] || data
      probs = ITEMS.keys.to_h { |k| [k, (answers.dig(k, "noul") || answers.dig(k, "probability")).to_f] }
      return [probs, data["usage"] || {}, data["model"] || MODEL]
    when "429", "529"
      attempt += 1
      raise "gave up after #{attempt} retries: HTTP #{res.code}" if attempt > 6
      sleep(2**attempt)
    else
      raise "HTTP #{res.code}: #{res.body[0, 300]}"
    end
  end
end

trials = CSV.read(ARGV.fetch(0), headers: true).map { |r| r.to_h.slice("arm", "task", "trial", "reward", "steps", "cost") }
out = CSV.new($stdout)
out << %w[arm task trial reward steps cost] + ITEMS.keys + %w[judge_model prompt_tokens]
mutex = Mutex.new
queue = Queue.new
trials.each { |t| queue << t }
total_tokens = 0
THREADS.times.map do
  Thread.new do
    while (t = (queue.pop(true) rescue nil))
      dir = PILOT.glob("#{t['arm']}/runs/*/#{t['trial']}").first
      next warn("#{t['trial']}: no run dir") unless dir
      begin
        probs, usage, model = ask(t["task"], dir.join("agent.patch").read)
        toks = (usage["input_tokens"] || usage["prompt_tokens"] || 0).to_i
        mutex.synchronize do
          total_tokens += toks
          out << t.values + ITEMS.keys.map { |k| probs[k].round(4) } + [model, toks]
          $stdout.flush
        end
      rescue => e
        warn "#{t['trial']}: #{e.class}: #{e.message[0, 200]}"
      end
    end
  end
end.each(&:join)
warn "total input tokens: #{total_tokens} (~$#{(total_tokens / 1e6 * 0.042).round(3)} at $0.042/M)"
