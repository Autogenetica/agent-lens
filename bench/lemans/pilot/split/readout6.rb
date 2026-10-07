#!/usr/bin/env ruby
# frozen_string_literal: true

# Mechanical readout for lens pilot run 6: the pre-registered check-reachability
# split. Reads run 6's two arms (<arm>/runs/run6/<model>/*/result.json), pools
# them with run 2's baseline and run 4's process arm (<arm>/runs/gpt-5.6-luna),
# and prints headline, split table (k=10 alone and k=15 pooled, two-proportion
# z, one-sided), kill criteria, per-task table and provenance checks. The
# `## Reading` section is left for a reader who has looked at the trajectories.
#
#   ruby bench/lemans/pilot/split/readout6.rb 2026-10-07 > bench/lemans/pilot/RESULTS-2026-10-07-run6.md
#
# Task sets are the pre-registered ones (brief 2026-10-06T1810, decision
# 2026-10-06T1708 option 1); do not edit them after launch.

require "json"
require "pathname"
require "time"

HERE = Pathname(ENV["PILOT_DIR"] || File.expand_path("..", __dir__))
DATE = ARGV[0] || Time.now.strftime("%Y-%m-%d")
RUN = ENV["RUN"] || "run6"
MODEL_DIR = ENV["MODEL_DIR"] || "gpt-5.6-luna"
K = (ENV["K"] || 10).to_i

R = %w[ac-deep-link-return ac-throttle-search aj-enqueue-after-commit aj-resumable-cleanup
       ar-announce-once ar-archive-book-access ar-atomic-import ar-compact-positions
       ar-erase-account ar-release-recap ar-tenant-isolation av-toc-cache-per-role
       sec-audit-sweep sup-legacy-conversions].freeze
NOT_R = %w[ar-bulk-access-grants as-purge-embedded-images as-variant-processed-once
           hw-scoped-broadcast sup-cache-library-digest sup-log-to-terminal
           tst-error-page-flake].freeze
SECONDARY = %w[ar-erase-account av-toc-cache-per-role sec-audit-sweep sup-legacy-conversions ar-announce-once].freeze
SETS = { "reachable (14)" => R, "not reachable (7)" => NOT_R, "hello-world" => %w[hello-world] }.freeze

Trial = Struct.new(:task, :scored, :passed, :steps, :cost, :input, :cached, :model, :profile, :task_digest, :started, :finished)

def load(glob)
  Dir[glob].sort.map do |f|
    r = JSON.parse(File.read(f))
    u = r["usage"] || {}
    Trial.new(r["task"], r.dig("outcome", "scored") == true, r["reward"].to_f >= 1.0, u["steps"].to_i,
              u["cost_usd"].to_f, u["input_tokens"].to_i, u["cached_tokens"].to_i, r["model"],
              r["profile_digest"], r["task_digest"], r["started_at"], r["finished_at"])
  end
end

run6 = { "baseline" => load(HERE.join("baseline/runs/#{RUN}/*/*/result.json").to_s),
         "process"  => load(HERE.join("process/runs/#{RUN}/*/*/result.json").to_s) }
prior = { "baseline" => load(HERE.join("baseline/runs/#{MODEL_DIR}/*/result.json").to_s),   # run 2
          "process"  => load(HERE.join("process/runs/#{MODEL_DIR}/*/result.json").to_s) }    # run 4
pooled = run6.to_h { |a, ts| [a, ts + prior[a]] }

def pass_of(ts, tasks) = ts.select { |t| tasks.include?(t.task) && t.scored }.then { |s| [s.count(&:passed), s.size] }
def pct(a, b) = b.zero? ? "n/a" : "#{(100.0 * a / b).round}%"
def frac(a, b) = "#{a}/#{b} (#{pct(a, b)})"
def phi(z) = 0.5 * (1 + Math.erf(z / Math.sqrt(2)))
def ztest(p1, n1, p0, n0)
  return [nil, nil, nil] if n1.zero? || n0.zero?
  pp = (p1 + p0).to_f / (n1 + n0)
  return [0.0, 0.0, 0.5] if pp.zero? || pp >= 1
  se = Math.sqrt(pp * (1 - pp) * (1.0 / n1 + 1.0 / n0))
  delta = 100.0 * (p1.to_f / n1 - p0.to_f / n0)
  z = (p1.to_f / n1 - p0.to_f / n0) / se
  [delta, z, 1 - phi(z)]
