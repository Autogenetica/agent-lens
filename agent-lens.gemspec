# frozen_string_literal: true

require_relative "lib/lens/version"

Gem::Specification.new do |spec|
  spec.name        = "agent-lens"
  spec.version     = Lens::VERSION
  spec.authors     = ["Autogenetica"]
  spec.email       = ["v+autogenetica@codenamev.com"]

  spec.summary     = "Shape Agent Skills from opinionated corpora."
  spec.description = <<~DESC
    lens turns a corpus of opinionated content (a book, a course transcript,
    a codebase's canonical files, an internal SOP) into an agentskills.io-
    compliant Agent Skill that AI coding agents read before responding.
    Each shaped skill acts as one element in the agent's compound lens stack —
    a layered focus that shifts the agent's reasoning toward the source's
    specific positions.
  DESC

  spec.homepage    = "https://github.com/Autogenetica/agent-lens"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["bug_tracker_uri"]   = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb", "bin/lens", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.bindir      = "bin"
  spec.executables = ["lens"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby_llm", "~> 1.14"
  spec.add_dependency "dotenv",   "~> 3.0"
  spec.add_dependency "thor",     "~> 1.3"

  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "rake",     "~> 13.0"
end
