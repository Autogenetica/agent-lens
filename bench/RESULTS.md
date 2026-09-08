# Benchmark results

Verified 2026-09-08 via `lemans run --backend=docker` (real sandbox, not a
hand simulation). Two agents per task:

- **oracle** — applies `solution.patch`. Should always pass.
- **nop** — makes no changes. Should always fail.

| task         | agent  | score | outcome   |
|--------------|--------|-------|-----------|
| validator    | oracle | 1/1   | completed |
| validator    | nop    | 0/1   | completed |
| skill_writer | oracle | 1/1   | completed |
| skill_writer | nop    | 0/1   | completed |

4 trials: 4 scored, 0 invalid, pass@2 2/2 tasks (100%) · $0.0000

## What this shows

Both tasks discriminate correctly: the real implementation passes every
check, and doing nothing passes none. That's the property a benchmark task
needs before it's trustworthy as a signal — a task that a `nop` agent could
accidentally pass isn't measuring anything. Reward of exactly 0.0 or 1.0
(no partial credit) also confirms `verification_test.rb` isn't leaking
partial matches from the stub's `NotImplementedError` paths.

Reproduce: `cd bench && lemans run --backend=docker && lemans report`.
