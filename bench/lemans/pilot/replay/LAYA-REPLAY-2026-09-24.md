# Lens-as-gate, offline replay with laya

Question: before wiring a decision model into the agent loop, can one read
a finished patch and tell a passing trial from a failing one? If not, it
cannot gate anything.

Data: run 2's 330 trials (gpt-5.6-luna, three arms, 22 Writebook tasks × 5
attempts). 225 passed the verifier, 105 failed. Run 1's 88 Haiku trials were
deleted before run 2 and are not in this set.

Model: ruby-laya 0.1.0, `typed-decisions` checkpoint (1,024-token context;
the English one reads 512), CPU on the mini. One sequence per question, so
the state is the task's description plus the first 500 characters of its
body, then the diff distilled to files changed and added lines, app code
first, capped at 1,500 characters. Mean state 1,526 characters.

Questions: the 15 lens items rephrased as yes/no about the change ("Does
the change build database conditions with placeholders…?"), plus one
comparator: "Does this change correctly and completely implement the
request?" The comparator is the floor. If it cannot beat a coin flip, the
per-item questions have nothing to add.

## Result: coin flip

AUC is the probability a random passing trial scores above a random
failing one. 0.5 is chance.

| | all | baseline | lensed | vocab |
|---|---|---|---|---|
| comparator | 0.518 | 0.530 | 0.452 | 0.571 |
| mean of 15 items | 0.472 | 0.494 | 0.388 | 0.524 |
| min of 15 items | 0.420 | 0.402 | 0.336 | 0.519 |
| count of items below 0.5 | 0.487 | 0.493 | 0.440 | 0.523 |

Best single item: path_safety at 0.583. Worst: cache_deps at 0.380. Every
one of the sixteen questions sits between 0.38 and 0.58 on the full set.

A gate at the comparator's median (0.589) would have let through 117
passing and 48 failing trials, and blocked 108 passing and 57 failing.
Precision of "blocked" as a failure detector: 34%. Recall: 54%. That gate
would have cost more good patches than it caught bad ones.

Per task it is no better. The three tasks luna fails 0/5 in every arm score
0.57 to 0.66 on the comparator, above several tasks luna passes 5/5
(ar-archive-book-access 0.46, ar-compact-positions 0.47). The model has no
sense of which tasks are hard.

## Why, probably

- **Resolution.** 1,500 characters of a patch that can run to a thousand
  lines. The bulk-access-grants failure from run 2 is an ordering choice
  between two index checks; nothing about that is visible in the first
  forty added lines.
- **Distribution.** laya's own benchmarks are tickets, emails, and intent
  labels. A Rails diff is not in that neighbourhood, and the confidence
  warning it prints on load ("this checkpoint ships invalid temperatures")
  says its probabilities are not calibrated here anyway.
- **The question is semantic.** Whether a patch passes the verifier depends
  on what the code does, not on what it mentions. A checklist-item
  classifier answers "does this text talk about X", and the pilot already
  showed that talking about X is not the failure mode.

## What this rules out, and what it does not

Rules out: laya, at this context, as a gate on finished patches. It also
rules out the cheap version of the per-item idea: asking whether each lens
item "is addressed" over the diff text.

Does not rule out: Jev with a fuller state (32K context, so the whole diff
plus the task), or a decision model reading something other than the
diff, such as the test output, the agent's own stated plan, or a
per-step observation. The offline replay for Jev costs about ten cents
for all 330 trials and needs a `TYPESAFE_API_KEY`. Worth running only if
the hypothesis is that context, not distribution, is what failed here.

## Reproduce

`laya-replay.rb` writes one CSV row per trial (`laya-replay-2026-09-24.csv`,
committed); `laya-analyze.rb` prints the tables above. Both run under
`runs/Gemfile` on the mini. The 16-questions-per-pass version peaked at
7.7 GB RSS and a minute a trial; two batches of 8 at 1,500 characters ran
at 4 GB and about 20 seconds. CoreML gets OOM-killed on this model; use
CPU.
