#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails-API reach readout for the lens pilot.
#
# pass@k says whether the agent solved the task. Reach says whether it solved
# it with the framework's own API or hand-rolled the same behaviour. Every
# ai-evals task names the API its reference solution turns on in its
# frontmatter (`metadata.rails_anchor`), and lemans copies that metadata into
# each trial's result.json next to the agent's patch. So per trial:
#
#   reached = the anchor appears on a line the agent ADDED in agent.patch
#
# That is the cheapest honest version of the metric: no LLM judge, no AST,
# one token per task chosen by the task author. It under-counts when the
# agent used a synonym (`rate_limit` vs `Rack::Attack` is exactly the gap we
# want to see, so that is the point) and over-counts when the anchor shows up
# in a comment; read the patch when a row looks odd.
#
#   ruby bench/lemans/pilot/reach.rb                       # baseline vs lensed
#   ruby bench/lemans/pilot/reach.rb fable=path/to/runs    # any run dirs, any names
#
# Rows pair by task name across arms. Tasks whose anchor starts with "none"
# (the infrastructure hello-world) are skipped, not counted as misses.

require "json"
require "pathname"
require "yaml"

HERE = Pathname(__dir__)
DEFAULT_ARMS = { "baseline" => HERE.join("baseline/runs"), "lensed" => HERE.join("lensed/runs") }.freeze

Trial = Struct.new(:task, :anchor, :scored, :passed, :reached, :patch_missing)

def frontmatter_anchor(arm_dir, task)
  file = arm_dir.join("..", "tasks", task, "instruction.md")
  return unless file.file?

  head = file.read[/\A---\n(.*?)\n---/m, 1]
  YAML.safe_load(head.to_s).dig("metadata", "rails_anchor")
rescue StandardError
  nil
end

def anchor_pattern(anchor) = /(?<![A-Za-z0-9_])#{Regexp.escape(anchor)}(?![A-Za-z0-9_])/

def added_lines(patch)
  patch.each_line.select { it.start_with?("+") && !it.start_with?("+++") }
end

def load_trials(arm_dir)
  arm_dir.glob("**/result.json").filter_map do |path|
    data = JSON.parse(path.read)
    task = data["task"]
    anchor = data.dig("metadata", "rails_anchor") || frontmatter_anchor(arm_dir, task)
    next if anchor.nil? || anchor.to_s.start_with?("none")

    patch = path.dirname.join("agent.patch")
    reached = patch.file? && added_lines(patch.read).any? { it.match?(anchor_pattern(anchor)) }
    Trial.new(task, anchor, data.dig("outcome", "scored") == true, data["reward"].to_f >= 1.0, reached, !patch.file?)
  rescue JSON::ParserError
    nil
  end
end

def tally(trials)
  n = trials.size
  pass = trials.count(&:passed)
  reach = trials.count(&:reached)
  both = trials.count { it.passed && it.reached }
  { n:, pass:, reach:, both:, missing: trials.count(&:patch_missing) }
end

def pct(num, den) = den.zero? ? "  -" : format("%3d%%", (100.0 * num / den).round)
def frac(num, den) = den.zero? ? "-" : "#{num}/#{den}"

arms = ARGV.empty? ? DEFAULT_ARMS : ARGV.to_h { |a| name, dir = a.split("=", 2); [ name, Pathname(dir || name) ] }
arms = arms.transform_values { |dir| dir.directory? ? load_trials(dir) : nil }

missing = arms.select { |_, t| t.nil? }.keys
warn "reach: no runs directory for #{missing.join(', ')}" unless missing.empty?
arms = arms.compact
abort "reach: nothing to read" if arms.empty?

tasks = arms.values.flatten.map(&:task).uniq.sort
by_task = arms.transform_values { |trials| trials.group_by(&:task) }
anchors = arms.values.flatten.to_h { [ it.task, it.anchor ] }

name_w = [ tasks.map(&:size).max || 4, 4 ].max
anchor_w = [ anchors.values.map(&:size).max || 6, 6 ].max
col_w = 15

puts "#{'task'.ljust(name_w)}  #{'anchor'.ljust(anchor_w)}  #{arms.keys.map { it.ljust(col_w) }.join('  ')}"
puts "#{''.ljust(name_w)}  #{''.ljust(anchor_w)}  #{arms.keys.map { 'pass   reach'.ljust(col_w) }.join('  ')}"
tasks.each do |task|
  cells = arms.keys.map do |arm|
    trials = by_task[arm][task]
    next "-".ljust(col_w) unless trials

    t = tally(trials)
    "#{frac(t[:pass], t[:n]).ljust(6)} #{frac(t[:reach], t[:n])}".ljust(col_w)
  end
  puts "#{task.ljust(name_w)}  #{anchors[task].ljust(anchor_w)}  #{cells.join('  ')}"
end

puts
arms.each do |arm, trials|
  t = tally(trials)
  line = "#{arm.ljust(name_w)}  pass #{frac(t[:pass], t[:n]).ljust(7)} #{pct(t[:pass], t[:n])}   " \
         "reach #{frac(t[:reach], t[:n]).ljust(7)} #{pct(t[:reach], t[:n])}   " \
         "reach|pass #{frac(t[:both], t[:pass]).ljust(7)} #{pct(t[:both], t[:pass])}"
  line += "   (#{t[:missing]} trials without agent.patch)" if t[:missing].positive?
  puts line
end
