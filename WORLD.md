# WORLD.md — project charter

This file sets direction for agent-lens: what it exists to do, what it will
not become, and how proposed work gets judged. The maintainer (codenamev,
through the Autogenetica org) owns it. Minerva (minerva-sky), an autonomous
agent that helps maintain this project, reads this document before proposing
anything and stays inside its fences. If a proposal conflicts with this file,
the proposal is wrong.

Status: PROPOSED. Drafted 2026-09-03, awaiting maintainer approval.

## Purpose

A small Ruby CLI that turns one opinionated corpus (a book, a course
transcript, a codebase's canonical files, an internal SOP) into one
agentskills.io-compliant Agent Skill: a SKILL.md of RFC-2119 items an AI
coding agent reads before responding, plus a PROVENANCE.md that says where
the items came from. The pipeline is a single LLM call with a validated
framing. The source author stays the irreducible expert input; lens
automates the distillation and nothing else.

## Direction

- The extraction prompt is the product. It was validated across books, MIT
  OCW courses, and a production Rails codebase (agent training program,
  THESIS.md claims 7-12). A change to the prompt or framing earns its place
  with a before/after on at least one of those corpora, and the proposal
  says what moved.
- Provenance is a feature, not a courtesy. Every shaped skill records its
  source, model, framing, and timestamp. Anything that weakens that record
  is a regression.
- Spec compliance is non-negotiable. Output validates against agentskills.io
  constraints before it is written. When the spec moves, lens moves with it.
- The README's "what lens does NOT do (yet)" list is the roadmap, in this
  order: multi-file corpora, then quality eval and re-cast, then composition
  of several corpora into one lens. PDF and EPUB extraction stay upstream in
  the agent training program's pre-processors. Auto-publishing to a
  marketplace stays off the list entirely.
- Each module does one thing (Shape, Validator, SkillWriter). New capability
  arrives as a new module alongside them, not as a branch inside an existing
  one.

## Constraints

- The test suite runs offline. No network, no API key, no live model call in
  tests. Anything that needs a real completion is a manual eval script, not
  a test.
- Three runtime dependencies (ruby_llm, dotenv, thor). Adding a fourth needs
  a reason the existing three cannot cover.
- Ruby 3.2 is the floor. Raising it is the maintainer's call.
- The gem is not yet published to rubygems.org. Versions, CHANGELOG release
  headings, and `gem push` are the maintainer's alone. The agent never
  publishes, tags, or releases.
- There is no CI yet. The first automation this repo needs is a test run
  across the supported Rubies with no secrets in the environment.
- Keys stay in `.env`, ignored by git, never in fixtures or examples beyond
  the placeholder in `.env.example`.
- Review budget: the maintainer reviews at most one pull request a week from
  this repo. Proposals beyond that wait as issues.

## Anti-goals

- Not a general prompt-engineering toolkit. One corpus in, one skill out.
- Not a marketplace and not a publisher. Drop the output directory where
  your harness wants it; lens does not upload anything.
- Not a provider abstraction. ruby_llm already is one; lens does not wrap
  it again.
- Not an agent and not a runtime. It shapes skills; it does not run them.
- Not the home of the thesis. Methodology, claims, and evaluation data live
  in the agent training program. This repo links to them and does not copy
  them.
- No telemetry. lens sends the corpus to the configured model and nothing
  anywhere else.

## How work gets proposed

Improvements arrive as GitHub issues, labeled by origin and state:

- Origin: `loop:quality`, `loop:security`, `loop:deps`, `loop:research`,
  `loop:self` (agent-originated), or unlabeled (human-originated).
- State: `status:analyzed`, `status:deferred`, `status:wont-do`,
  `status:blocked`. A closed issue with `status:wont-do` records the reason in
  its final comment and is permanent institutional memory. Proposals must check
  closed and deferred issues before re-raising an idea.

## Review policy

Changes are classed by risk (external visibility times reversibility), and each
class has an autonomy level that can rise as the agent's track record earns it:

- L0: propose in an issue only.
- L1: open a PR; the maintainer merges.
- L2: open a PR; it may merge after a 72-hour quiet period with green CI.
- L3: merge on green CI, reported in a digest.

Every class starts at L0 or L1. Promotions happen only on the maintainer's
explicit approval, backed by the acceptance record. Any revert demotes the
class immediately. The extraction prompt, the default model, and anything
touching the gemspec or release process stay at L0.

## Amending this document

By pull request with maintainer approval, nothing else. The agent may propose
amendments; it may never merge them.
