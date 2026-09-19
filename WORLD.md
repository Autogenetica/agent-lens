# WORLD.md: agent-lens, answered six ways

This file sets direction for agent-lens: what it exists to do, what it will
not become, and how proposed work gets judged. The maintainer (codenamev,
through the Autogenetica org) owns it. Minerva (minerva-sky), an autonomous
agent that helps maintain this project, reads this document before proposing
anything and stays inside its fences. If a proposal conflicts with this file,
the proposal is wrong.

Status: PROPOSED. Drafted 2026-09-03 as a seven-section charter. Restructured
2026-09-19 under the six headings every repo in the fleet now shares, so a loop
session or a portfolio pass finds the same answer in the same place in every
repo. Awaiting maintainer approval.

## VISION (where we hope this goes)

<!-- VAL: edit. Drafted from the old Purpose and Direction sections; the charter said what lens does and which way it leans, never where it ends up. -->

An author hands lens the thing they know best and gets back a skill their
coding agent will actually obey: RFC-2119 items, every one traceable to a
page. The expert stays the expert. The distillation stops being an afternoon
of prompt-wrangling and becomes one command. Not a prompt toolkit, not a
marketplace. A lens: one corpus in, one focused thing out, and you can see
where the light came from.

## MISSION (what we're here to do)

A small Ruby CLI that turns one opinionated corpus (a book, a course
transcript, a codebase's canonical files, an internal SOP) into one
agentskills.io-compliant Agent Skill: a SKILL.md of RFC-2119 items an AI
coding agent reads before responding, plus a PROVENANCE.md that says where
the items came from. The pipeline is a single LLM call with a validated
framing. The source author stays the irreducible expert input; lens
automates the distillation and nothing else.

## CONSTITUTION (what rules we must obey)

The fleet's shared rules live in one place and this file links to them rather
than pasting: the [operator's constitution](https://github.com/minerva-sky/workspace/blob/master/WORLD.md#constitution-what-rules-we-must-obey).
That covers the autonomy ladder (L0 propose in an issue, L1 open a PR the
maintainer merges, L2 merge after a quiet period on green CI, L3 merge on green
CI and report in a digest), how a class gets promoted (maintainer approval on
the acceptance record) and demoted (any revert, immediately), and the rule that
gem releases and version bumps are the maintainer's alone.

Local additions for agent-lens:

- The extraction prompt is the product. A change to the prompt or framing
  earns its place with a before/after on real source material, and the
  proposal says what moved.
- Provenance is a feature, not a courtesy. Every shaped skill records its
  source, model, framing, and timestamp. Anything that weakens that record
  is a regression.
- Spec compliance is non-negotiable. Output validates against agentskills.io
  constraints before it is written. When the spec moves, lens moves with it.
- The test suite runs offline. No network, no API key, no live model call in
  tests. Anything that needs a real completion is a manual eval script, not
  a test.
- Three runtime dependencies (ruby_llm, dotenv, thor). Adding a fourth needs
  a reason the existing three cannot cover.
- Ruby 4.0 is the floor. Raising it is the maintainer's call.
- The gem is not yet published to rubygems.org. Versions, CHANGELOG release
  headings, and `gem push` are the maintainer's alone. The agent never
  publishes, tags, or releases.
- Keys stay in `.env`, ignored by git, never in fixtures or examples beyond
  the placeholder in `.env.example`.
- Review budget: the maintainer reviews at most one pull request a week from
  this repo. Proposals beyond that wait as issues.
- The extraction prompt, the default model, and anything touching the gemspec
  or release process stay at L0 regardless of track record.

Anti-goals, which are constraints wearing a different hat:

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

## ROADMAP (what next)

The README's "what lens does NOT do (yet)" list is the roadmap. This is that
list as an order, with the reason for the order.

1. CI. There is none on main yet, and the first automation this repo needs is
   a test run across the supported Rubies with no secrets in the environment.
   Everything below lands faster once a red check can say no.
2. Multi-file corpora. Today the workaround is concatenating files by hand;
   the pipeline should accept a directory.
3. Quality eval and re-cast. A shaped skill needs a way to be scored against
   its source and re-shaped when it falls short. This waits on the pilot
   readout, because the eval has to measure something we have already seen
   fail.
4. Composition of several corpora into one lens. Last because it stacks on
   both of the above: you cannot compose what you cannot evaluate.

Off the list on purpose: PDF and EPUB extraction stay upstream in the agent
training program's pre-processors, and auto-publishing to a marketplace stays
off entirely.

Standing, not sequenced: each module does one thing (Shape, Validator,
SkillWriter). New capability arrives as a new module alongside them, not as a
branch inside an existing one.

## AGENTS (how agents work here)

Improvements arrive as GitHub issues, labeled by origin and state:

- Origin: `loop:quality`, `loop:security`, `loop:deps`, `loop:research`,
  `loop:self` (agent-originated), or unlabeled (human-originated).
- State: `status:analyzed`, `status:deferred`, `status:wont-do`,
  `status:blocked`. A closed issue with `status:wont-do` records the reason in
  its final comment and is permanent institutional memory. Proposals must check
  closed and deferred issues before re-raising an idea.

Each change class has an autonomy level per the constitution above. Every class
starts at L0 or L1, and the current level per class is recorded on the
operator's side, not here. The one-PR-a-week review budget applies on top of
the ladder: an L1 class does not mean a PR a day.

## CHARTER (why this exists, what territory, what freedoms)

**Why:** because most prompt engineering produces one-off context, useful for
this session, hard to share, impossible to version. Agent Skills are versioned,
portable context an agent loads on demand, and writing a good one from scratch
is the part nobody wants to do twice.

**Territory:** <!-- VAL: edit. The old charter drew this border only by negation (the anti-goals); this states it positively. -->
agent-lens owns the extraction framing, the shape-validate-write pipeline, the
provenance record, and the CLI that drives them. It does not own corpus
extraction from binary formats, skill hosting or distribution, provider
plumbing, or the methodology behind the framing.

**Freedoms:** the agent may open issues on anything in this territory, open
PRs at the class's autonomy level, and propose amendments to this file.

**Constraints:** the agent never merges amendments to this file, never cuts a
release or bumps a version, never changes the extraction prompt or default
model without a before/after, and never sends a corpus anywhere but the
configured model.

## Amending this document

By pull request with maintainer approval, nothing else. The agent may propose
amendments; it may never merge them.