end
def fmt(x, d = 2) = x.nil? ? "n/a" : format("%.#{d}f", x)

tasks = (R + NOT_R + ["hello-world"]).sort
all6 = run6.values.flatten
total_cost = all6.sum(&:cost)
starts = all6.map(&:started).compact.map { Time.parse(_1) }
ends = all6.map(&:finished).compact.map { Time.parse(_1) }
wall = starts.empty? ? 0 : ((ends.max - starts.min) / 60).round

puts "# Lens pilot, run 6: the pre-registered check-reachability split"
puts
puts "Run #{DATE} on the mini. gpt-5.6-luna via OpenRouter (`--model` override on the"
puts "arm's bench.yml, so the arm directories are byte-identical to the branch), host-side"
puts "miniswen, docker backend, upstream trial limits. All 22 Writebook stage-1 tasks,"
puts "#{K} attempts per task, two arms run one after the other at 3 trials in flight."
puts "#{all6.size} trials, $#{'%.2f' % total_cost}, #{wall} min wall clock."
puts
puts "Pre-registered before launch (brief 2026-10-06, from the corpus-2 survey): the"
puts "process lens beats baseline on the 14 tasks whose hidden checks a self-written"
puts "integration/model test can reach (one-sided), and does nothing on the 7 whose"
puts "checks need instrumentation or assert an unstated requirement. Primary readout"
puts "is arm-level pass per subset at k=15, pooling run 6 with run 2's baseline and"
puts "run 4's process arm. Kill: reachable delta under +5 points or z < 1.64 → the"
puts "lens is \"behaviour only\"; the 7 moving as much as the 14 → the split is wrong."
puts
puts "## Headline, run 6 alone"
puts
arms = %w[baseline process]
puts "| | #{arms.join(' | ')} |"
puts "|---|---|---|"
puts "| trials solved | #{arms.map { |a| s = run6[a].select(&:scored); frac(s.count(&:passed), s.size) }.join(' | ')} |"
puts "| pass@#{K} | #{arms.map { |a| "#{tasks.count { |t| run6[a].any? { |x| x.task == t && x.passed } }}/#{tasks.size}" }.join(' | ')} |"
puts "| mean steps | #{arms.map { |a| ts = run6[a]; ts.empty? ? 'n/a' : (ts.sum(&:steps).to_f / ts.size).round(1) }.join(' | ')} |"
puts "| cache hit | #{arms.map { |a| pct(run6[a].sum(&:cached), run6[a].sum(&:input)) }.join(' | ')} |"
puts "| cost | #{arms.map { |a| "$#{'%.2f' % run6[a].sum(&:cost)}" }.join(' | ')} |"
puts "| cost per trial | #{arms.map { |a| ts = run6[a]; ts.empty? ? 'n/a' : "$#{'%.4f' % (ts.sum(&:cost) / ts.size)}" }.join(' | ')} |"
puts "| invalid (unscored) trials | #{arms.map { |a| run6[a].count { |x| !x.scored } }.join(' | ')} |"
puts
puts "## The split"
puts
puts "Pass / scored trials per subset. z is the two-proportion test, process minus"
puts "baseline; p is one-sided (the pre-registered direction)."
puts
puts "| subset | baseline k=#{K} | process k=#{K} | Δ pts | z | baseline pooled | process pooled | Δ pts | z | p |"
puts "|---|---|---|---|---|---|---|---|---|---|"
kill = {}
SETS.each do |label, set|
  b6 = pass_of(run6["baseline"], set); p6 = pass_of(run6["process"], set)
  d6, z6, = ztest(p6[0], p6[1], b6[0], b6[1])
  bp = pass_of(pooled["baseline"], set); pp_ = pass_of(pooled["process"], set)
  dp, zp, pv = ztest(pp_[0], pp_[1], bp[0], bp[1])
  kill[label] = [dp, zp]
  puts "| #{label} | #{frac(*b6)} | #{frac(*p6)} | #{fmt(d6, 1)} | #{fmt(z6)} | #{frac(*bp)} | #{frac(*pp_)} | #{fmt(dp, 1)} | #{fmt(zp)} | #{fmt(pv, 3)} |"
