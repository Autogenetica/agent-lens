# Changelog

All notable changes to agent-lens will be documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the
project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- Ruby 4.0 is now the minimum supported version (`required_ruby_version`
  `>= 4.0.0`), matching the project charter. The gemspec previously accepted
  Ruby 3.2+ even though the bench and lockfile already assumed 4.0 (#4).
- `docs/PROVENANCE.md` now identifies the source corpus by basename plus a
  SHA-256 of its content instead of the absolute path typed at cast time.
  The hash pins the exact source wherever it lived; the path shipped the
  author's filesystem layout inside every published skill (#7).

## [0.1.0] — 2026-06-11

Initial release.

### Added

- `lens shape` accepts multiple files and directories. `Lens::Corpus.gather`
  expands directories to `*.md` / `*.markdown` / `*.txt`, concatenates with
  a per-file boundary marker, and `docs/PROVENANCE.md` records each file's
  basename, sha256 and size; the `source-corpus` frontmatter value becomes
  `first.md (+N files)`. A single file is byte-for-byte unchanged (#17).

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
