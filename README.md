# agent-lens

> Shape Agent Skills from opinionated corpora.

`lens` is a small Ruby CLI that turns an opinionated source corpus — a book
chapter, a course transcript, a codebase's canonical pattern files, an
internal SOP — into an [agentskills.io](https://agentskills.io)-compliant
**Agent Skill** that AI coding agents read before responding.

Each shaped skill acts as one **lens element** in the agent's compound lens
stack: a layered focus that shifts the agent's reasoning toward the source's
specific positions. Add an element, the agent's attention bends slightly.
Add another, the prescription combines. Different stacks produce different
focal points.

## Install

```sh
gem install agent-lens
```

Requires Ruby ≥ 4.0 and an `ANTHROPIC_API_KEY` (a `.env` file in the current
directory works; copy `.env.example` to start).

## Use

```sh
lens shape ~/Books/99-bottles-of-oop.md \
  --output ./skills/ruby-rails-discipline \
  --name ruby-rails-discipline \
  --framing "a senior Ruby/Rails engineer reviewing or refactoring code"
```

This reads the corpus, calls a single LLM completion (Sonnet 4.6 by default),
and writes:

```
./skills/ruby-rails-discipline/
├── SKILL.md                      # agentskills.io-compliant: name + description + body
└── docs/
    └── PROVENANCE.md             # source, model, framing, lens-cast timestamp
```

The `SKILL.md` has YAML frontmatter (validated against agentskills.io
constraints before writing) and a body of 10–15 RFC-2119 verification items
the agent reads before responding to relevant questions.

Drop the directory into `~/.claude/skills/<name>/` to load it in Claude Code,
or publish it to a marketplace.

### Options

| Flag | Required | Notes |
|---|---|---|
| `--output` / `-o` | yes | Output directory (creates if missing) |
| `--name` / `-n` | yes | Kebab-case skill name; matches the agentskills.io `name:` field |
| `--framing` / `-f` | no | Operating-context phrase, e.g. *"a senior Ruby engineer reviewing code"*. This is the per-task-layer focus knob — distinct framings against the same corpus produce distinct skills. |
| `--description` / `-d` | no | Override the auto-generated description (max 1024 chars per spec) |
| `--license` | no | License string (default: *"Pending review"* — appropriate while content is pre-publication) |
| `--model` | no | LLM model for extraction (default: `claude-sonnet-4-6`) |
| `--env-file` | no | Path to a `.env` file to load (default: `./.env`) |

### Multi-file corpora

`lens shape` takes any number of files and directories. Directories expand
to their `*.md` / `*.markdown` / `*.txt` files, sorted by path. With more
than one file, each file is preceded by a visible boundary marker
(`<!-- source file 2 of 5: models.md -->`) and `docs/PROVENANCE.md` lists
every file with its own sha256 — unlike `cat files > combined.md`, whose
hash pins nothing you could name. A single file is read byte for byte, exactly
as before.

```bash
lens shape app/models/concerns/ docs/patterns.md --output ./codebase-lens --name codebase-lens
```

### What lens does NOT do (yet)

- PDF or EPUB extraction (use a pre-processor; the [agent training program](https://github.com/codenamev/agent-training-program) ships `epub_to_md.rb` and `ocw_to_md.rb` for those)
- Auto-publishing to a marketplace
- Quality eval / re-cast loop
- Composition of multiple corpora into a single lens

## Why this exists

Most prompt engineering produces *one-off* context — useful for this session,
hard to share, impossible to version. Agent Skills are versioned, portable
context the agent loads on demand. But writing a good skill from scratch is
slow expert work.

agent-lens compresses that authoring step: point it at a corpus the author
already wrote (a book, a course, a codebase's canonical files) and it
distills the positions into a publishable skill. The original author/source
remains the irreducible expert input; lens automates the distillation.

The pipeline has been empirically validated across:

- **Books** — 99 Bottles of OOP (Metz/Owen/Stankus), Confident Ruby (Grimm), Hotwire Native for Rails Developers (Masilotti)
- **Courses** — MIT 6.034 AI, MIT 14.01 Microeconomics, MIT 6.006 Algorithms
- **Internal codebases** — `nowreading.dev` (Rails 8 + Hotwire) canonical pattern files

Across both **advisory** (review, critique, explain) and **code-generation**
task layers. Details and methodology in the
[agent training program](https://github.com/codenamev/agent-training-program)'s
`docs/THESIS.md` (rounds 7-9, Claims 7-12).

## Architecture

```
Corpus (any text/markdown)
    │
    ▼
Lens::Shape          # single LLM call with RFC-2119 framing
    │
    ▼
Lens::Validator      # agentskills.io constraints (name, description)
    │
    ▼
Lens::SkillWriter    # writes SKILL.md + docs/PROVENANCE.md
    │
    ▼
Agent Skill directory (publishable)
```

Each module is single-purpose; downstream lens work (composition, re-casting,
quality eval) plugs in alongside without re-architecting.

## Contributing

This is part of [Autogenetica](https://github.com/Autogenetica) — tools for
self-shaping agentic systems. The agent-lens roadmap is shaped by the
agent training program's L·F frontier work; see
[`docs/AGENCY_DISCIPLINES.md`](https://github.com/codenamev/agent-training-program/blob/main/docs/AGENCY_DISCIPLINES.md)
for the broader project arc.

Issues and PRs welcome.

## License

[MIT](LICENSE.txt).
