#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Advisory correctness judge (decisions 2026-10-04T2205, option 2): one
# question, "does this change correctly and completely implement the
# request?", answered as a probability by a capable reader that sees the
# task, the full diff, and the agent's OWN final test output. The reward
# source (verifier.log) is deliberately never shown to the judge; it is the
# label we calibrate against, not an input.
#
#   BUNDLE_GEMFILE=runs/Gemfile bundle exec ruby bench/lemans/pilot/replay/correctness-judge.rb \
#     bench/lemans/pilot/replay/laya-replay-2026-09-24.csv > runs/correctness-judge.csv
#
# Reads the trial list from the laya CSV so this reader sees the same 330
# trials as the lens replays. LIMIT=n judges only the first n trials (smoke).
# Stops when cumulative OpenRouter cost passes COST_CAP_USD.

require "net/http"
require "json"
require "csv"
require "pathname"

PILOT = Pathname(__dir__).join("..").expand_path
ROOT = PILOT.join("../../..").expand_path
MODEL = ENV["JUDGE_MODEL"] || "openai/gpt-6.1-sol"
TASK_CHARS = (ENV["TASK_CHARS"] || 6000).to_i
DIFF_CHARS = (ENV["DIFF_CHARS"] || 24_000).to_i
TEST_CHARS = (ENV["TEST_CHARS"] || 3000).to_i
TEST_LINES = (ENV["TEST_LINES"] || 40).to_i
COST_CAP_USD = (ENV["COST_CAP_USD"] || 10).to_f
THREADS = (ENV["THREADS"] || 4).to_i
LIMIT = ENV["LIMIT"]&.to_i
KEY = ENV.fetch("OPENROUTER_API_KEY")

SUMMARY_RE = /\d+ runs, \d+ assertions, \d+ failures, \d+ errors(?:, \d+ skips)?/

SCHEMA = {
  "type" => "object",
  "additionalProperties" => false,
  "required" => ["correct"],
  "properties" => { "correct" => { "type" => "number", "minimum" => 0, "maximum" => 1 } }
}.freeze

SYSTEM = <<~TXT
  You review a code change against the request that prompted it. Answer with a calibrated
  probability between 0 and 1 that the change correctly and completely implements the request:
  every stated requirement met, nothing banned by the request added, no regression introduced.
  The AGENT TEST OUTPUT section is the implementing agent's own last test run, which may be
  partial, targeted at one file, or edited to pass; weigh it as evidence, not as a verdict.
  Respond only with the JSON object.
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

# The agent's final self-run: the LAST tool result in trajectory.json whose
# content carries a minitest summary line. Returns [tail, summary]; tail is
# the summary line plus the TEST_LINES before it, capped at TEST_CHARS.
def agent_test_output(dir)
  path = dir.join("trajectory.json")
  return ["(no trajectory.json)", ""] unless path.exist?
  data = JSON.parse(path.read)
  steps = data.is_a?(Hash) ? data["steps"] : data
  hit = nil
  Array(steps).each do |s|
    Array(s.dig("observation", "results")).each do |r|
      c = r["content"].to_s
      hit = c if c.match?(SUMMARY_RE)
    end
  end
  return ["(agent ran no tests)", "none"] unless hit
  text = hit.gsub("\\n", "\n")
  lines = text.lines
  idx = lines.rindex { |l| l.match?(SUMMARY_RE) } || lines.length - 1
  tail = lines[[idx - TEST_LINES, 0].max..idx].join
  tail = "[truncated]\n" + tail[-TEST_CHARS..] if tail.length > TEST_CHARS
  [tail, lines[idx][SUMMARY_RE].to_s]
rescue JSON::ParserError => e
  ["(trajectory unreadable: #{e.message[0, 80]})", ""]
end

def ask(task, patch, tests)
  user = "REQUEST:\n#{task_text(task)}\n\nCHANGE (unified diff):\n#{diff_text(patch)}\n\n" \
         "AGENT TEST OUTPUT (the implementing agent's own last run):\n#{tests}\n\n" \
         "QUESTION:\ncorrect: Does this change correctly and completely implement the request?"
  body = {
    model: MODEL,
    messages: [{ role: "system", content: SYSTEM }, { role: "user", content: user }],
    response_format: { type: "json_schema", json_schema: { name: "review", strict: true, schema: SCHEMA } },
    temperature: 0,
    usage: { include: true }
  }
  uri = URI("https://openrouter.ai/api/v1/chat/completions")
  req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{KEY}",
                                 "HTTP-Referer" => "https://github.com/Autogenetica/agent-lens", "X-Title" => "agent-lens correctness judge")
  req.body = body.to_json
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 180) { |h| h.request(req) }
  raise "HTTP #{res.code}: #{res.body[0, 300]}" unless res.code == "200"
  data = JSON.parse(res.body)
  content = data.dig("choices", 0, "message", "content").to_s
  answers = JSON.parse(content[/\{.*\}/m] || "{}")
  [answers["correct"].to_f, data["model"], data.dig("usage", "cost") || 0.0, data.dig("usage", "prompt_tokens") || 0]
end

trials = CSV.read(ARGV.fetch(0), headers: true).map { |r| r.to_h.slice("arm", "task", "trial", "reward", "steps", "cost") }
trials = trials.first(LIMIT) if LIMIT
out = CSV.new($stdout)
out << %w[arm task trial reward steps cost correct test_summary judge_model judge_cost_usd prompt_tokens]
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
        tests, summary = agent_test_output(dir)
        correct, model, cost, ptoks = ask(t["task"], dir.join("agent.patch").read, tests)
        mutex.synchronize do
          spent += cost.to_f
          out << t.values + [correct.round(4), summary, model, cost.to_f.round(5), ptoks]
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
