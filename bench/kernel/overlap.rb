#!/usr/bin/env ruby
# frozen_string_literal: true

# Mechanical readout for the asa35 A/B (issue #35, metric 1). Ruby port of
# overlap.py; same parsing, same matching, same output.
#
# For each arm directory containing members/<member>.md:
#   * findings per member = items under the heading that contains "Concern",
#     where an item is a `###`/`####` heading or a top-level list bullet whose
#     text (or the next 2 lines) carries a severity word
#     (critical|high|medium|low).
#   * each finding is normalized to (title_tokens, locations):
#       - title_tokens: lowercase alphanumeric words of the item line, minus the
#         severity word, markdown, and a stop-list; stemmed crudely (strip a
#         trailing 's').
#       - locations: every `path:line` or bare file reference in the item's
#         block (item line + following lines up to the next item).
#   * two findings from DIFFERENT members match if either
#       (a) they cite the same file with line numbers within +/-5, or
#       (b) Jaccard(title_tokens) >= 0.5.
#   * pairwise overlap for members (i, j) = matched_pairs / min(n_i, n_j)
#     (0 when either has no findings). The arm's score is the mean over all
#     member pairs. Lower = more differentiated reviews (the #35 prediction for
#     the treatment arm).
# Prints a per-arm table and the per-pair matrix, writes <arm>/overlap.json;
# no judgment.
#
# Usage: ruby overlap.rb <arm_dir> [<arm_dir> ...]

require "json"
require "set"

