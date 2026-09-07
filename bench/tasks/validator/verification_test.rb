# frozen_string_literal: true

$LOAD_PATH.unshift "/app/lib"
require "lens"
require "minitest/autorun"

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
