# Lens pilot: two arms, one task set

Does prepending the Rails-idiom lens to a task change what Haiku ships on the
Agents on Rails corpus? Two benches answer that with the same 42 tasks:

- `baseline/` runs the tasks as the Rails Foundation published them.
- `lensed/` runs them with `lens/SKILL.md` ahead of every `instruction.md`
  (see `../lensify.rb` for exactly how the file is assembled).

Everything else (image, agent, limits, verifier) is the upstream profile with
the model swapped to Haiku 4.5 over the Anthropic API. The two `bench.yml`
files must stay identical apart from their header comments; diff them before
a run.

## Run

```sh
export ANTHROPIC_API_KEY=...            # minerva-mini-agent-lens
bench/lemans/pilot/prepare.sh            # copies tasks + docker from ~/src/ai-evals

# smoke: one task, one attempt, both arms
lemans run --bench bench/lemans/pilot/baseline --backend docker --task ac-throttle-search
lemans run --bench bench/lemans/pilot/lensed   --backend docker --task ac-throttle-search

# pilot: 42 tasks x 3 attempts per arm
lemans run --bench bench/lemans/pilot/baseline --backend docker -k 3 -c 2
lemans run --bench bench/lemans/pilot/lensed   --backend docker -k 3 -c 2

lemans report --bench bench/lemans/pilot/baseline
lemans report --bench bench/lemans/pilot/lensed
```

Run one arm to completion before starting the other; the per-trial cost cap
is $0.60 and the pilot ceiling is $65 across both arms, so check the report's
cost line after the smoke run and after the first arm.

## Readout

Pair rows by task name. Beyond pass@k, the metric the lens is actually
targeting is Rails-API reach (did the agent use the framework's own API or
hand-roll it?). `reach.rb` reads the same run directories and adds that axis:

```sh
ruby bench/lemans/pilot/reach.rb                          # baseline vs lensed
ruby bench/lemans/pilot/reach.rb fable=path/to/runs/model  # any run dirs
```

Per trial it checks whether the task's `rails_anchor` (the API the reference
solution turns on, from the task frontmatter, copied into `result.json`)
appears on a line the agent added in `agent.patch`. Same rule on both arms,
so the arm-to-arm delta is honest even where the absolute number is not:
anchors that name a concept rather than a token (`callable_cache_key`,
`commit_transaction_on_non_local_return`) always read as misses, and an
anchor in a comment reads as a hit. Read the patch when a row looks odd.

Calibration against the published Fable 5.1 run in ai-evals: the pass column
reproduces the 58/63 the Rails Foundation reported; reach reads 38/63 (60%)
where their judge-scored readout said 41%. The gap is the concept anchors
above. Treat reach here as a within-pilot comparison, not a leaderboard
number.

## Control arm (run 2)

`control/LENS.md` is the vocabulary control: the same fifteen checks, rewritten
so no Rails API name, method, option, or constant appears, at ±5% of the lens's
word count under the same skill preamble. `control/check.rb` is the leakage
gate (the 21 task anchors plus every backticked identifier in the real lens,
plus an identifier-shape regex); `prepare.sh` runs it before building
`control/tasks` and refuses to build on a leak or a size miss. Read the
three-arm readout with:

```sh
ruby bench/lemans/pilot/reach.rb control=bench/lemans/pilot/control/runs
```

If control tracks baseline, the lens's effect is the vocabulary (the API names
themselves). If control tracks lensed, the effect is the checklist and the
vocabulary is decoration.
