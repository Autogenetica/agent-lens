# frozen_string_literal: true

module Lens
  # Validates SKILL.md frontmatter values against the agentskills.io
  # specification (https://agentskills.io/specification) so a shaped lens
  # is publishable on first try.
  module Validator
    class InvalidName < StandardError; end
    class InvalidDescription < StandardError; end

    NAME_RE = /\A[a-z0-9]+(-[a-z0-9]+)*\z/.freeze
    NAME_MAX = 64
    DESCRIPTION_MAX = 1024

    # Per agentskills.io spec:
    #   - 1-64 characters
    #   - lowercase a-z, 0-9, and hyphens only
    #   - must not start or end with a hyphen
    #   - must not contain consecutive hyphens
    #   - must match the parent directory name (caller's responsibility)
    def self.validate_name!(name)
      raise InvalidName, "name is required" if name.nil? || name.empty?
      raise InvalidName, "name must be at most #{NAME_MAX} characters (#{name.length})" if name.length > NAME_MAX
      raise InvalidName, "name must be lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens (#{name.inspect})" unless NAME_RE.match?(name)
    end

    # Per agentskills.io spec: 1-1024 characters, non-empty.
    def self.validate_description!(description)
      raise InvalidDescription, "description is required" if description.nil?
      stripped = description.strip
      raise InvalidDescription, "description is empty" if stripped.empty?
      raise InvalidDescription, "description must be at most #{DESCRIPTION_MAX} characters (#{description.length})" if description.length > DESCRIPTION_MAX
    end
  end
end
