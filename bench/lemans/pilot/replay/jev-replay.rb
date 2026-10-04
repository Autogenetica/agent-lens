#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Lens-as-gate offline replay, second reader: typesafe/jev-router through
# OpenRouter's chat completions, with the full task text and the full diff,
# answering the same 16 yes/no questions as the laya replay with a
# probability each, via a JSON response schema.
#
# This is NOT Jev's typed-decision (systemone) API. OpenRouter exposes
# jev-router as a chat model that routes each request to an LLM of its
# choosing; the routed model is recorded per row. It answers the question
# laya could not: with the whole diff in front of a capable reader, does
# "does this change correctly implement the request?" separate pass from
# fail?
#
#   BUNDLE_GEMFILE=runs/Gemfile bundle exec ruby bench/lemans/pilot/replay/jev-replay.rb \
#     bench/lemans/pilot/replay/laya-replay-2026-09-24.csv > bench/lemans/pilot/replay/jev-router-replay-<date>.csv
#
# Reads the trial list from the laya CSV so the two readers see the same 330
# trials. Stops when cumulative OpenRouter cost passes COST_CAP_USD.

require "net/http"
require "json"
require "csv"
require "pathname"

ROOT = Pathname(__dir__).join("../../../..").expand_path
PILOT = ROOT.join("bench/lemans/pilot")
MODEL = ENV["JUDGE_MODEL"] || "typesafe/jev-router"
TASK_CHARS = (ENV["TASK_CHARS"] || 6000).to_i
DIFF_CHARS = (ENV["DIFF_CHARS"] || 24_000).to_i
COST_CAP_USD = (ENV["COST_CAP_USD"] || 10).to_f
THREADS = (ENV["THREADS"] || 4).to_i
KEY = ENV.fetch("OPENROUTER_API_KEY")

ITEMS = {
  "sql_injection" => "Does the change build database conditions with placeholders or hash conditions rather than interpolating values into SQL strings?",
  "n_plus_one" => "Does the change eager-load associations it iterates over, avoiding one query per record?",
  "mass_assignment" => "Does the change allowlist request parameters before writing them to models?",
  "unique_index" => "Does the change pair any uniqueness validation with a unique database index?",
  "bulk_bypass" => "Does the change use bulk write methods that skip validations and callbacks only where that is clearly intentional?",
  "callback_side_effects" => "Does the change keep external side effects out of save callbacks and place them after the transaction commits?",
  "job_arguments" => "Does the change pass records to background jobs safely and handle a record that is gone when the job runs?",
  "csrf" => "Does the change keep request forgery protection in place for non-read actions?",
  "strong_params" => "Does the change add any new attribute to the controller's parameter allowlist?",
  "cache_deps" => "Does the change declare the template dependencies of any cached view fragment it touches?",
  "after_commit" => "Does the change trigger emails, jobs, or external calls only after the database transaction commits?",
  "sensitive_data" => "Does the change keep sensitive values out of logs and plain cookies?",
  "batching" => "Does the change iterate large record sets in batches rather than loading them all into memory?",
  "path_safety" => "Does the change validate redirect targets and file paths built from user input?",
  "enqueue_after_commit" => "Does the change enqueue background jobs only after the surrounding transaction commits?",
  "comparator" => "Does this change correctly and completely implement the request?"
}.freeze

SCHEMA = {
  "type" => "object",
  "additionalProperties" => false,
  "required" => ITEMS.keys,
  "properties" => ITEMS.keys.to_h { |k| [k, { "type" => "number", "minimum" => 0, "maximum" => 1 }] }
}.freeze

SYSTEM = <<~TXT
  You review a code change against the request that prompted it. For each question, answer with a
  calibrated probability between 0 and 1 that the answer is yes. If a question's subject does not
  apply to this change, answer what the change actually does (for example, a change that touches no
  cached views gets a low probability on the cache question). Respond only with the JSON object.
TXT

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
  user = "REQUEST:\n#{task_text(task)}\n\nCHANGE (unified diff):\n#{diff_text(patch)}\n\nQUESTIONS:\n" +
         ITEMS.map { |k, q| "#{k}: #{q}" }.join("\n")
  body = {
    model: MODEL,
    messages: [{ role: "system", content: SYSTEM }, { role: "user", content: user }],
    response_format: { type: "json_schema", json_schema: { name: "review", strict: true, schema: SCHEMA } },
    temperature: 0,
    usage: { include: true }
  }
  uri = URI("https://openrouter.ai/api/v1/chat/completions")
  req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{KEY}",
                                 "HTTP-Referer" => "https://github.com/Autogenetica/agent-lens", "X-Title" => "agent-lens lens-as-gate replay")
  req.body = body.to_json
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 180) { |h| h.request(req) }
  raise "HTTP #{res.code}: #{res.body[0, 300]}" unless res.code == "200"
  data = JSON.parse(res.body)
  content = data.dig("choices", 0, "message", "content").to_s
  answers = JSON.parse(content[/\{.*\}/m] || "{}")
  [answers, data["model"], data.dig("usage", "cost") || 0.0, data.dig("usage", "prompt_tokens") || 0]
end

trials = CSV.read(ARGV.fetch(0), headers: true).map { |r| r.to_h.slice("arm", "task", "trial", "reward", "steps", "cost") }
out = CSV.new($stdout)
out << %w[arm task trial reward steps cost] + ITEMS.keys + %w[judge_model judge_cost_usd prompt_tokens]
mutex = Mutex.new
spent = 0.0
queue = Queue.new
trials.each { |t| queue << t }
workers = THREADS.times.map do
  Thread.new do
    while (t = queue.pop(true) rescue nil)
      break if mutex.synchronize { spent } > COST_CAP_USD
      dir = PILOT.glob("#{t['arm']}/runs/*/#{t['trial']}").first
      next warn("#{t['trial']}: no run dir") unless dir
      begin
        answers, model, cost, ptoks = ask(t["task"], dir.join("agent.patch").read)
        mutex.synchronize do
          spent += cost.to_f
          out << t.values + ITEMS.keys.map { |k| answers[k].to_f.round(4) } + [model, cost.to_f.round(5), ptoks]
          $stdout.flush
        end
      rescue => e
        warn "#{t['trial']}: #{e.class}: #{e.message[0, 200]}"
        sleep 5
      end
    end
  end
end
workers.each(&:join)
warn "total judge cost: $#{spent.round(3)}"
