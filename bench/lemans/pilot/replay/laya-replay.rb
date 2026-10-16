#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Lens-as-gate offline replay. For every run-2 trial, ask laya the 15 lens
# items as noul questions over (task text + distilled diff), plus one
# comparator question, and write one CSV row per trial with the verifier's
# reward alongside. Analysis happens in laya-analyze.rb.
#
#   BUNDLE_GEMFILE=runs/Gemfile bundle exec ruby bench/lemans/pilot/replay/laya-replay.rb > bench/lemans/pilot/replay/laya-replay-<date>.csv
#
# MAX_CHARS caps the distilled diff so the state fits the checkpoint's context.

require "laya"
require "json"
require "csv"
require "pathname"

ROOT = Pathname(__dir__).join("../../../..").expand_path
PILOT = ROOT.join("bench/lemans/pilot")
ARMS = %w[baseline lensed vocab].freeze
MAX_CHARS = (ENV["MAX_CHARS"] || 1500).to_i   # ~600 tokens per sequence: attention cost and RSS both drop sharply vs the 1024 max
TASK_CHARS = (ENV["TASK_CHARS"] || 500).to_i
BATCH = (ENV["BATCH"] || 8).to_i               # questions per forward pass; 16 at once peaked at 7.7 GB RSS
DEVICE = ENV["LAYA_DEVICE"] || "cpu"

# The 15 lens items as yes/no questions about the change. Same order as
# bench/lemans/lens/SKILL.md. Each is asked as: "Does the change ...?"
ITEMS = {
  sql_injection:   "Does the change build database conditions with placeholders or hash conditions rather than interpolating values into SQL strings?",
  n_plus_one:      "Does the change eager-load associations it iterates over, avoiding one query per record?",
  mass_assignment: "Does the change allowlist request parameters before writing them to models?",
  unique_index:    "Does the change pair any uniqueness validation with a unique database index?",
  bulk_bypass:     "Does the change use bulk write methods that skip validations and callbacks only where that is clearly intentional?",
  callback_side_effects: "Does the change keep external side effects out of save callbacks and place them after the transaction commits?",
  job_arguments:   "Does the change pass records to background jobs safely and handle a record that is gone when the job runs?",
  csrf:            "Does the change keep request forgery protection in place for non-read actions?",
  strong_params:   "Does the change add any new attribute to the controller's parameter allowlist?",
  cache_deps:      "Does the change declare the template dependencies of any cached view fragment it touches?",
  after_commit:    "Does the change trigger emails, jobs, or external calls only after the database transaction commits?",
  sensitive_data:  "Does the change keep sensitive values out of logs and plain cookies?",
  batching:        "Does the change iterate large record sets in batches rather than loading them all into memory?",
  path_safety:     "Does the change validate redirect targets and file paths built from user input?",
  enqueue_after_commit: "Does the change enqueue background jobs only after the surrounding transaction commits?"
}.freeze

COMPARATOR = "Does this change correctly and completely implement the request?"

# The task's one-line description plus the opening of its body, capped.
def task_text(task)
  text = PILOT.join("baseline/tasks", task, "instruction.md").read
  desc = text[/^description:\s*(.+)$/, 1].to_s.strip
  body = text.sub(/\A---\s*\n.*?\n---\s*\n/m, "").strip
  "#{desc}\n#{body}"[0, TASK_CHARS]
end

# Files touched plus the added lines, app code before tests and docs, capped.
def distilled_diff(patch)
  files = patch.scan(/^\+\+\+ b\/(.+)$/).flatten
  chunks = patch.split(/^diff --git /).drop(1).map do |c|
    file = c[/^\+\+\+ b\/(.+)$/, 1].to_s
    [file, c.lines.select { |l| l.start_with?("+") && !l.start_with?("+++") }.map { |l| l[1..] }.join]
  end
  rank = ->(f) { f.start_with?("app/", "lib/", "config/", "db/") ? 0 : (f.start_with?("test/") ? 1 : 2) }
  added = chunks.sort_by { |f, _| rank.(f) }.map { |f, lines| "# #{f}\n#{lines}" }
  head = "Files changed: #{files.join(', ')}\n\nAdded lines:\n"
  body = added.join
  body = body[0, MAX_CHARS - head.length] + "\n[truncated]" if head.length + body.length > MAX_CHARS
  head + body
end

def state_for(task, patch)
  "Task:\n#{task_text(task)}\n\nChange:\n#{distilled_diff(patch)}"
end

questions = ITEMS.transform_keys(&:to_s).transform_values { |q| { "type" => "noul", "instructions" => q } }
questions["comparator"] = { "type" => "noul", "instructions" => COMPARATOR }

router = Laya::Router.new(max_loaded: 1, device: DEVICE)
MODEL = ENV["LAYA_MODEL"] || "typed-decisions"
out = CSV.new($stdout)
out << %w[arm task trial reward steps cost] + ITEMS.keys.map(&:to_s) + %w[comparator state_chars]

ARMS.each do |arm|
  PILOT.join(arm, "runs").glob("**/result.json").sort.each do |rj|
    dir = rj.dirname
    result = JSON.parse(rj.read)
    task = result["task"] || dir.basename.to_s.split("__").first
    patch = dir.join("agent.patch")
    next unless patch.file?
    state = state_for(task, patch.read)
    answers = {}
    questions.each_slice(BATCH) { |slice| answers.merge!(router.predict(state, slice.to_h, model: MODEL).answers) }
    probs = ITEMS.keys.map { |k| answers[k.to_s].probability.round(4) }
    out << [arm, task, dir.basename.to_s, result["reward"], result.dig("usage", "steps"), result.dig("usage", "cost_usd"),
            *probs, answers["comparator"].probability.round(4), state.length]
    $stdout.flush
  rescue => e
    warn "#{dir}: #{e.class}: #{e.message}"
  end
end
