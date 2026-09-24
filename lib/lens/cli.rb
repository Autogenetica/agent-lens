# frozen_string_literal: true

require "digest"
require "thor"
require "dotenv"

module Lens
  # Top-level command-line interface for `lens`. Subcommand-based so each
  # action stays focused.
  #
  #   lens shape CORPUS --output DIR --name NAME [options]
  #
  # The Thor convention keeps the surface area small while leaving room
  # for future subcommands (`lens validate`, `lens stack`, `lens cast` for
  # alternative input types) without breaking the existing CLI shape.
  class CLI < Thor
    package_name "lens"

    def self.exit_on_failure?
      true
    end

    desc "version", "Print the agent-lens version"
    def version
      puts "agent-lens #{Lens::VERSION}"
    end

    desc "shape CORPUS_PATH [CORPUS_PATH...]",
         "Shape an Agent Skill from a corpus of opinionated content"
    long_desc <<~LONGDESC
      Shape an agentskills.io-compliant Agent Skill from a corpus.

      The corpus can be any text or markdown file — a book chapter, a course
      transcript, a codebase's canonical pattern files concatenated together,
      an internal SOP. Lens reads the corpus, calls a single LLM completion
      to extract a 10-15 item RFC-2119 verification checklist, and writes
      the result as a publishable Agent Skill directory.

      Example:

        lens shape ~/Books/99-bottles-of-oop.md \\
          --output ./skills/ruby-rails-discipline \\
          --name ruby-rails-discipline \\
          --framing "a senior Ruby/Rails engineer reviewing or refactoring code"

      The output directory will contain a valid SKILL.md plus a docs/PROVENANCE.md
      documenting how the lens was cast. Both are agentskills.io-compliant.
    LONGDESC
    option :output, type: :string, required: true, aliases: "-o",
                    desc: "Output directory for the shaped skill"
    option :name, type: :string, required: true, aliases: "-n",
                  desc: "Skill name (kebab-case, becomes the SKILL.md name: field)"
    option :description, type: :string, aliases: "-d",
                         desc: "Override the auto-generated description (max 1024 chars)"
    option :framing, type: :string, aliases: "-f",
                     desc: "Operating-context phrase for the agent (e.g. 'a senior Ruby engineer reviewing code')"
    option :license, type: :string, default: "Pending review",
                     desc: "License string for the SKILL.md license field"
    option :model, type: :string, default: Shape::DEFAULT_MODEL,
                   desc: "LLM model to use for extraction"
    option :env_file, type: :string,
                      desc: "Path to a .env file to load (defaults to ./.env)"
    def shape(*corpus_paths)
      load_env(options[:env_file])

      if corpus_paths.empty?
        say_error "Usage: lens shape CORPUS_PATH [CORPUS_PATH...] --output DIR --name NAME"
        exit 1
      end

      Validator.validate_name!(options[:name])

      gathered = Corpus.gather(corpus_paths)
      corpus = gathered[:text]
      files = gathered[:files]
      if files.size == 1
        say_status :reading, "#{files.first.path} (#{corpus.length} chars)"
      else
        say_status :reading, "#{files.size} files (#{corpus.length} chars)"
        files.each { |f| say_status :file, "#{f.path} (#{f.bytes} bytes)" }
      end

      shaper = Shape.new(
        corpus: corpus,
        framing: options[:framing],
        model: options[:model]
      )

      say_status :shaping, "single-call extraction with #{options[:model]} (this may take 30–90s)"
      body = shaper.cast

      description = options[:description] || derive_description(options[:name], options[:framing])
      Validator.validate_description!(description)

      writer = SkillWriter.new(
        output_dir: options[:output],
        name: options[:name],
        description: description,
        body: body,
        license: options[:license],
        framing: options[:framing],
        source_path: files.first.path,
        source_sha256: files.first.sha256,
        source_files: files,
        model: options[:model]
      )

      paths = writer.write
      say_status :wrote, paths[:skill_path]
      say_status :wrote, paths[:provenance_path]
      say ""
      say "Shaped #{options[:name]} from #{files.size == 1 ? files.first.basename : "#{files.size} files"}."
      say "Next: review the SKILL.md body for faithfulness, then publish to a"
      say "marketplace or drop into ~/.claude/skills/#{options[:name]}/ to load locally."
    rescue Validator::InvalidName, Validator::InvalidDescription => e
      say_error "Invalid skill metadata: #{e.message}"
      exit 1
    rescue Corpus::Missing, Corpus::Empty => e
      say_error e.message
      exit 1
    end

    private

    def load_env(path)
      env_file = path || File.expand_path(".env", Dir.pwd)
      Dotenv.load(env_file) if File.exist?(env_file)
    end

    # Default description used when --description isn't provided. Kept short
    # and safely under the 1024-char cap; user should override for production
    # skills they intend to publish.
    def derive_description(name, framing)
      readable = name.split("-").map(&:capitalize).join(" ")
      context = framing || "the relevant domain"
      "#{readable} skill — a pre-response verification checklist applied when " \
        "the user's conversation falls within the trigger conditions of any " \
        "listed item. Use this skill whenever the agent is acting as #{context}, " \
        "even when the user doesn't name the underlying patterns explicitly. " \
        "(Auto-generated description; override with --description for publication.)"
    end

    def say_status(status, message)
      say format("  %12s  %s", status, message), :green
    end

    def say_error(message)
      say message, :red
    end
  end
end
