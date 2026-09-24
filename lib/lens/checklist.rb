# frozen_string_literal: true

module Lens
  # Scores a cast checklist body against the format Shape::EXTRACTION_PROMPT
  # demands: 10-15 numbered items, each opening with a short bold name,
  # carrying a "MUST verify:" marker, phrased as an "if X, have you Y?"
  # conditional, and citing no source.
  #
  # This is the format half of quality, and only that half. Whether item 7
  # faithfully reflects the source's position needs a reader. No I/O, no LLM:
  # Checklist parses a String and returns numbers, so the before/after that
  # WORLD.md's first Direction bullet demands has something to quote.
  #
  # Deliberately not part of Validator: the item format is lens's own
  # contract, not agentskills.io's (the spec puts no format restriction on
  # the body). Nothing here changes what `lens shape` writes.
  module Checklist
    COUNT_RANGE = (10..15)

    ITEM_START = /\A\s*(\d+)[.)]\s+/
    BOLD_NAME = /\A\s*(?:\d+[.)]\s+)?\*\*([^*\n]+?)\*\*/
    MUST_VERIFY = /\bMUST verify:/
    CONDITIONAL = /\bif\b.+?\bhave you\b/im
    # Citing the source by name or structure is what the prompt forbids.
    # Kept narrow: "the source" alone is common English, so require the
    # citation verbs/nouns the prompt itself uses.
    CITATION = /\b(?:the (?:source|author|book|chapter|text) (?:says|states|argues|notes|recommends|describes)|according to the (?:source|author|book|text)|(?:in|see) (?:chapter|section|part) \d+|\(\s*(?:chapter|section|p\.|pp\.)\s*\d)/i

    Item = Struct.new(:number, :name, :text, :bold_name, :must_verify, :conditional, :cites_source, keyword_init: true) do
      def conformant?
        bold_name && must_verify && conditional && !cites_source
      end
    end

    Result = Struct.new(:items, keyword_init: true) do
      def count = items.size
      def count_in_range? = COUNT_RANGE.cover?(count)
      def conformant_count = items.count(&:conformant?)
      def conformance_rate = count.zero? ? 0.0 : conformant_count.fdiv(count)
      def names = items.map(&:name).compact
      def conformant? = count_in_range? && conformant_count == count

      # Per-property miss counts, for the "what moved" line.
      def misses
        {
          bold_name: items.count { |i| !i.bold_name },
          must_verify: items.count { |i| !i.must_verify },
          conditional: items.count { |i| !i.conditional },
          cites_source: items.count(&:cites_source)
        }
      end

      def to_h
        { count: count, count_in_range: count_in_range?, conformant: conformant_count,
          conformance_rate: conformance_rate.round(3), misses: misses, names: names }
      end
    end

    module_function

    # Parses a body into items and scores each. Continuation lines belong to
    # the preceding item; text before the first numbered line is preamble
    # and is ignored (the prompt forbids it, but scoring the items is more
    # useful than refusing the body).
    def score(body)
      Result.new(items: split_items(body.to_s).map { |number, text| score_item(number, text) })
    end

    # Jaccard overlap of two name lists, case-insensitive. A crude run-to-run
    # stability signal: 1.0 means the same item names came back, 0.0 none.
    def name_overlap(names_a, names_b)
      a = names_a.map { |n| normalize(n) }.to_set
      b = names_b.map { |n| normalize(n) }.to_set
      return 1.0 if a.empty? && b.empty?

      (a & b).size.fdiv((a | b).size)
    end

    def split_items(body)
      items = []
      body.each_line do |line|
        if (m = line.match(ITEM_START))
          items << [m[1].to_i, line.sub(ITEM_START, "").rstrip]
        elsif items.any?
          items.last[1] = "#{items.last[1]}\n#{line.rstrip}"
        end
      end
      items
    end

    def score_item(number, text)
      name = text.match(BOLD_NAME)&.captures&.first&.strip
      Item.new(
        number: number,
        name: name,
        text: text,
        bold_name: !name.nil?,
        must_verify: MUST_VERIFY.match?(text),
        conditional: CONDITIONAL.match?(text),
        cites_source: CITATION.match?(text)
      )
    end

    def normalize(name)
      name.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip
    end
    private_class_method :split_items, :score_item, :normalize
  end
end
