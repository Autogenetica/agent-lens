#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Read runs/correctness-judge-<date>.csv (correctness-judge.rb output): how
# well does the advisory judge's `correct` separate verifier pass from fail,
# and is it calibrated? Compares against the diff-only comparator from the
# jev-router replay (gpt-6.1-sol subset, the 0.745 reference) on the same
# trials when that CSV is given as a second argument.
#
#   ruby bench/lemans/pilot/replay/correctness-judge-analyze.rb \
#     bench/lemans/pilot/replay/correctness-judge-<date>.csv \
#     [bench/lemans/pilot/replay/jev-router-replay-2026-10-04.csv]

require "csv"

rows = CSV.read(ARGV.fetch(0), headers: true).reject { |r| r["correct"].to_s.empty? }
ref = ARGV[1] ? CSV.read(ARGV[1], headers: true) : []
ref_by_trial = ref.to_h { |r| [r["trial"], r] }
label = ->(r) { r["reward"].to_f >= 1 ? 1 : 0 }

def auc(pairs)
  pos = pairs.select { |_, l| l == 1 }.map(&:first)
  neg = pairs.select { |_, l| l == 0 }.map(&:first)
  return nil if pos.empty? || neg.empty?
  wins = 0.0
  pos.each { |p| neg.each { |n| wins += p > n ? 1 : (p == n ? 0.5 : 0) } }
  wins / (pos.size * neg.size)
end

def fmt(x) = x.nil? ? "  n/a" : format("%.3f", x)

pass = rows.count { |r| label.(r) == 1 }
puts "trials: #{rows.size}  pass: #{pass}  fail: #{rows.size - pass}"
cost = rows.sum { |r| r["judge_cost_usd"].to_f }
puts format("judge cost: $%.3f total, $%.4f per trial; mean prompt tokens %d", cost, cost / rows.size, rows.sum { |r| r["prompt_tokens"].to_i } / rows.size)
puts "judge models: #{rows.map { |r| r['judge_model'] }.tally.inspect}"
puts "agent ran no tests: #{rows.count { |r| r['test_summary'] == 'none' }} trials"
puts

groups = { "all" => rows }
rows.group_by { |r| r["arm"] }.sort.each { |arm, rs| groups[arm] = rs }
puts "AUC of `correct` (pass vs fail), per arm"
puts format("%-34s %s", "", groups.keys.map { |g| g.rjust(9) }.join)
puts format("%-34s %s", "judge (diff + agent test output)", groups.map { |_, rs| fmt(auc(rs.map { |r| [r["correct"].to_f, label.(r)] })).rjust(9) }.join)
unless ref.empty?
  sol = rows.select { |r| ref_by_trial[r["trial"]]&.[]("judge_model") == "openai/gpt-6.1-sol" }
  puts "matched to jev-router sol-answered trials (n=#{sol.size}, #{sol.count { |r| label.(r) == 1 }} pass):"
  puts format("%-34s %s", "  judge, same trials", fmt(auc(sol.map { |r| [r["correct"].to_f, label.(r)] })).rjust(9))
  puts format("%-34s %s", "  diff-only comparator (sol)", fmt(auc(sol.map { |r| [ref_by_trial[r["trial"]]["comparator"].to_f, label.(r)] })).rjust(9))
  all_ref = rows.select { |r| ref_by_trial[r["trial"]] }
  puts format("%-34s %s", "  diff-only comparator (any model)", fmt(auc(all_ref.map { |r| [ref_by_trial[r["trial"]]["comparator"].to_f, label.(r)] })).rjust(9)) + "  (n=#{all_ref.size})"
end
puts

puts "calibration: score bin -> trials, observed pass rate, mean score"
bins = [[0.0, 0.1], [0.1, 0.2], [0.2, 0.3], [0.3, 0.4], [0.4, 0.5], [0.5, 0.6], [0.6, 0.7], [0.7, 0.8], [0.8, 0.9], [0.9, 0.95], [0.95, 1.01]]
bins.each do |lo, hi|
  rs = rows.select { |r| c = r["correct"].to_f; c >= lo && c < hi }
  next if rs.empty?
  pr = rs.count { |r| label.(r) == 1 } / rs.size.to_f
  ms = rs.sum { |r| r["correct"].to_f } / rs.size
  puts format("  [%.2f, %.2f)  n=%3d  pass %.2f  mean score %.3f  %s", lo, [hi, 1.0].min, rs.size, pr, ms, "#" * (rs.size / 3))
end
ece = bins.sum do |lo, hi|
  rs = rows.select { |r| c = r["correct"].to_f; c >= lo && c < hi }
  next 0.0 if rs.empty?
  (rs.count { |r| label.(r) == 1 } / rs.size.to_f - rs.sum { |r| r["correct"].to_f } / rs.size).abs * rs.size / rows.size
end
puts format("  expected calibration error (binned): %.3f", ece)
puts

puts "if it were a gate (it is not): threshold -> lets through / blocks"
[0.5, 0.8, 0.9, 0.95].each do |t|
  tp = rows.count { |r| r["correct"].to_f >= t && label.(r) == 1 }
  fp = rows.count { |r| r["correct"].to_f >= t && label.(r) == 0 }
  fn = rows.count { |r| r["correct"].to_f < t && label.(r) == 1 }
  tn = rows.count { |r| r["correct"].to_f < t && label.(r) == 0 }
  puts format("  %.2f: through %3d pass + %3d fail; blocked %3d pass + %3d fail; precision(blocked) %.2f recall(fail) %.2f", t, tp, fp, fn, tn, tn.to_f / [tn + fn, 1].max, tn.to_f / [tn + fp, 1].max)
end
puts

puts "per task: pass rate, mean judge score, mean diff-only comparator (any model / sol only), n"
rows.group_by { |r| r["task"] }.sort.each do |task, rs|
  pr = rs.count { |r| label.(r) == 1 } / rs.size.to_f
  mj = rs.sum { |r| r["correct"].to_f } / rs.size
  refs = rs.filter_map { |r| ref_by_trial[r["trial"]] }
  sols = refs.select { |r| r["judge_model"] == "openai/gpt-6.1-sol" }
  mc = refs.empty? ? nil : refs.sum { |r| r["comparator"].to_f } / refs.size
  ms = sols.empty? ? nil : sols.sum { |r| r["comparator"].to_f } / sols.size
  flag = (pr >= 0.8 && mj < 0.5) || (pr <= 0.2 && mj > 0.5) ? "  <- confidently wrong" : ""
  puts format("  %-28s pass %.2f  judge %.3f  diff-only %s / %s (n=%d/%d)%s", task, pr, mj, fmt(mc), fmt(ms), refs.size, sols.size, flag)
end
