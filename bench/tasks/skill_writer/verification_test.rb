# frozen_string_literal: true

$LOAD_PATH.unshift "/app/lib"
require "lens"
require "minitest/autorun"
require "tmpdir"
require "fileutils"

class LensSkillWriterTest < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir("lens-skill-writer-test-")
    @output_dir = File.join(@tmp_dir, "test-skill")
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir) if File.exist?(@tmp_dir)
  end

  def test_writes_skill_md_and_provenance
    writer = Lens::SkillWriter.new(
      output_dir: @output_dir,
      name: "test-skill",
      description: "A test skill for verifying the writer produces valid agentskills.io output. Use this skill whenever testing.",
      body: "1. **Test item** — MUST verify: if testing, have you asserted something?",
      license: "MIT",
      framing: "a test runner",
      source_path: "/path/to/source.md",
      model: "claude-sonnet-4-6"
    )

    paths = writer.write

    assert File.exist?(paths[:skill_path]), "SKILL.md should exist"
    assert File.exist?(paths[:provenance_path]), "PROVENANCE.md should exist"

    skill_content = File.read(paths[:skill_path])
    assert_match(/^---$/, skill_content, "should have YAML frontmatter")
    assert_match(/^name: test-skill$/, skill_content)
    assert_match(/^description: "/, skill_content)
    assert_match(/\*\*Test item\*\*/, skill_content, "should include body")

    provenance = File.read(paths[:provenance_path])
    assert_match(/Provenance — test-skill/, provenance)
    assert_match(%r{/path/to/source\.md}, provenance)
  end

  def test_rejects_invalid_name_at_write_time
    writer = Lens::SkillWriter.new(
      output_dir: @output_dir,
      name: "Invalid_Name",
      description: "valid description",
      body: "body"
    )
    assert_raises(Lens::Validator::InvalidName) { writer.write }
  end
end
