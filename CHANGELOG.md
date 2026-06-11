# Changelog

All notable changes to agent-lens will be documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the
project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] — 2026-06-11

Initial release.

### Added

- `lens shape CORPUS_PATH` — single subcommand that reads an opinionated
  corpus (book, course transcript, codebase canonical files, internal SOP),
  calls a single LLM completion (Sonnet 4.6 by default), and writes an
  agentskills.io-compliant Agent Skill directory.
- Spec validation against the agentskills.io constraints (name format
  + length, description ≤ 1024 chars) before writing.
- Auto-generated `docs/PROVENANCE.md` documenting source corpus, model,
  framing, and lens-cast timestamp for each shaped skill.
- `lens version` subcommand.

### Pipeline provenance

The extraction prompt and framing discipline come from the validated
single-call pipeline of the
[agent training program](https://github.com/codenamev/agent-training-program)
(Claims 7-12 in `docs/THESIS.md`). The pipeline has been empirically
validated on books (Ruby/Rails: Metz/Grimm/Masilotti), MIT OCW courses
(6.034 AI, 14.01 Microeconomics, 6.006 Algorithms), and internal codebases
(nowreading.dev) across both advisory and code-generation task layers.
