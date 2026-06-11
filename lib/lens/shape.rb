# frozen_string_literal: true

require "ruby_llm"

module Lens
  # The core extraction step. Takes a corpus + framing context, calls a
  # single LLM completion, returns the body of an RFC-2119 verification
  # checklist suitable for embedding in a SKILL.md.
  #
  # The prompt is the validated form from Claims 7–12 of the parent
  # research project (single-call extraction with broad-trigger
  # conditional discipline). The framing parameter is the lever
  # Claim 9 / Claim 12 identified as the per-task-layer focus knob.
  class Shape
    DEFAULT_MODEL = "claude-sonnet-4-6"
    DEFAULT_FRAMING = "a domain advisor in multi-turn conversations"

    EXTRACTION_PROMPT = <<~PROMPT
      You are extracting a pre-response verification checklist from a source corpus.
      The checklist will be injected into an agent's system context to help it apply
      the source's specific positions consistently. The agent operates as #{'%FRAMING%'}.

      Read the source carefully. Identify the key actionable principles the source
      takes a specific position on — things the agent should verify it has done
      before responding to a user on relevant topics.

      Output format: a numbered list of 10-15 RFC-2119 MUST-verify items. Each item
      must:
        - Start with a short bold name (e.g., **Premature abstraction guard**)
        - Use "MUST verify:" followed by a conditional ("if X, have you Y?")
        - Be self-contained — do NOT reference the source by name or section
        - Be principle-grounded — name a specific behavior the agent should check
        - Be applicable in a multi-turn context for the operating role above

      ## Critical: trigger-condition breadth

      The "if X" conditional in each item determines when the agent is reminded
      of the principle. Write triggers that fire on the **type of conversation**
      the user is having, NOT on literal properties they happen to mention.

      - TOO LITERAL (bad): "if the user mentions subscriptions, verify churn"
        (fires only when the literal property is named)
      - BROADER (good): "if the user is discussing pricing, business model, or
        recurring revenue, verify churn analysis"
        (fires whenever the conversation enters relevant territory)

      Cover the topical/situational contexts where each principle matters, not
      just the surface attribute that technically triggers it.

      Output only the numbered list. No preamble, no source citations, no closing
      summary. Do NOT include any YAML frontmatter — that is handled separately.

      ## Source

      #{'%SOURCE%'}
    PROMPT

    def initialize(corpus:, framing: DEFAULT_FRAMING, model: DEFAULT_MODEL)
      @corpus = corpus
      @framing = framing || DEFAULT_FRAMING
      @model = model
      configure_llm
    end

    # Returns the raw extracted checklist body as a String.
    def cast
      response = chat.ask(build_prompt)
      content = response.content.to_s.strip
      raise "Empty extraction response from #{@model}" if content.empty?
      content
    end

    private

    def build_prompt
      EXTRACTION_PROMPT
        .sub("%FRAMING%", @framing.to_s)
        .sub("%SOURCE%", @corpus.to_s)
    end

    def chat
      @chat ||= RubyLLM.chat(model: @model)
    end

    def configure_llm
      RubyLLM.configure do |c|
        c.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
        c.request_timeout = 300
        c.max_retries = 5
        c.retry_interval = 2
        c.retry_backoff_factor = 2
      end
    end
  end
end
