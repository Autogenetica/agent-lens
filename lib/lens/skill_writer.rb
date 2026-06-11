# frozen_string_literal: true

require "fileutils"
require "time"

module Lens
  # Writes the shaped lens to disk as an agentskills.io-compliant Agent Skill
  # directory. Generates the YAML frontmatter, embeds the extracted checklist
  # body, and writes a provenance record documenting how the lens was cast.
  class SkillWriter
    HEADER = <<~HEADER
      Before responding to the user, internally verify each applicable item
      below. These are pre-response checks — if the condition applies to the
      conversation, confirm you have addressed the principle before sending
      your answer. Cite the item by its short bold name when an answer turns
      on it (e.g., *"Per **<item name>**, I'd suggest..."*).
    HEADER

    def initialize(output_dir:, name:, description:, body:, license: "Pending review", framing: nil, source_path: nil, model: nil)
      @output_dir = output_dir
      @name = name
      @description = description
      @body = body
      @license = license
      @framing = framing
      @source_path = source_path
      @model = model
    end

    def write
      Validator.validate_name!(@name)
      Validator.validate_description!(@description)

      FileUtils.mkdir_p(@output_dir)
      skill_path = File.join(@output_dir, "SKILL.md")
      File.write(skill_path, render_skill_md)

      docs_dir = File.join(@output_dir, "docs")
      FileUtils.mkdir_p(docs_dir)
      provenance_path = File.join(docs_dir, "PROVENANCE.md")
      File.write(provenance_path, render_provenance)

      { skill_path: skill_path, provenance_path: provenance_path }
    end

    private

    def render_skill_md
      <<~MD
        ---
        name: #{@name}
        description: #{yaml_escape(@description)}
        license: #{yaml_escape(@license)}
        metadata:
          shaped-by: "agent-lens v#{Lens::VERSION}"
          shaped-at: "#{Time.now.utc.iso8601}"
          source-corpus: #{yaml_escape(source_basename)}
          model: #{yaml_escape(@model || "unknown")}
        ---

        # #{title_case(@name)}

        #{HEADER.strip}

        ---

        #{@body.strip}
      MD
    end

    def render_provenance
      <<~MD
        # Provenance — #{@name}

        - **Shaped by:** [agent-lens](https://github.com/Autogenetica/agent-lens) v#{Lens::VERSION}
        - **Shaped at:** #{Time.now.utc.iso8601}
        - **Source corpus:** `#{@source_path || "(unknown)"}`
        - **Model:** `#{@model || "unknown"}`
        - **Framing:** #{@framing ? "`#{@framing}`" : "(default)"}

        ## How this lens was cast

        A single LLM completion read the source corpus and produced a 10–15 item
        RFC-2119 pre-response verification checklist. Each item names a specific
        behavior the agent should verify before responding to a user whose
        conversation falls within its trigger conditions.

        The extraction prompt and operating discipline come from the
        [agent training program](https://github.com/codenamev/agent-training-program)'s
        validated single-call pipeline (Claims 7–12 in `docs/THESIS.md`).

        ## Review status

        First-pass auto-cast. Human review pass is recommended before
        distribution — check for faithfulness to the source, completeness of
        coverage, and trigger-condition breadth.
      MD
    end

    def source_basename
      return "unknown" if @source_path.nil?
      File.basename(@source_path.to_s)
    end

    def title_case(slug)
      slug.split("-").map(&:capitalize).join(" ")
    end

    # YAML-safe quoting for description and other string values. Uses
    # double-quoted style and escapes embedded double quotes/backslashes.
    def yaml_escape(value)
      s = value.to_s
      escaped = s.gsub("\\", "\\\\").gsub('"', '\\"')
      %("#{escaped}")
    end
  end
end
