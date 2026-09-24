# frozen_string_literal: true

require_relative "test_helper"

# Lens::Checklist is scored against synthetic bodies only. Real completions
# are a manual eval (bin/eval), never a test, per WORLD.md's offline-suite
# constraint.
class LensChecklistTest < Minitest::Test
  def item(n, name = "Guard #{n}", tail = "MUST verify: if the topic #{n} comes up, have you checked it?")
    "#{n}. **#{name}** — #{tail}"
  end

  def full_body(count = 12)
    (1..count).map { |n| item(n) }.join("\n")
  end

  def test_fully_conformant_body
    r = Lens::Checklist.score(full_body(12))
    assert_equal 12, r.count
    assert r.count_in_range?
    assert_equal 1.0, r.conformance_rate
    assert r.conformant?
    assert_equal %w[1 2 3], r.names.first(3).map { |n| n[/\d+/] }
    assert_equal({ bold_name: 0, must_verify: 0, conditional: 0, cites_source: 0 }, r.misses)
  end

  def test_count_outside_range_is_not_conformant
    assert_equal false, Lens::Checklist.score(full_body(9)).conformant?
    assert_equal false, Lens::Checklist.score(full_body(16)).conformant?
    assert Lens::Checklist.score(full_body(16)).items.all?(&:conformant?)
  end

  def test_missing_bold_name
    r = Lens::Checklist.score("1. MUST verify: if X, have you Y?")
    assert_equal false, r.items[0].bold_name
    assert_nil r.items[0].name
    assert_equal 1, r.misses[:bold_name]
  end

  def test_missing_must_verify_marker
    r = Lens::Checklist.score("1. **Name** — Verify: if X, have you Y?")
    assert_equal false, r.items[0].must_verify
  end

  def test_missing_conditional
    r = Lens::Checklist.score("1. **Name** — MUST verify: always check churn.")
    assert_equal false, r.items[0].conditional
    assert_equal 0.0, r.conformance_rate
  end

  def test_source_citation_is_a_miss
    r = Lens::Checklist.score(item(1, "Name", "MUST verify: if X, have you Y? The author argues this in chapter 3."))
    assert r.items[0].cites_source
    assert_equal false, r.items[0].conformant?
  end

  def test_plain_english_the_source_is_not_a_citation
    r = Lens::Checklist.score(item(1, "Name", "MUST verify: if the source of truth is unclear, have you named it?"))
    assert_equal false, r.items[0].cites_source
  end

  def test_continuation_lines_and_preamble
    body = "Here is the list:\n1. **A** — MUST verify:\n   if X,\n   have you Y?\n2) **B** — MUST verify: if P, have you Q?"
    r = Lens::Checklist.score(body)
    assert_equal 2, r.count
    assert r.items[0].conditional
    assert_equal [1, 2], r.items.map(&:number)
  end

  def test_empty_body
    r = Lens::Checklist.score("")
    assert_equal 0, r.count
    assert_equal 0.0, r.conformance_rate
    assert_equal false, r.conformant?
  end

  def test_name_overlap_is_case_insensitive_jaccard
    assert_equal 1.0, Lens::Checklist.name_overlap(["A guard"], ["a Guard"])
    assert_in_delta 1.0 / 3, Lens::Checklist.name_overlap(%w[a b], %w[b c])
    assert_equal 0.0, Lens::Checklist.name_overlap(%w[a], %w[b])
    assert_equal 1.0, Lens::Checklist.name_overlap([], [])
  end
end
