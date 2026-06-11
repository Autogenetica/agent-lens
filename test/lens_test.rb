# frozen_string_literal: true

require_relative "test_helper"

class LensVersionTest < Minitest::Test
  def test_has_a_version
    refute_nil Lens::VERSION
    assert_match(/\A\d+\.\d+\.\d+\z/, Lens::VERSION)
  end
end

class LensValidatorNameTest < Minitest::Test
  def test_accepts_valid_kebab_case_name
    Lens::Validator.validate_name!("ruby-rails-discipline")
  end

  def test_accepts_single_word
    Lens::Validator.validate_name!("microeconomics")
  end

  def test_rejects_uppercase
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!("Ruby-Rails")
    end
  end

  def test_rejects_leading_hyphen
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!("-ruby")
    end
  end

  def test_rejects_trailing_hyphen
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!("ruby-")
    end
  end

  def test_rejects_consecutive_hyphens
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!("ruby--rails")
    end
  end

  def test_rejects_underscores
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!("ruby_rails")
    end
  end

  def test_rejects_too_long_name
    too_long = "a" * 65
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!(too_long)
    end
  end

  def test_accepts_64_chars
    Lens::Validator.validate_name!("a" * 64)
  end

  def test_rejects_nil
    assert_raises(Lens::Validator::InvalidName) do
      Lens::Validator.validate_name!(nil)
    end
  end
end

class LensValidatorDescriptionTest < Minitest::Test
  def test_accepts_typical_description
    desc = "A skill that helps the agent apply specific principles when the user " \
           "is discussing pricing strategy."
    Lens::Validator.validate_description!(desc)
  end

  def test_accepts_at_max_length
    Lens::Validator.validate_description!("a" * 1024)
  end

  def test_rejects_over_max_length
    assert_raises(Lens::Validator::InvalidDescription) do
      Lens::Validator.validate_description!("a" * 1025)
    end
  end

  def test_rejects_empty
    assert_raises(Lens::Validator::InvalidDescription) do
      Lens::Validator.validate_description!("")
    end
  end

  def test_rejects_whitespace_only
    assert_raises(Lens::Validator::InvalidDescription) do
      Lens::Validator.validate_description!("   \n   ")
    end
  end

  def test_rejects_nil
    assert_raises(Lens::Validator::InvalidDescription) do
      Lens::Validator.validate_description!(nil)
    end
  end
end

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
