#!/usr/bin/env ruby
# frozen_string_literal: true

# Blind extractor for the asa#35 A/B rerun (task-a5e5dabd). Ruby port of
# extract-rated.py; same filters, same output layout.
#
# Takes an arm's concatenated member reviews (A/review.md, B/review.md) and emits
# one file per member containing ONLY the rated sections (Concerns and
# Recommendations), with the treatment's structural tells removed:
#
#   * drops sections whose heading matches the treatment persona fields
#     (Silent checklist / Blocking criteria / Signature trade-off) and
#     everything else that isn't Concerns or Recommendations;
#   * redacts the treatment phrases inline ("[redacted]") rather than dropping lines,
#     so arm B does not lose rated content;
#   * normalizes per-concern headers to one canonical form
#     ("### Cn (severity): title") so arm A's "### C1. title (critical)" and
#     arm B's "**C1 — critical. title**" are indistinguishable;
#   * numbers output files by shuffled slot, writing the slot->member map to
#     a sealed key file the rater must not open until scoring is done.
#
# The shuffle uses Ruby's Random, so a given --seed yields a different slot
# order than the Python script did. Log which extractor produced a run.
#
# Usage: ruby extract_rated.rb <review.md> <outdir> [--seed N]

require "json"
require "fileutils"

module ExtractRated
  KEEP = %w[concerns recommendations].freeze
  REDACT = /silent[ -]checklist|signature[ -]trade[ -]?off|blocking[ -]criteri\w*/i
  HDR_A = /\A###\s+(C\d+)[.:]?\s+(.*?)\s*\((\w+)\)\s*\z/
  HDR_B = /\A\*\*(C\d+)\s*[—–-]+\s*(\w+)\.\s*(.*?)\*\*\s*\z/
  HDR_S = /\A###\s+(critical|high|medium|low)\s*[:.]\s*(.*?)\s*\z/i
  SEV_SUFFIX = /\s*(?:Severity:|[—–-]+)\s*\*{0,2}(critical|high|medium|low)\*{0,2}\s*(\([^)]*\))?\s*\z/i

  MEMBER_HDR = /^\#{1,2}\s+(?!Arm )(.*\breview\b.*)$/i
  SECTION_HDR = /\A(\#{2,3})\s+(?!(?:C\d+|critical|high|medium|low)\b)(.*)\z/i
  # A "###" heading only switches sections when it names a known top-level section;
  # otherwise it is content (e.g. "### Immediate" under Recommendations). "##" always switches.
  SECTION_WORDS = %w[perspective key strengths concerns recommendations
                     risks silent signature blocking].freeze

  module_function

  def members(text)
    starts = text.to_enum(:scan, MEMBER_HDR).map { Regexp.last_match.begin(0) }
    starts.zip(starts.drop(1) + [text.length]).map { |a, b| text[a...b] }
  end

  def section_switch?(match)
    return true if match[1] == "##"

    first = match[2].strip.downcase.split.first.to_s.sub(/[,:]+\z/, "")
    SECTION_WORDS.include?(first)
  end

  def rated_sections(member_text)
    lines = []
    keep = false
    member_text.each_line(chomp: true) do |ln|
      m = SECTION_HDR.match(ln)
      if m && section_switch?(m)
        cur = m[2].strip.downcase.split(" (").first.to_s.split(" within").first.to_s
        keep = KEEP.include?(cur)
        lines << "## #{cur.capitalize}" if keep
        next
      end
      next unless keep

      ln = ln.gsub(REDACT, "[redacted]")
      sv = SEV_SUFFIX.match(ln)
      if ln.start_with?("### ") && sv
        rest = ln[4..].sub(SEV_SUFFIX, "").gsub(/\A[.: ]+|[.: ]+\z/, "")
        ln = "### (#{sv[1].downcase}): #{rest}"
      end
      a = HDR_A.match(ln)
      b = HDR_B.match(ln)
      c = HDR_S.match(ln)
      ln = "### (#{c[1].downcase}): #{c[2]}" if c
      if a
        ln = "### #{a[1]} (#{a[3].downcase}): #{a[2]}"
      elsif b
        ln = "### #{b[1]} (#{b[2].downcase}): #{b[3]}"
      end
      lines << ln
    end
    "#{lines.join("\n").strip}\n"
  end

  def run(argv)
    args = argv.reject { |a| a.start_with?("--") }
    seed = argv.include?("--seed") ? Integer(argv[argv.index("--seed") + 1]) : 0
    abort "usage: ruby extract_rated.rb <review.md> <outdir> [--seed N]" if args.length < 2

    src, outdir = args
    FileUtils.mkdir_p(outdir)
    ms = members(File.read(src))
    order = (0...ms.length).to_a.shuffle(random: Random.new(seed))
    key = {}
    order.each.with_index(1) do |idx, slot|
      name = format("slot-%02d", slot)
      title = ms[idx].lines.first.sub(/\A[# ]+/, "").strip
      File.write(File.join(outdir, "#{name}.md"), rated_sections(ms[idx]))
      key[name] = title
    end
    File.write(File.join(outdir, "KEY-sealed.json"), "#{JSON.pretty_generate(key)}\n")
    puts "#{src}: #{ms.length} members -> #{outdir} (key sealed, seed=#{seed})"
  end
end

ExtractRated.run(ARGV) if $PROGRAM_NAME == __FILE__
