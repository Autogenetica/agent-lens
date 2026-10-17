# Advisory correctness judge, offline replay: full diff plus the agent's own test output

The one idea the three gate replays left standing was a plain correctness
question asked of a strong model over the whole diff: gpt-6.1-sol reached
0.745 AUC on the trials the Jev router happened to hand it. The two tasks
it got confidently wrong (ac-throttle-search, 15/15 pass, scored 0.24;
as-purge-embedded-images, 0/15, scored 0.98) looked like cases where the
diff alone cannot show behaviour. This replay adds the missing evidence:
the implementing agent's own last test run, lifted from the trajectory,
with the verifier log kept out of the prompt.

Data: the same 330 run-2 trials (gpt-5.6-luna, three arms, 22 Writebook
tasks x 5). 330 of 330 answered, all by `openai/gpt-6.1-sol` directly (no
router), temperature 0, strict JSON schema with one field `correct`.
Prompt: task text, full unified diff (app code first, 24,000-char cap),
then the last tool result in `trajectory.json` carrying a minitest summary
line, 40 lines of tail. Five trials ran no tests at all. Cost $2.37, 0.7
cents a trial, 1,389 prompt tokens on average.

## Result: the test output does not move the curve

| | all | baseline | lensed | vocab |
|---|---|---|---|---|
| judge, diff + agent test output | 0.732 | 0.707 | 0.743 | 0.744 |

The honest comparison is trial-matched. On the 146 trials the router had
routed to sol in the diff-only replay (102 pass, 44 fail):

| reader, same 146 trials | AUC |
|---|---|
| diff-only comparator (sol, 2026-10-04) | 0.745 |
| diff + agent test output (this run) | 0.765 |

Plus 0.02 on 44 failures is inside the noise of a bootstrap on that
subset; the full-set 0.732 is the number to carry forward, and it is not
0.85. The arm split is flat, as it was for every other reader.

## The two named tasks did not move

| task | verifier | diff-only (sol) | diff + tests | agent's own last run |
|---|---|---|---|---|
| ac-throttle-search | 15/15 pass | 0.148 (n=13) | 0.227 (n=15) | 179 runs, 0 failures in 14/15 |
| as-purge-embedded-images | 0/15 pass | 0.975 (n=2) | 0.989 (n=15) | 180 runs, 0 failures in 11/15 |

Both agents ran the full suite green, so the test output is the same
evidence in both tasks and the judge reads it the same way: as not
decisive. On as-purge the judge is right to discount it (the agent's suite
is green and the verifier still fails, so the hidden check is something
the agent never tested) and wrong about the patch. On ac-throttle it
disbelieves a green suite because it disbelieves the implementation. Either
way the extra section is not what the judge needed; what it needed is the
check it cannot see.

Three more tasks join the confidently-wrong list at full n: ar-erase-account
(0/15, scored 0.61), ar-tenant-isolation (13/15, scored 0.29),
sup-legacy-conversions (10/13, scored 0.37). The disagreements are per task,
not per trial: within a task the judge's scores barely vary with the patch
(ac-throttle 0.02 to 0.43 across 15 different patches that all pass). The
judge is scoring its opinion of the task's approach, not the trial.

## Calibration

| score bin | n | observed pass rate |
|---|---|---|
| [0.00, 0.10) | 41 | 0.29 |
| [0.10, 0.20) | 23 | 0.39 |
| [0.20, 0.30) | 18 | 0.72 |
| [0.30, 0.40) | 12 | 0.67 |
| [0.40, 0.80) | 15 | 0.47 |
| [0.80, 0.90) | 28 | 0.50 |
| [0.90, 0.95) | 38 | 0.79 |
| [0.95, 1.00] | 155 | 0.85 |

Binned expected calibration error 0.196. The instrument saturates exactly
as the router run did (155 of 330 at or above 0.95), and the low end is
upside down: a trial scored below 0.3 passes 45% of the time, because the
low bins are mostly ac-throttle-search and ar-tenant-isolation, which pass.
The score is bimodal with a hole between 0.4 and 0.8; this is a verdict
with a probability bolted on, not a probability.

## If it were a gate (it is an advisory column, and should stay one)

| threshold | lets through | blocks | precision of "blocked" | recall of failures |
|---|---|---|---|---|
| 0.50 | 181 pass + 50 fail | 44 pass + 55 fail | 56% | 52% |
| 0.80 | 176 pass + 45 fail | 49 pass + 60 fail | 55% | 57% |
| 0.90 | 162 pass + 31 fail | 63 pass + 74 fail | 54% | 70% |
| 0.95 | 132 pass + 23 fail | 93 pass + 82 fail | 47% | 78% |

Every row is the 2026-10-04 table again: one good patch blocked per
failure caught. The promote-to-gate bar was a curve near 0.85; this is
0.73 to 0.77 depending on the subset, and the test output was the one
cheap input left to add.

## What would move it, and what would not

Not more context of the same kind: the diff and the agent's tests are the
whole of what the agent produced, and the judge already has both. The five
confidently-wrong tasks are the ones whose verifier checks something the
ticket does not state (the exact throttle threshold, the attachment really
purged, the account really erased). A reader that never sees the check
cannot score it, at any model size. What might move it is a judge that can
run code against the task text (write its own probe test, not read the
agent's), which is a different and much more expensive instrument, and at
that point it is a second verifier, not a judge.

## Reproduce

`correctness-judge.rb <laya csv>` writes one row per trial
(`correctness-judge-2026-10-17.csv`, committed);
`correctness-judge-analyze.rb <judge csv> [jev-router csv]` prints the
tables above, including the trial-matched comparison. Needs
`OPENROUTER_API_KEY`; `THREADS=4` finished 330 trials in 17 minutes.