end
puts
puts "Pooled = run 6 + run 2 baseline (110 trials, 2026-09-23) and run 6 + run 4"
puts "process (110 trials, 2026-10-05); same model id, tasks, limits."
puts
puts "## Kill criteria, applied mechanically"
puts
dr, zr = kill["reachable (14)"]; dn, = kill["not reachable (7)"]
if dr.nil?
  puts "- no run 6 trials yet; nothing to apply."
else
  verdict1 = (dr >= 5 && zr >= 1.64) ? "survives" : "KILLED (downgrade to \"behaviour only\")"
  puts "- reachable subset, pooled: Δ #{fmt(dr, 1)} pts, z #{fmt(zr)} → threshold Δ ≥ +5 and z ≥ 1.64: **#{verdict1}**"
  verdict2 = dn.nil? ? "n/a" : (dn.abs >= dr.abs ? "KILLED (split is wrong: the 7 moved as much as the 14)" : "survives")
  puts "- not-reachable subset, pooled: Δ #{fmt(dn, 1)} pts against the reachable Δ #{fmt(dr, 1)}: **#{verdict2}**"
  puts
  puts "These are the pre-registered thresholds read off the table; the Reading section"
  puts "says what they mean after the trajectories have been looked at."
end
puts
puts "## Per task"
puts
puts "Solved / scored. `*` marks the five secondary tasks named before launch"
puts "(the reachable tasks with headroom in the k=5 data)."
puts
puts "| task | set | baseline k=#{K} | process k=#{K} | baseline pooled | process pooled |"
puts "|---|---|---|---|---|---|"
tasks.each do |t|
  set = R.include?(t) ? "R" : NOT_R.include?(t) ? "not-R" : "—"
  mark = SECONDARY.include?(t) ? "\\*" : ""
  cells = [run6["baseline"], run6["process"], pooled["baseline"], pooled["process"]].map { |ts| "%d/%d" % pass_of(ts, [t]) }
  puts "| #{t}#{mark} | #{set} | #{cells.join(' | ')} |"
end
puts
puts "## Provenance"
puts
arms.each do |a|
  puts "- #{a}, run 6: model #{run6[a].map(&:model).tally}, profile_digest #{run6[a].map(&:profile).tally}; prior arm profile_digest #{prior[a].map(&:profile).tally}."
  prior_td = prior[a].group_by(&:task).transform_values { |ts| ts.map(&:task_digest).uniq }
  mism = run6[a].reject { |x| prior_td.fetch(x.task, []).include?(x.task_digest) }.map(&:task).uniq
  puts "  task_digest against the prior arm: #{mism.empty? ? 'every run 6 trial matches' : "MISMATCH on #{mism.join(', ')}"}."
end
puts "- Arm directories: run6.sh refuses to launch unless `git diff lemans/run4-corpus-arms --"
puts "  bench/lemans/pilot/{baseline,process}` is empty; the launch log records the check."
puts "- A different profile_digest between run 6 and the prior arm is expected when the"
puts "  bench.yml model line differs from the `--model` override (baseline's file says"
puts "  Haiku since run 3); the task_digest match is the content check that matters."
puts
puts "## Reading"
puts
puts "<!-- interpretation pending: written after the trajectories are read, not by readout6.rb -->"
puts
puts "## Reproduce"
puts
puts "`bench/lemans/pilot/run6.sh` (two arms in sequence, `--model openrouter/openai/gpt-5.6-luna`,"
puts "`-k #{K} -c 3`, the 22 tasks by name, trials under `<arm>/runs/#{RUN}/`), then"
puts "`ruby bench/lemans/pilot/split/readout6.rb #{DATE}` for this file. `split/reanalysis.py`"
puts "is the k=5 post-hoc analysis that motivated the run; `split/checks.rb` regenerates"
puts "the per-check classification input from a local ai-evals checkout."
arms.each do |a|
  rep = HERE.join("split/lemans-report-#{RUN}-#{a}.txt")
  next unless rep.file?
  puts
  puts "### lemans report, #{a}"
  puts
  puts "```"
  puts rep.read.strip
  puts "```"
end
