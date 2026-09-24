# frozen_string_literal: true

require "digest"

module Lens
  # Gathers one or more corpus paths into a single text the shaper reads,
  # while keeping a per-file record for provenance (#17).
  #
  # A single file is returned byte for byte — no marker, no trailer — so
  # every existing `lens shape FILE` invocation is untouched. With more than
  # one file, each file's content is preceded by a visible boundary marker
  # (`<!-- source file 2 of 5: models.md -->`) so the prompt sees where one
  # source ends and the next begins, and PROVENANCE.md can pin each file by
  # basename and sha256 instead of hashing an anonymous `cat` blob.
  #
  # Directories expand to their `*.md` / `*.markdown` / `*.txt` files, sorted
  # by path, non-recursively. Reads only; offline-testable.
  module Corpus
    EXTENSIONS = %w[.md .markdown .txt].freeze

    class Empty < ArgumentError; end
    class Missing < ArgumentError; end

    Entry = Struct.new(:path, :basename, :sha256, :bytes, keyword_init: true)

    module_function

    # Returns { text: String, files: [Entry, ...] }.
    def gather(paths)
      files = expand(Array(paths))
      raise Empty, "no corpus files found (looked for #{EXTENSIONS.join(', ')})" if files.empty?

      entries = files.map { |path| entry_for(path) }
      text = if files.size == 1
               File.read(files.first)
             else
               files.each_with_index.map do |path, i|
                 "#{marker(i + 1, files.size, File.basename(path))}\n#{ensure_trailing_newline(File.read(path))}"
               end.join("\n")
             end

      { text: text, files: entries }
    end

    # Expands directories to their corpus files (sorted by path). Plain files
    # are taken as given regardless of extension. Duplicates collapse.
    def expand(paths)
      paths.flat_map do |path|
        raise Missing, "Corpus file not found: #{path}" unless File.exist?(path)

        if File.directory?(path)
          Dir.children(path).sort
             .map { |child| File.join(path, child) }
             .select { |child| File.file?(child) && EXTENSIONS.include?(File.extname(child).downcase) }
        else
          [path]
        end
      end.uniq
    end

    def marker(index, total, basename)
      "<!-- source file #{index} of #{total}: #{basename} -->"
    end

    def entry_for(path)
      content = File.binread(path)
      Entry.new(
        path: path,
        basename: File.basename(path),
        sha256: Digest::SHA256.hexdigest(content),
        bytes: content.bytesize
      )
    end

    def ensure_trailing_newline(text)
      text.end_with?("\n") ? text : "#{text}\n"
    end
    private_class_method :entry_for, :ensure_trailing_newline
  end
end
