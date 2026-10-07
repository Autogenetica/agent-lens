# Lens pilot, run 6: the pre-registered check-reachability split

Run 2026-10-07 on the mini. gpt-5.6-luna via OpenRouter (`--model` override on the
arm's bench.yml, so the arm directories are byte-identical to the branch), host-side
miniswen, docker backend, upstream trial limits. All 22 Writebook stage-1 tasks,
10 attempts per task, two arms run one after the other at 3 trials in flight.
440 trials, $6.33, 290 min wall clock.

Pre-registered before launch (brief 2026-10-06, from the corpus-2 survey): the
process lens beats baseline on the 14 tasks whose hidden checks a self-written
integration/model test can reach (one-sided), and does nothing on the 7 whose
checks need instrumentation or assert an unstated requirement. Primary readout
is arm-level pass per subset at k=15, pooling run 6 with run 2's baseline and
run 4's process arm. Kill: reachable delta under +5 points or z < 1.64 → the
lens is "behaviour only"; the 7 moving as much as the 14 → the split is wrong.

## Headline, run 6 alone

| | baseline | process |
|---|---|---|
| trials solved | 163/220 (74%) | 159/220 (72%) |
| pass@10 | 19/22 | 19/22 |
| mean steps | 13.4 | 15.0 |
| cache hit | 89% | 91% |
| cost | $2.89 | $3.44 |
| cost per trial | $0.0131 | $0.0156 |
| invalid (unscored) trials | 0 | 0 |

## The split

Pass / scored trials per subset. z is the two-proportion test, process minus
baseline; p is one-sided (the pre-registered direction).

| subset | baseline k=10 | process k=10 | Δ pts | z | baseline pooled | process pooled | Δ pts | z | p |
|---|---|---|---|---|---|---|---|---|---|
| reachable (14) | 117/140 (84%) | 112/140 (80%) | -3.6 | -0.77 | 170/210 (81%) | 173/210 (82%) | 1.4 | 0.38 | 0.353 |
| not reachable (7) | 36/70 (51%) | 37/70 (53%) | 1.4 | 0.17 | 53/105 (50%) | 55/105 (52%) | 1.9 | 0.28 | 0.391 |
| hello-world | 10/10 (100%) | 10/10 (100%) | 0.0 | 0.00 | 15/15 (100%) | 15/15 (100%) | 0.0 | 0.00 | 0.500 |

Pooled = run 6 + run 2 baseline (110 trials, 2026-09-23) and run 6 + run 4
process (110 trials, 2026-10-05); same model id, tasks, limits.

## Kill criteria, applied mechanically

- reachable subset, pooled: Δ 1.4 pts, z 0.38 → threshold Δ ≥ +5 and z ≥ 1.64: **KILLED (downgrade to "behaviour only")**
- not-reachable subset, pooled: Δ 1.9 pts against the reachable Δ 1.4: **KILLED (split is wrong: the 7 moved as much as the 14)**

These are the pre-registered thresholds read off the table; the Reading section
says what they mean after the trajectories have been looked at.

## Per task

Solved / scored. `*` marks the five secondary tasks named before launch
(the reachable tasks with headroom in the k=5 data).

| task | set | baseline k=10 | process k=10 | baseline pooled | process pooled |
|---|---|---|---|---|---|
| ac-deep-link-return | R | 10/10 | 10/10 | 15/15 | 15/15 |
| ac-throttle-search | R | 10/10 | 8/10 | 15/15 | 12/15 |
| aj-enqueue-after-commit | R | 10/10 | 7/10 | 15/15 | 12/15 |
| aj-resumable-cleanup | R | 9/10 | 10/10 | 14/15 | 15/15 |
| ar-announce-once\* | R | 10/10 | 8/10 | 14/15 | 13/15 |
| ar-archive-book-access | R | 10/10 | 10/10 | 15/15 | 15/15 |
| ar-atomic-import | R | 10/10 | 10/10 | 15/15 | 15/15 |
| ar-bulk-access-grants | not-R | 5/10 | 5/10 | 9/15 | 6/15 |
| ar-compact-positions | R | 10/10 | 10/10 | 14/15 | 14/15 |
| ar-erase-account\* | R | 0/10 | 0/10 | 0/15 | 0/15 |
| ar-release-recap | R | 10/10 | 10/10 | 15/15 | 15/15 |
| ar-tenant-isolation | R | 8/10 | 10/10 | 12/15 | 15/15 |
| as-purge-embedded-images | not-R | 0/10 | 0/10 | 0/15 | 0/15 |
| as-variant-processed-once | not-R | 0/10 | 0/10 | 0/15 | 0/15 |
| av-toc-cache-per-role\* | R | 1/10 | 3/10 | 2/15 | 7/15 |
| hello-world | — | 10/10 | 10/10 | 15/15 | 15/15 |
| hw-scoped-broadcast | not-R | 4/10 | 4/10 | 7/15 | 8/15 |
| sec-audit-sweep\* | R | 9/10 | 9/10 | 11/15 | 13/15 |
| sup-cache-library-digest | not-R | 10/10 | 10/10 | 15/15 | 15/15 |
| sup-legacy-conversions\* | R | 10/10 | 7/10 | 13/15 | 12/15 |
| sup-log-to-terminal | not-R | 8/10 | 9/10 | 10/15 | 12/15 |
| tst-error-page-flake | not-R | 9/10 | 9/10 | 12/15 | 14/15 |

## Provenance

- baseline, run 6: model {"openrouter/openai/gpt-5.6-luna" => 220}, profile_digest {"d0a69d05a4b34509" => 220}; prior arm profile_digest {"b59fd00ddff7c9ea" => 110}.
  task_digest against the prior arm: every run 6 trial matches.
- process, run 6: model {"openrouter/openai/gpt-5.6-luna" => 220}, profile_digest {"3f4941dbbb07c26b" => 220}; prior arm profile_digest {"3f4941dbbb07c26b" => 110}.
  task_digest against the prior arm: every run 6 trial matches.
- Arm directories: run6.sh refuses to launch unless `git diff lemans/run4-corpus-arms --
  bench/lemans/pilot/{baseline,process}` is empty; the launch log records the check.
- A different profile_digest between run 6 and the prior arm is expected when the
  bench.yml model line differs from the `--model` override (baseline's file says
  Haiku since run 3); the task_digest match is the content check that matters.

## Reading

<!-- interpretation pending: written after the trajectories are read, not by readout6.rb -->

## Reproduce

`bench/lemans/pilot/run6.sh` (two arms in sequence, `--model openrouter/openai/gpt-5.6-luna`,
`-k 10 -c 3`, the 22 tasks by name, trials under `<arm>/runs/run6/`), then
`ruby bench/lemans/pilot/split/readout6.rb 2026-10-07` for this file. `split/reanalysis.py`
is the k=5 post-hoc analysis that motivated the run; `split/checks.rb` regenerates
the per-check classification input from a local ai-evals checkout.

### lemans report, baseline

```
task                       score  time    cost     steps  tokens
ac-deep-link-return        10/10  1m 35s  $0.0089  12.8   109079
ac-throttle-search         10/10  1m 43s  $0.0122  11.3   147717
aj-enqueue-after-commit    10/10  1m 37s  $0.0098  11.7   123735
aj-resumable-cleanup       9/10   1m 54s  $0.0137  14.6   181391
ar-announce-once           10/10  1m 59s  $0.0141  13.6   182309
ar-archive-book-access     10/10  1m 51s  $0.0127  13.3   165830
ar-atomic-import           10/10  1m 36s  $0.0106  12.2   122127
ar-bulk-access-grants      5/10   1m 41s  $0.0112  12.4   110592
ar-compact-positions       10/10  1m 30s  $0.011   11.5   143105
ar-erase-account           0/10   2m 7s   $0.0177  14.3   261960
ar-release-recap           10/10  1m 44s  $0.0129  13.9   185553
ar-tenant-isolation        8/10   2m 53s  $0.0227  16.8   362184
as-purge-embedded-images   0/10   1m 35s  $0.014   14.1   237002
as-variant-processed-once  0/10   2m 3s   $0.0196  17.5   341916
av-toc-cache-per-role      1/10   2m 2s   $0.0179  15.9   288247
hello-world                10/10  51s     $0.0027  5.6    15227
hw-scoped-broadcast        4/10   1m 42s  $0.0147  14.4   210351
sec-audit-sweep            9/10   2m 5s   $0.0189  16.7   340048
sup-cache-library-digest   10/10  1m 27s  $0.0095  11.9   104062
sup-legacy-conversions     10/10  1m 22s  $0.0089  10.5   92869
sup-log-to-terminal        8/10   1m 30s  $0.0121  13.8   156927
tst-error-page-flake       9/10   2m 32s  $0.0134  16.4   192259
220 trials: 220 scored, 0 invalid, 163 solved (74%) · $2.8915 · pass@10 19/22 tasks (86%)
```

### lemans report, process

```
task                       score  time    cost     steps  tokens
ac-deep-link-return        10/10  1m 54s  $0.0118  15.5   163855
ac-throttle-search         8/10   2m 0s   $0.0149  12.4   193749
aj-enqueue-after-commit    7/10   1m 50s  $0.014   14.7   207014
aj-resumable-cleanup       10/10  2m 3s   $0.0144  12.9   178457
ar-announce-once           8/10   1m 57s  $0.0159  14.9   235625
ar-archive-book-access     10/10  2m 1s   $0.0156  15.8   237002
ar-atomic-import           10/10  1m 42s  $0.0111  12.1   136889
ar-bulk-access-grants      5/10   2m 3s   $0.0138  14     174335
ar-compact-positions       10/10  1m 22s  $0.0099  10     126233
ar-erase-account           0/10   2m 10s  $0.0199  16.5   343472
ar-release-recap           10/10  1m 52s  $0.0134  13.2   193304
ar-tenant-isolation        10/10  2m 47s  $0.0242  16     384529
as-purge-embedded-images   0/10   1m 46s  $0.0168  16.6   305606
as-variant-processed-once  0/10   2m 11s  $0.0233  20.1   455669
av-toc-cache-per-role      3/10   2m 7s   $0.0192  16.6   334101
hello-world                10/10  47s     $0.0021  4.9    16347
hw-scoped-broadcast        4/10   2m 56s  $0.0245  22.4   473850
sec-audit-sweep            9/10   2m 57s  $0.0253  20.9   503313
sup-cache-library-digest   10/10  1m 37s  $0.0129  14.1   180218
sup-legacy-conversions     7/10   1m 52s  $0.0138  14.3   197264
sup-log-to-terminal        9/10   1m 38s  $0.0125  14.6   180059
tst-error-page-flake       9/10   2m 47s  $0.0144  18.2   233910
220 trials: 220 scored, 0 invalid, 159 solved (72%) · $3.4371 · pass@10 19/22 tasks (86%)
```
