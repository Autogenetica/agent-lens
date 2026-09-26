#!/usr/bin/env ruby
# frozen_string_literal: true

# Mechanical readout for lens pilot run 3: headline + per-task tables from the
# result.json / agent.patch files under <arm>/runs/run3. Reach mirrors reach.rb
# (anchor on a line the agent added). Prose after the tables is the fixed
# framing the brief asked for; the interpretation paragraph is left for a
# reader who has looked at the trajectories.
#
#   ruby bench/lemans/pilot/readout.rb 2026-09-26 > bench/lemans/pilot/RESULTS-2026-09-26.md

require "json"
require "pathname"
require "time"

HERE = Pathname(ENV["PILOT_DIR"] || __dir__)
DATE = ARGV[0] || Time.now.strftime("%Y-%m-%d")
ARMS = %w[baseline lensed vocab].freeze
K = (ENV["K"] || 3).to_i
CEILING = 65.0

Trial = Struct.new(:task, :anchor, :scored, :passed, :reached, :input, :cached, :output, :steps, :cost, :started, :finished)

def load_arm(arm)
  Dir[HERE.join(arm, "runs/run3/*/*/result.json").to_s].sort.map do |f|
    r = JSON.parse(File.read(f))
    patch = Pathname(f).dirname.join("agent.patch")
    anchor = r.dig("metadata", "rails_anchor")
    anchor = nil if anchor.to_s.empty? || anchor.to_s.start_with?("none")
    reached = if anchor && patch.file?
                pat = /(?<![A-Za-z0-9_])#{Regexp.escape(anchor)}(?![A-Za-z0-9_])/ # same rule as reach.rb
                patch.read.each_line.any? { |l| l.start_with?("+") && !l.start_with?("+++") && l.match?(pat) }
              end
    u = r["usage"] || {}
    Trial.new(r["task"], anchor, r.dig("outcome", "scored") == true, r["reward"].to_f >= 1.0, reached,
              u["input_tokens"].to_i, u["cached_tokens"].to_i, u["output_tokens"].to_i, u["steps"].to_i,
              u["cost_usd"].to_f, r["started_at"], r["finished_at"])
  end
end

def pct(a, b) = b.zero? ? "n/a" : "#{(100.0 * a / b).round}%"
def frac(a, b) = "#{a}/#{b} (#{pct(a, b)})"

arms = ARMS.to_h { |a| [a, load_arm(a)] }
tasks = arms.values.flatten.map(&:task).uniq.sort

stats = arms.to_h do |name, ts|
  scored = ts.select(&:scored)
  anchored = ts.select(&:anchor) # every anchored trial, scored or not, as reach.rb counts
  passed_anchored = anchored.select(&:passed)
  input = ts.sum(&:input); cached = ts.sum(&:cached)
  [name, {
    n: ts.size, solved: scored.count(&:passed),
    pass_k: tasks.count { |t| ts.any? { |x| x.task == t && x.passed } },
    anchored: anchored.size, reached: anchored.count(&:reached),
    reach_given_pass: pct(passed_anchored.count(&:reached), passed_anchored.size),
    steps: ts.empty? ? 0 : (ts.sum(&:steps).to_f / ts.size).round,
    cost: ts.sum(&:cost), per_trial: ts.empty? ? 0 : ts.sum(&:cost) / ts.size,
    hit: pct(cached, input), invalid: ts.count { |x| !x.scored },
  }]
end

total_cost = stats.values.sum { |s| s[:cost] }
total_n = stats.values.sum { |s| s[:n] }
all = arms.values.flatten
starts = all.map(&:started).compact.map { |t| Time.parse(t) }
ends = all.map(&:finished).compact.map { |t| Time.parse(t) }
wall = starts.empty? ? 0 : ((ends.max - starts.min) / 60).round

