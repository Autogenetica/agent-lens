# frozen_string_literal: true

module Lens
  # Derives the SKILL.md description from the cast body's own trigger clauses.
  #
  # The description is the primary triggering mechanism: agentskills.io says
  # it "should include specific keywords that help agents identify relevant
  # tasks", and every skill loader in the neighbourhood picks skills by it.
  # The trigger domains lens already extracted are sitting in each item's
  # "if X, have you Y?" clause, so read them back out instead of writing a
  # generic sentence that names nothing (#19). Deterministic, no second LLM
  # call, no prompt change; `--description` still overrides.
  module Description
    MAX = Validator::DESCRIPTION_MAX

    # The X in "MUST verify: if X, have you Y?". Non-greedy so a nested "if"
    # later in the item does not swallow the clause; the comma is optional
    # because the model sometimes drops it.
    TRIGGER = /\bif\s+(.+?),?\s+have you\b/im

    NOTE = "(Auto-generated from the checklist's trigger clauses; " \
           "override with --description for publication.)"

    module_function

    # Returns a description under MAX chars. Trigger phrases are appended in
    # body order until the cap would be exceeded; when nothing parses, the
    # name-and-framing fallback is returned unchanged.
    def derive(name:, body:, framing: nil)
      triggers = triggers(body)
      lead = "#{readable(name)} skill: a pre-response verification checklist. " \
             "Use when the conversation involves "
      tail = "#{framing_clause(framing)} #{NOTE}"

      until triggers.empty?
        candidate = "#{lead}#{triggers.join('; ')}.#{tail}"
        return candidate if candidate.length <= MAX

        triggers.pop
      end

      fallback(name, framing)
    end

    # Trigger phrases in body order, whitespace-squished, markdown emphasis
    # and trailing punctuation dropped, de-duplicated case-insensitively.
    def triggers(body)
      Checklist.score(body).items
               .filter_map { |item| clause(item.text) }
               .uniq(&:downcase)
    end

    # The pre-#19 description: names the skill and the framing, nothing about
    # what the checklist covers. Kept as the floor for bodies with no
    # parseable trigger clause.
    def fallback(name, framing)
      "#{readable(name)} skill: a pre-response verification checklist applied " \
        "when the user's conversation falls within the trigger conditions of " \
        "any listed item.#{framing_clause(framing)} #{NOTE}"
    end

    def clause(text)
      raw = text.match(TRIGGER)&.captures&.first or return nil
      phrase = raw.gsub(/[*_`]/, "").gsub(/\s+/, " ").strip.sub(/[[:punct:]]+\z/, "")
      phrase.empty? ? nil : phrase
    end

    def readable(name)
      name.split("-").map(&:capitalize).join(" ")
    end

    def framing_clause(framing)
      framing ? " Applies when the agent is acting as #{framing}." : ""
    end
    private_class_method :clause, :readable, :framing_clause
  end
end