module Overlap
  SEV = /\b(critical|high|medium|low)\b/i
  EXT = "(?:js|json|md|yml|yaml|mjs|ts)"
  LOC = /((?:[\w.-]+\/)*[\w.-]+\.#{EXT}):(\d+)/
  FILE = /\b((?:[\w.-]+\/)*[\w.-]+\.#{EXT})\b/
  STOP = %w[
    the a an of in on to for and or is are be with without by from as at
    this that it its into no not vs via when per any all each file line
    severity concern concerns issue why matters fix location
  ].to_set.freeze
  FIELD = /\A\W*(location|why it matters|why|fix|concrete fix|fixes|severity|impact|
            recommendation|not recommended|adjacent|evidence|effort|signature\ trade-off|
            mode|reviewer|scope|note|verification|cost|trigger)\b/ix
  LOC_TOL = 5
  TITLE_J = 0.5

  module_function

  def tokens(s)
    s = s.gsub(SEV, " ").downcase.gsub(/[`*_#>\[\]()|:\/.,;!?"'-]/, " ")
    s.split.each_with_object(Set.new) do |w, out|
      next if w.length < 3 || STOP.include?(w) || w.match?(/\A\d+\z/)

      out << (w.end_with?("s") && w.length > 4 ? w[0..-2] : w)
    end
  end

  # Lines of the Concerns section (from the heading containing 'concern' up
  # to the next heading of the same or higher level).
  def section_lines(text)
    lines = text.lines(chomp: true)
    start = level = nil
    lines.each_with_index do |l, i|
      m = l.match(/\A(\#{1,6})\s+(.*)/)
      next unless m && m[2].downcase.include?("concern")

      start = i + 1
      level = m[1].length
      break
    end
    return [] if start.nil?

    lines[start..].take_while do |l|
      m = l.match(/\A(\#{1,6})\s+/)
      !(m && m[1].length <= level)
    end
  end

  def strip_md(l)
    l.sub(/\A(\#{1,6}|[-*+]|\d+[.)])\s*/, "").strip.gsub(/\A\*+|\*+\z/, "").strip
  end

  # Items in the Concerns section. Three shapes are recognised:
  # (a) `###`/`####` heading lines (severity in the line or next 2 lines);
  # (b) bold-lead paragraph lines `**...**` with a severity word in the line;
  # (c) top-level `-`/`1.` bullets with a severity word in the line.
  # Lines whose text starts with a field label (Location, Why it matters, Fix,
  # ...) are never findings.
  def findings(text)
    sec = section_lines(text)
    items = []
    cur = nil
    sec.each_with_index do |l, idx|
      is_head = l.match?(/\A\#{3,6}\s+\S/)
      is_bold = l.match?(/\A\*\*\S/)
      is_bullet = l.match?(/\A(?:[-*+]|\d+[.)])\s+\S/)
      if is_head || is_bold || is_bullet
        txt = strip_md(l)
        unless txt.match?(FIELD)
          window = is_head ? sec[idx, 3].join(" ") : l
          if window.match?(SEV)
            cur = { title: txt, block: [l] }
            items << cur
            next
          end
        end
      end
      cur[:block] << l if cur
    end
    items.each do |it|
      head = it[:block].first(3).join("\n")
      m = it[:title].match(SEV) || head.match(SEV)
      it[:sev] = m ? m[1].downcase : "?"
      it[:tok] = tokens(it[:title])
      blk = it[:block].join("\n")
      it[:locs] = blk.scan(LOC).map { |f, n| [File.basename(f), n.to_i] }
      it[:files] = blk.scan(FILE).flatten.map { |f| File.basename(f) }.to_set
    end
    items
  end

  def match(a, b, loc_tol = LOC_TOL, title_j = TITLE_J)
    a[:locs].each do |fa, la|
      b[:locs].each do |fb, lb|
        return "loc" if fa == fb && (la - lb).abs <= loc_tol
      end
    end
    if a[:tok].any? && b[:tok].any?
      j = (a[:tok] & b[:tok]).size.fdiv((a[:tok] | b[:tok]).size)
      return "title" if j >= title_j
    end
    nil
  end

  def mean_overlap(members, loc_tol, title_j)
    scores = members.keys.sort.combination(2).map do |i, j|
      fi, fj = members[i], members[j]
      matched = fi.count { |a| fj.any? { |b| match(a, b, loc_tol, title_j) } }
      denom = [fi.size, fj.size].min
      denom.zero? ? 0.0 : matched.fdiv(denom)
    end
    scores.empty? ? 0.0 : scores.sum / scores.size
  end

  # Cluster every cited (file,line) across all findings in the arm; return
  # (n_clusters, share of findings touching the largest cluster, span).
  def hotspots(members, tol = 5)
    pts = []
    members.each do |m, fs|
      fs.each_with_index { |f, k| f[:locs].each { |loc| pts << [loc, [m, k]] } }
    end
    pts.sort!
    clusters = []
    pts.each do |fl, fid|
      last = clusters.last
      if last && last[0][0][0] == fl[0] && fl[1] - last[-1][0][1] <= tol
        last << [fl, fid]
      else
        clusters << [[fl, fid]]
      end
    end
    total = members.values.sum(&:size)
    return [0, 0.0, nil] if clusters.empty?

    big = clusters.max_by { |c| c.map(&:last).uniq.size }
    share = total.zero? ? 0.0 : big.map(&:last).uniq.size.fdiv(total)
    [clusters.size, share, [big[0][0][0], big[0][0][1], big[-1][0][1]]]
  end

  def arm(dirpath)
    dir = File.join(dirpath, "members")
    members = {}
    Dir.children(dir).sort.each do |fn|
      next unless fn.end_with?(".md")

      members[fn.delete_suffix(".md")] = findings(File.read(File.join(dir, fn), encoding: "utf-8"))
    end
    pair_scores = {}
    pair_detail = []
    members.keys.sort.combination(2).each do |i, j|
      fi, fj = members[i], members[j]
      matched = 0
      fi.each do |a|
        fj.each do |b|
          how = match(a, b)
          next unless how

          matched += 1
          pair_detail << [i, j, how, a[:title][0, 60], b[:title][0, 60]]
          break
        end
      end
      denom = [fi.size, fj.size].min
      pair_scores[[i, j]] = denom.zero? ? 0.0 : matched.fdiv(denom)
    end
    mean = pair_scores.empty? ? 0.0 : pair_scores.values.sum / pair_scores.size
    [members, pair_scores, pair_detail, mean]
  end

  # Python-style repr, so stdout matches overlap.py line for line.
  def pyrepr(v)
    case v
    when nil then "None"
    when String then v.include?("'") && !v.include?('"') ? "\"#{v}\"" : "'#{v.gsub("\\", "\\\\\\\\").gsub("'", "\\\\'")}'"
    when Array then "(#{v.map { |x| pyrepr(x) }.join(', ')})"
    else v.to_s
    end
  end

  def main(argv)
    argv.each do |d|
      members, pairs, detail, mean = arm(d)
      label = File.basename(d.chomp("/"))
      total = members.values.sum(&:size)
      puts "## Arm #{label}: #{members.size} members, #{total} findings, mean pairwise overlap #{format('%.3f', mean)}"
      puts "| member | findings | critical | high | medium | low |"
      puts "|---|---|---|---|---|---|"
      members.each do |m, fs|
        c = %w[critical high medium low].map { |s| fs.count { |f| f[:sev] == s } }
        puts "| #{m} | #{fs.size} | #{c.join(' | ')} |"
      end
      puts
      puts "Pairwise overlap (matched / min(n_i, n_j)):"
      pairs.sort.each { |(i, j), s| puts "  #{i} x #{j}: #{format('%.2f', s)}" }
      sens = [0, 5, 20].product([0.3, 0.5]).map do |t, j|
        "tol=#{t}/jac=#{j}: #{format('%.3f', mean_overlap(members, t, j))}"
      end
      puts "Sensitivity (mean pairwise overlap): #{sens.join(', ')}"
      nc, share, big = hotspots(members)
      puts "Location clusters (±5 lines, same file): #{nc}; largest cluster #{pyrepr(big)} touches #{format('%.0f', share * 100)}% of findings"
      puts "Cross-member matched pairs: #{detail.size}"
      detail.each { |i, j, how, ta, tb| puts "  [#{how}] #{i} <-> #{j}: #{pyrepr(ta)} ~ #{pyrepr(tb)}" }
      puts
      out = {
        arm: label,
        members: members.transform_values { |fs| fs.map { |f| { title: f[:title], sev: f[:sev], locs: f[:locs] } } },
        pairwise: pairs.to_h { |(i, j), s| ["#{i}|#{j}", s] },
        mean_pairwise_overlap: mean,
        total_findings: total
      }
      File.write(File.join(d, "overlap.json"), JSON.pretty_generate(out, indent: " "))
    end
  end
end

Overlap.main(ARGV) if $PROGRAM_NAME == __FILE__