puts "# Lens pilot, run 3: three arms on Haiku 4.5, cached via OpenRouter"
puts
puts "Run #{DATE} on the mini. Haiku 4.5 as `openrouter/anthropic/claude-haiku-4.5`"
puts "(miniswen's explicit cache breakpoints fire on this id, per the 2026-09-25"
puts "smoke), lemans 1.3.1, host-side miniswen 1.3.5, docker backend, upstream"
puts "trial limits. Writebook stage 1: #{tasks.size} tasks, #{K} attempts per task, three"
puts "arms run in parallel at 3 trials each. #{total_n} trials, $#{'%.2f' % total_cost} total,"
puts "#{wall} min wall clock."
puts
puts "Arms are the run 2 arms unchanged apart from the model line: **baseline** (tasks"
puts "as published), **lensed** (`lens/SKILL.md` framed as a loaded Agent Skill),"
puts "**vocab** (the same items with every API identifier rewritten as a description)."
puts
puts "Replication check against run 1 (same model over the direct Anthropic API,"
puts "uncached, k=2, RESULTS-2026-09-22): baseline solved 13/44 (30%), pass@2 8/22,"
puts "reach 11/42 (26%), $1.33 a trial. Baseline here: solved"
puts "#{frac(stats['baseline'][:solved], stats['baseline'][:n])}, pass@#{K} #{stats['baseline'][:pass_k]}/#{tasks.size},"
puts "reach #{frac(stats['baseline'][:reached], stats['baseline'][:anchored])}, $#{'%.3f' % stats['baseline'][:per_trial]} a trial."
puts
puts "## Headline"
puts
puts "| | #{ARMS.join(' | ')} |"
puts "|---|#{'---|' * ARMS.size}"
puts "| trials solved | #{ARMS.map { |a| frac(stats[a][:solved], stats[a][:n]) }.join(' | ')} |"
puts "| pass@#{K} | #{ARMS.map { |a| "#{stats[a][:pass_k]}/#{tasks.size}" }.join(' | ')} |"
puts "| reach (anchored tasks) | #{ARMS.map { |a| frac(stats[a][:reached], stats[a][:anchored]) }.join(' | ')} |"
puts "| reach given pass | #{ARMS.map { |a| stats[a][:reach_given_pass] }.join(' | ')} |"
puts "| mean steps | #{ARMS.map { |a| stats[a][:steps] }.join(' | ')} |"
puts "| cache hit | #{ARMS.map { |a| stats[a][:hit] }.join(' | ')} |"
puts "| cost | #{ARMS.map { |a| "$#{'%.2f' % stats[a][:cost]}" }.join(' | ')} |"
puts "| cost per trial | #{ARMS.map { |a| "$#{'%.3f' % stats[a][:per_trial]}" }.join(' | ')} |"
inv = ARMS.map { |a| stats[a][:invalid] }.sum
puts "| invalid trials | #{ARMS.map { |a| stats[a][:invalid] }.join(' | ')} |" if inv.positive?
puts
puts "pass@#{K} here is not directly comparable to run 2's pass@5: three attempts"
puts "give a task fewer chances to land one, so a task solved once in five may"
puts "read as 0/#{K} here without the model having changed."
puts
puts "Provider and model are a confound against runs 1-2: run 1 was the same"
puts "Haiku over the direct Anthropic API with no cache, run 2 was gpt-5.6-luna."
puts "Arm-to-arm comparisons inside this run share the model and provider; only"
puts "the cross-run comparisons carry the confound."
puts
puts "## Per task"
puts
puts "pass / reach, #{K} attempts each. Reach is whether the task's anchor API appears"
puts "on a line the agent added."
puts
puts "| task | anchor | #{ARMS.join(' | ')} |"
puts "|---|---|#{'---|' * ARMS.size}"
tasks.each do |t|
  anchor = all.find { |x| x.task == t }&.anchor
  cells = ARMS.map do |a|
    ts = arms[a].select { |x| x.task == t }
    p = "#{ts.count(&:passed)}/#{ts.size}"
    anchor ? "#{p} · #{ts.count(&:reached)}/#{ts.size}" : p
  end
  puts "| #{t} | #{anchor || '(none)'} | #{cells.join(' | ')} |"
end
puts
puts "## Cost"
puts
puts "$#{'%.2f' % total_cost} across #{total_n} trials against the $#{'%.0f' % CEILING} pilot ceiling"
puts "(#{pct(total_cost.round, CEILING.round)} of it). Per trial, per arm: #{ARMS.map { |a| "$#{'%.3f' % stats[a][:per_trial]}" }.join(', ')}."
puts "Cache hit per arm: #{ARMS.map { |a| stats[a][:hit] }.join(', ')}. Costs are the ruby_llm"
puts "registry estimate for this OpenRouter id, not the OpenRouter bill."
puts
puts "## Reading"
puts
puts "<!-- interpretation pending: written after the trajectories are read, not by readout.rb -->"
puts
puts "## Reproduce"
puts
puts "`bench/lemans/pilot/run3.sh` (all three arms, `-k #{K} -c 3`, the 22 Writebook"
puts "tasks by name), then `ruby bench/lemans/pilot/readout.rb #{DATE}` for the tables"
puts "and `ruby reach.rb baseline=… lensed=… vocab=…` on the `runs/run3` dirs for"
puts "the reach cross-check."
