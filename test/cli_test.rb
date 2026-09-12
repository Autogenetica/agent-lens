# frozen_string_literal: true

require_relative "test_helper"
require "minitest/mock"
require "tmpdir"
require "fileutils"

# Exercises Lens::CLI without a network call. Everything up to Shape#cast is
# pure argument handling and short-circuits; the success path stubs
# Lens::Shape.new so the writer runs against a canned checklist body.
# The live extraction itself is a manual eval (bench/), not a test, per
# WORLD.md's offline-suite constraint.
class LensCLITest < Minitest::Test
  FAKE_BODY = "1. **Test item** — MUST verify: if testing, have you asserted something?"
  ENV_VAR = "LENS_CLI_TEST_VAR"

  FakeShaper = Struct.new(:body) do
    def cast
      body
    end
  end

  def setup
    @tmp = Dir.mktmpdir("lens-cli-test-")
    @corpus = File.join(@tmp, "corpus-notes.md")
    File.write(@corpus, "# Notes\n\nPrefer small objects over clever ones.\n")
    @output = File.join(@tmp, "shaped-skill")
    # Every shape invocation points --env-file at a private file so the test
    # never loads a developer's real ./.env into the process.
    @env_file = File.join(@tmp, "test.env")
    File.write(@env_file, "#{ENV_VAR}=from-env-file\n")
    ENV.delete(ENV_VAR)
  end

  def teardown
    ENV.delete(ENV_VAR)
    FileUtils.rm_rf(@tmp) if File.exist?(@tmp)
  end

  # Runs the CLI in-process. Returns [exit_status, stdout, stderr].
  # Thor's exit_on_failure? and the CLI's own `exit 1` both raise SystemExit.
  def run_cli(*args)
    status = 0
    out, err = capture_io do
      Lens::CLI.start(args)
    rescue SystemExit => e
      status = e.status
    end
    [status, out, err]
  end

  def shape_args(*extra)
    ["shape", @corpus, "--output", @output, "--name", "corpus-notes",
     "--env-file", @env_file, *extra]
  end

  # Stubs Lens::Shape.new for the block; yields the kwargs it was called with.
  def with_fake_shaper
    received = nil
    factory = lambda do |**kwargs|
      received = kwargs
      FakeShaper.new(FAKE_BODY)
    end
    Lens::Shape.stub(:new, factory) { yield }
    received
  end

  def test_version_prints_gem_name_and_version
    status, out, = run_cli("version")

    assert_equal 0, status
    assert_equal "agent-lens #{Lens::VERSION}\n", out
  end

  def test_shape_requires_output_and_name
    status, _out, err = run_cli("shape", @corpus, "--env-file", @env_file)

    assert_equal 1, status
    assert_match(/required options/, err)
    assert_match(/--output/, err)
    assert_match(/--name/, err)
  end

  def test_shape_exits_1_when_corpus_missing
    missing = File.join(@tmp, "nope.md")
    status, out, = run_cli("shape", missing, "--output", @output,
                           "--name", "corpus-notes", "--env-file", @env_file)

    assert_equal 1, status
    assert_match(/Corpus file not found: #{Regexp.escape(missing)}/, out)
    refute File.exist?(@output), "should not create the output dir"
  end

  def test_shape_rejects_invalid_name_before_shaping
    calls = 0
    Lens::Shape.stub(:new, ->(**) { calls += 1 }) do
      status, out, = run_cli("shape", @corpus, "--output", @output,
                             "--name", "Bad_Name", "--env-file", @env_file)

      assert_equal 1, status
      assert_match(/Invalid skill metadata: name must be/, out)
    end

    assert_equal 0, calls, "Shape.new must not run for an invalid name"
    refute File.exist?(@output)
  end

  def test_shape_rejects_over_long_description_after_shaping
    with_fake_shaper do
      status, out, = run_cli(*shape_args("--description", "a" * 1025))

      assert_equal 1, status
      assert_match(/Invalid skill metadata: description must be at most 1024/, out)
    end

    refute File.exist?(File.join(@output, "SKILL.md"))
  end

  def test_shape_writes_skill_and_provenance_from_extracted_body
    received = with_fake_shaper do
      status, out, = run_cli(*shape_args("--framing", "a test pilot",
                                         "--license", "MIT"))

      assert_equal 0, status
      assert_match(/reading\s+#{Regexp.escape(@corpus)} \(\d+ chars\)/, out)
      assert_match(/wrote\s+#{Regexp.escape(File.join(@output, 'SKILL.md'))}/, out)
      assert_match(%r{wrote\s+#{Regexp.escape(File.join(@output, 'docs', 'PROVENANCE.md'))}}, out)
      assert_match(/Shaped corpus-notes from corpus-notes\.md\./, out)
    end

    assert_equal File.read(@corpus), received[:corpus]
    assert_equal "a test pilot", received[:framing]
    assert_equal Lens::Shape::DEFAULT_MODEL, received[:model]

    skill = File.read(File.join(@output, "SKILL.md"))
    assert_match(/^name: corpus-notes$/, skill)
    assert_match(/^license: "MIT"$/, skill)
    assert_match(/^  model: "#{Regexp.escape(Lens::Shape::DEFAULT_MODEL)}"$/, skill)
    assert_includes skill, FAKE_BODY

    provenance = File.read(File.join(@output, "docs", "PROVENANCE.md"))
    assert_match(/Provenance — corpus-notes/, provenance)
    assert_match(/\*\*Framing:\*\* `a test pilot`/, provenance)
  end

  def test_shape_passes_model_option_through
    received = with_fake_shaper do
      run_cli(*shape_args("--model", "some-other-model"))
    end

    assert_equal "some-other-model", received[:model]
    assert_match(/^  model: "some-other-model"$/, File.read(File.join(@output, "SKILL.md")))
  end

  def test_shape_derives_description_from_name_and_framing
    with_fake_shaper { run_cli(*shape_args("--framing", "a test pilot")) }

    skill = File.read(File.join(@output, "SKILL.md"))
    description = skill[/^description: "(.*)"$/, 1]

    refute_nil description
    assert_match(/\ACorpus Notes skill/, description)
    assert_includes description, "acting as a test pilot"
    assert_includes description, "Auto-generated description"
    assert_operator description.length, :<=, Lens::Validator::DESCRIPTION_MAX
  end

  def test_shape_derived_description_falls_back_without_framing
    with_fake_shaper { run_cli(*shape_args) }

    description = File.read(File.join(@output, "SKILL.md"))[/^description: "(.*)"$/, 1]

    assert_includes description, "acting as the relevant domain"
  end

  def test_shape_uses_explicit_description_verbatim
    with_fake_shaper do
      run_cli(*shape_args("--description", "Hand-written description."))
    end

    assert_match(/^description: "Hand-written description\."$/,
                 File.read(File.join(@output, "SKILL.md")))
  end

  def test_shape_loads_env_file_option
    with_fake_shaper { run_cli(*shape_args) }

    assert_equal "from-env-file", ENV.fetch(ENV_VAR, nil)
  end

  def test_shape_loads_dot_env_from_cwd_by_default
    File.write(File.join(@tmp, ".env"), "#{ENV_VAR}=from-cwd-dot-env\n")

    Dir.chdir(@tmp) do
      with_fake_shaper do
        run_cli("shape", @corpus, "--output", @output, "--name", "corpus-notes")
      end
    end

    assert_equal "from-cwd-dot-env", ENV.fetch(ENV_VAR, nil)
  end

  def test_shape_tolerates_missing_env_file
    status, out, = run_cli("shape", File.join(@tmp, "nope.md"), "--output", @output,
                           "--name", "corpus-notes",
                           "--env-file", File.join(@tmp, "absent.env"))

    # Reaches the corpus check, so the env-file miss itself did not raise.
    assert_equal 1, status
    assert_match(/Corpus file not found/, out)
  end
end
