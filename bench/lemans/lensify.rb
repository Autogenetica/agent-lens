#!/usr/bin/env ruby
# frozen_string_literal: true

# lensify -- emit "lensed" variants of lemans task directories.
#
# lemans has no system-prompt knob: the agent reads `instruction.md` from the
# task dir and that file is the whole prompt. So the injection mechanism for
# an agent-lens skill is to write a copy of each task where instruction.md is
#
#     <original YAML frontmatter, untouched>
#     <lens SKILL.md body>
#     <separator>
#     <original instruction body>
#
# Everything else in the task dir (environment.patch, solution.patch,
# verification_test.rb, anything extra) is copied byte-for-byte. The
# frontmatter stays first because lemans parses task metadata from it, and the
# benchmark canary line must remain in every copy.
#
# The lens's own frontmatter (name/description/license/metadata) is dropped --
# that block is for skill discovery, not for the agent to read.
#
# Usage:
#   ruby bench/lemans/lensify.rb --lens bench/lemans/lens/SKILL.md \
#        --tasks ~/src/ai-evals/tasks --out bench/lemans/tasks [TASK ...]
#
# With no TASK names every directory under --tasks is lensed. Run the baseline
# and the lensed set as two separate benches so task names line up per trial.

require "fileutils"
require "optparse"

module Lensify
  FRONTMATTER = /\A---\s*\n.*?\n---\s*\n/m
  SEPARATOR = "\n\n---\n\n<!-- lens: end of pre-response checklist; task follows -->\n\n"

  Options = Struct.new(:lens, :tasks, :out, :names, :force, keyword_init: true)

  # Split a markdown file into [frontmatter, body]; frontmatter is "" if absent.
  def self.split_frontmatter(text)
    m = FRONTMATTER.match(text)
    m ? [m[0], text[m[0].length..]] : ["", text]
  end

  # The lens body with its own frontmatter stripped and whitespace trimmed.
  def self.lens_body(skill_text)
    _, body = split_frontmatter(skill_text)
    body.strip
  end

  # Compose the lensed instruction: task frontmatter first, then lens, then task.
  def self.compose(instruction_text, lens_text)
    fm, body = split_frontmatter(instruction_text)
    "#{fm}#{lens_body(lens_text)}#{SEPARATOR}#{body.lstrip}"
  end

  # Write the lensed copy of one task dir. Returns the destination path.
  def self.lensify_task(src, dst, lens_text, force: false)
    instruction = File.join(src, "instruction.md")
    raise ArgumentError, "#{src}: no instruction.md" unless File.file?(instruction)
    raise ArgumentError, "#{dst}: exists (pass --force to overwrite)" if File.exist?(dst) && !force

    FileUtils.rm_rf(dst) if force
    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.cp_r(src, dst)
    File.write(File.join(dst, "instruction.md"), compose(File.read(instruction), lens_text))
    dst
  end

  def self.parse(argv)
    opts = Options.new(names: [], force: false)
    parser = OptionParser.new do |o|
      o.banner = "usage: lensify.rb --lens SKILL.md --tasks DIR --out DIR [--force] [TASK ...]"
      o.on("--lens PATH", "shaped SKILL.md to inject") { |v| opts.lens = v }
      o.on("--tasks DIR", "source lemans tasks directory") { |v| opts.tasks = v }
      o.on("--out DIR", "destination directory for lensed tasks") { |v| opts.out = v }
      o.on("--force", "overwrite existing lensed task dirs") { opts.force = true }
    end
    opts.names = parser.parse(argv)
    missing = %i[lens tasks out].reject { |k| opts[k] }
    abort(parser.help) unless missing.empty?
    opts
  end

  def self.run(argv, io: $stdout)
    opts = parse(argv)
    lens_text = File.read(opts.lens)
    names = opts.names.empty? ? Dir.children(opts.tasks).sort : opts.names
    names.each do |name|
      src = File.join(opts.tasks, name)
      next unless File.directory?(src)
      dst = lensify_task(src, File.join(opts.out, name), lens_text, force: opts.force)
      io.puts "lensed #{name} -> #{dst}"
    end
    io.puts "#{names.size} task(s), lens #{File.basename(File.dirname(opts.lens))}/#{File.basename(opts.lens)} (#{lens_body(lens_text).lines.size} lines)"
  end
end

Lensify.run(ARGV) if __FILE__ == $PROGRAM_NAME
