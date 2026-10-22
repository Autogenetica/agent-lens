# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "fileutils"
require "digest"

class LensCorpusTest < Minitest::Test
  def setup
    @tmp = Dir.mktmpdir("lens-corpus-test-")
    @a = write("a.md", "# A\n\nAlpha.\n")
    @b = write("b.txt", "Bravo without trailing newline")
    @dir = File.join(@tmp, "patterns")
    FileUtils.mkdir_p(@dir)
    @d2 = write("patterns/02-second.md", "second\n")
    @d1 = write("patterns/01-first.markdown", "first\n")
    write("patterns/ignored.rb", "puts 1\n")
    FileUtils.mkdir_p(File.join(@dir, "nested"))
    write("patterns/nested/deep.md", "deep\n")
  end

  def teardown
    FileUtils.rm_rf(@tmp)
  end

  def write(rel, content)
    path = File.join(@tmp, rel)
    File.write(path, content)
    path
  end

  def test_single_file_is_byte_for_byte_and_unmarked
    result = Lens::Corpus.gather([@b])

    assert_equal File.read(@b), result[:text]
    assert_equal 1, result[:files].size
    assert_equal "b.txt", result[:files].first.basename
    assert_equal Digest::SHA256.file(@b).hexdigest, result[:files].first.sha256
  end

  def test_multiple_files_get_boundary_markers_in_given_order
    result = Lens::Corpus.gather([@b, @a])

    expected = "<!-- source file 1 of 2: b.txt -->\nBravo without trailing newline\n\n" \
               "<!-- source file 2 of 2: a.md -->\n# A\n\nAlpha.\n"
    assert_equal expected, result[:text]
    assert_equal %w[b.txt a.md], result[:files].map(&:basename)
  end

  def test_per_file_sha256_and_bytes
    result = Lens::Corpus.gather([@a, @b])
    a, b = result[:files]

    assert_equal Digest::SHA256.file(@a).hexdigest, a.sha256
    assert_equal File.size(@a), a.bytes
    assert_equal Digest::SHA256.file(@b).hexdigest, b.sha256
    refute_equal a.sha256, b.sha256
  end

  def test_directory_expands_to_sorted_corpus_files_non_recursively
    result = Lens::Corpus.gather([@dir])

    assert_equal %w[01-first.markdown 02-second.md], result[:files].map(&:basename)
    assert_includes result[:text], "<!-- source file 1 of 2: 01-first.markdown -->"
    refute_includes result[:text], "deep"
    refute_includes result[:text], "puts 1"
  end

  def test_mixed_directory_and_file_and_duplicates_collapse
    result = Lens::Corpus.gather([@a, @dir, @a])

    assert_equal %w[a.md 01-first.markdown 02-second.md], result[:files].map(&:basename)
  end

  def test_missing_path_raises
    assert_raises(Lens::Corpus::Missing) { Lens::Corpus.gather([File.join(@tmp, "nope.md")]) }
  end

  def test_empty_directory_raises
    empty = File.join(@tmp, "empty")
    FileUtils.mkdir_p(empty)

    assert_raises(Lens::Corpus::Empty) { Lens::Corpus.gather([empty]) }
  end
end
