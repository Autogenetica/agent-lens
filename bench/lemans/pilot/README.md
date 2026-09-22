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
hand-roll it?); that readout is tracked separately and reads the same run
directories.
