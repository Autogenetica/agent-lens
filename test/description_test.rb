# frozen_string_literal: true

require_relative "test_helper"

class LensDescriptionTest < Minitest::Test
  BODY = <<~BODY
    1. **Small objects** — MUST verify: if a class is growing past one responsibility, have you split it?
    2. **Naming** — MUST verify: if a method name hides a side effect, have you renamed it?
    3. **Tests** — MUST verify: If **a change** touches `public` behaviour, have you added a test?
  BODY

  def test_derives_from_trigger_clauses_in_body_order
    description = Lens::Description.derive(name: "ruby-discipline", body: BODY)

    assert_match(/\ARuby Discipline skill/, description)
    assert_includes description,
                    "Use when the conversation involves a class is growing past one responsibility; " \
                    "a method name hides a side effect; a change touches public behaviour."
    assert_includes description, "override with --description"
    refute_includes description, "acting as"
  end

  def test_framing_is_appended_after_the_triggers
    description = Lens::Description.derive(name: "x", body: BODY, framing: "a reviewer")

    assert_match(/behaviour\. Applies when the agent is acting as a reviewer\. \(Auto-generated/, description)
  end

  def test_triggers_dedupe_case_insensitively_and_ignore_items_without_a_clause
    body = <<~BODY
      1. **A** — MUST verify: if the query is unbounded, have you paged it?
      2. **B** — MUST verify: If the Query is Unbounded, have you added a limit?
      3. **C** — MUST verify: check the indexes.
    BODY

    assert_equal ["the query is unbounded"], Lens::Description.triggers(body)
  end

  def test_falls_back_when_nothing_parses
    body = "1. **A** — MUST verify: check the indexes.\n2. **B** — look twice.\n"
    description = Lens::Description.derive(name: "db-notes", body: body, framing: "a DBA")

    assert_equal Lens::Description.fallback("db-notes", "a DBA"), description
    assert_match(/\ADb Notes skill: a pre-response verification checklist applied/, description)
    assert_includes description, "acting as a DBA"
  end

  def test_stays_under_the_cap_by_dropping_trailing_triggers
    items = (1..40).map do |n|
      "#{n}. **Item #{n}** — MUST verify: if trigger number #{n} #{'lorem ipsum ' * 6}fires, have you checked?"
    end
    description = Lens::Description.derive(name: "long", body: items.join("\n"))

    assert_operator description.length, :<=, Lens::Validator::DESCRIPTION_MAX
    assert_includes description, "trigger number 1 "
    refute_includes description, "trigger number 40 "
    assert_match(/fires\. \(Auto-generated/, description)
  end

  def test_empty_body_falls_back
    assert_equal Lens::Description.fallback("x", nil), Lens::Description.derive(name: "x", body: "")
  end
end
