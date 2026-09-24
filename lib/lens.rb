# frozen_string_literal: true

# Load order matters: Validator → Shape → SkillWriter → CLI.
# CLI's option-defaults reference Shape constants at class-definition time,
# so Shape must be loaded first.
require_relative "lens/version"
require_relative "lens/validator"
require_relative "lens/corpus"
require_relative "lens/shape"
require_relative "lens/skill_writer"
require_relative "lens/cli"

module Lens
end
