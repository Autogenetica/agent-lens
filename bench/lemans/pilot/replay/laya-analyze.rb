#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Analyze runs/laya-replay.csv: for each question (and a few aggregates), how
# well does laya's probability separate verifier pass from fail? AUC is the
# probability a random passing trial scores higher than a random failing one
# (0.5 = coin flip). Also a 2x2 at the median for the best aggregate.
#
#   ruby bench/lemans/pilot/replay/laya-analyze.rb bench/lemans/pilot/replay/laya-replay-<date>.csv

require "csv"

rows = CSV.read(ARGV.fetch(0), headers: true)
meta = %w[arm task trial reward steps cost state_chars]
questions = rows.headers - meta

def auc(pairs) # [[score, label(1/0)], ...]
  pos = pairs.select { |_, l| l == 1 }.map(&:first)
  neg = pairs.select { |_, l| l == 0 }.map(&:first)
  return nil if pos.empty? || neg.empty?
  wins = 0.0
  pos.each { |p| neg.each { |n| wins += p > n ? 1 : (p == n ? 0.5 : 0) } }
  wins / (pos.size * neg.size)
end

def fmt(x) = x.nil? ? "  n/a" : format("%.3f", x)

label = ->(r) { r["reward"].to_f >= 1 ? 1 : 0 }

def aggregates(r, questions)
  items = (questions - ["comparator"]).map { |q| r[q].to_f }
  {
    "mean_items" => items.sum / items.size,
    "min_items" => items.min,
    "n_below_0.5" => -items.count { |p| p < 0.5 }, # negated so higher = better
    "comparator" => r["comparator"].to_f
  }
end

groups = { "all" => rows.map { |r| r } }
rows.group_by { |r| r["arm"] }.each { |arm, rs| groups[arm] = rs }

puts "trials: #{rows.size}  pass: #{rows.count { |r| label.(r) == 1 }}  fail: #{rows.count { |r| label.(r) == 0 }}"
puts "mean state chars: #{(rows.sum { |r| r['state_chars'].to_i } / rows.size.to_f).round}"
puts

puts "AUC by question (pass vs fail), per arm"
puts format("%-22s %s", "question", groups.keys.map { |g| g.rjust(9) }.join)
questions.each do |q|
  puts format("%-22s %s", q, groups.map { |_, rs| fmt(auc(rs.map { |r| [r[q].to_f, label.(r)] })).rjust(9) }.join)
end
puts
puts "AUC by aggregate"
%w[mean_items min_items n_below_0.5 comparator].each do |a|
  puts format("%-22s %s", a, groups.map { |_, rs| fmt(auc(rs.map { |r| [aggregates(r, questions)[a], label.(r)] })).rjust(9) }.join)
end
puts

# 2x2 for the comparator at its median: would a gate at that threshold have
# blocked failures without blocking passes?
all = rows.map { |r| r }
scores = all.map { |r| r["comparator"].to_f }.sort
median = scores[scores.size / 2]
tp = all.count { |r| r["comparator"].to_f >= median && label.(r) == 1 }
fp = all.count { |r| r["comparator"].to_f >= median && label.(r) == 0 }
fn = all.count { |r| r["comparator"].to_f < median && label.(r) == 1 }
tn = all.count { |r| r["comparator"].to_f < median && label.(r) == 0 }
puts "comparator gate at median #{median.round(3)}: let through #{tp} pass + #{fp} fail; blocked #{fn} pass + #{tn} fail"
puts "  precision of 'blocked' as a failure detector: #{(tn.to_f / (tn + fn)).round(3)}  recall of failures: #{(tn.to_f / (tn + fp)).round(3)}"
puts

# Per-task mean comparator vs pass rate: does it at least know which tasks are hard?
puts "per task: pass rate vs mean comparator probability"
rows.group_by { |r| r["task"] }.sort.each do |task, rs|
  pr = rs.count { |r| label.(r) == 1 } / rs.size.to_f
  mc = rs.sum { |r| r["comparator"].to_f } / rs.size
  puts format("  %-28s pass %.2f  comparator %.3f", task, pr, mc)
end
