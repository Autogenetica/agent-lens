#!/usr/bin/env ruby
# frozen_string_literal: true

# Leakage + size gate for the vocabulary control arm.
#
#   ruby bench/lemans/pilot/control/check.rb [AI_EVALS_DIR]
#
# The control text must (1) contain none of the task anchors (rails_anchor in
# every ai-evals task's frontmatter), (2) contain none of the identifiers the
# real lens sets in backticks, and (3) be the same size as the real lens to
# within 5% (word count; the two files share the intro verbatim, so words are
# a fair proxy for tokens). Exit 1 on any failure so prepare.sh refuses to
# build a leaky arm.

require "pathname"

here = Pathname(__dir__)
lens = here.join("../../lens/SKILL.md").read
control = here.join("LENS.md").read
ai_evals = Pathname(ARGV[0] || File.join(Dir.home, "src/ai-evals"))

strip = ->(t) { t.sub(/\A---\s*\n.*?\n---\s*\n/m, "") }
lens_body = strip.(lens)
control_body = strip.(control)

anchors = ai_evals.glob("tasks/*/instruction.md").filter_map do |f|
  f.read[/rails_anchor:\s*(\S+)/, 1]
end.reject { it.start_with?("none") }.uniq

backticked = lens_body.scan(/`([^`]+)`/).flatten.uniq
# Plain English nouns the real lens happens to backtick as helpers; the
# control cannot talk about caching or cookies without them.
ALLOW = %w[cache cookies].freeze
terms = (anchors + backticked - ALLOW).uniq

boundary = ->(t) { /(?<![A-Za-z0-9_])#{Regexp.escape(t)}(?![A-Za-z0-9_])/ }
leaks = terms.select { control_body.match?(boundary.(it)) }
# Anything that still looks like an identifier: snake_case, Namespaced::Const, dotted calls.
shaped = control_body.scan(/\b(?:[a-z]+_[a-z_]+|[A-Z][A-Za-z]+::[A-Z][A-Za-z:]+|[A-Za-z]+\.[a-z_]+\()/).uniq

lw = lens_body.split.size
cw = control_body.split.size
ratio = (cw - lw).fdiv(lw)

puts "anchors checked: #{anchors.size}  backticked identifiers: #{backticked.size}  allowlisted: #{ALLOW.join(', ')}"
puts "words: lens=#{lw} control=#{cw} (#{format('%+.1f%%', ratio * 100)})"
puts "leaks: #{leaks.empty? ? 'none' : leaks.join(', ')}"
puts "identifier-shaped tokens: #{shaped.empty? ? 'none' : shaped.join(', ')}"

ok = leaks.empty? && shaped.empty? && ratio.abs <= 0.05
puts(ok ? "CONTROL: OK" : "CONTROL: FAIL")
exit(ok ? 0 : 1)
