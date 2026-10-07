# split/ — the check-reachability split (lens pilot run 6)

Run 6 asks one pre-registered question: does the process lens's pass-rate
gain live on the Writebook tasks whose hidden checks a self-written test can
reach, and nowhere else? This directory holds the classification and the
readout so the answer is reproducible.

## The classification

Every hidden check (the string-named `test "…" do` blocks in each task's
`verification_test.rb`) was put in one of three buckets by hand:

- **R** — the behaviour is stated in the ticket and assertable in a plain
  Rails integration/model test: request/response, redirect, DB state,
  enqueued jobs, `travel_to`.
- **I** — stated, but assertable only with instrumentation an agent rarely
  sets up from a ticket: `ActiveStorage` service existence / `variant_records`,
  `ActiveSupport::Notifications` subscribers counting cache reads or INSERTs,
  `capture_turbo_stream_broadcasts` per verified stream name, `IO.popen` of
  the runbook command plus a log-file read, `Thread`/parallel-suite behaviour.
- **U** — not stated in the ticket (the "senior Rails developer would supply
  unasked" requirement).

A task is **reachable** when ≥ 80% of its checks are R. Stage 1, per task
(hello-world excluded; it is a file-content check). Fail counts are from
`checks.json` across the seven luna arms of runs 2, 4 and 5 (35 trials):

| task | checks | R | share | luna fails /35 | where the failures land |
|---|---|---|---|---|---|
| ac-deep-link-return | 4 | 4 | 100% | 0 | — |
| ac-throttle-search | 5 | 5 | 100% | 0 | — |
| aj-enqueue-after-commit | 8 | 8 | 100% | 1 | R |
| aj-resumable-cleanup | 5 | 5 | 100% | 0 | — |
| ar-announce-once | 10 | 10 | 100% | ~3 | R |
| ar-archive-book-access | 6 | 6 | 100% | 2 | R |
| ar-atomic-import | 10 | 10 | 100% | 0 | — |
| ar-compact-positions | 6 | 6 | 100% | 2 | R |
| ar-erase-account | 5 | 5 | 100% | 35 | R, enumeration-deep cascade |
| ar-release-recap | 4 | 4 | 100% | 0 | — |
| ar-tenant-isolation | 10 | 9 | 90% | 2 | R |
| av-toc-cache-per-role | 6 | 5 | 83% | 21 | R |
| sec-audit-sweep | 5 | 5 | 100% | 9 | R |
| sup-legacy-conversions | 6 | 6 | 100% | 2 | R |
| ar-bulk-access-grants | 9 | 7 | 78% | 25 | R, but 2 checks count INSERTs (I) |
| as-purge-embedded-images | 5 | 1 | 20% | 35 | I+U |
| as-variant-processed-once | 5 | 0 | 0% | 33 | I |
| hw-scoped-broadcast | 8 | 0 | 0% | 18 | I+U |
| sup-cache-library-digest | 4 | 3 | 75% | 0 | — |
| sup-log-to-terminal | 3 | 0 | 0% | 16 | I |
| tst-error-page-flake | 6 | 3 | 50% | 0 | — |

Confidence: high on the eight tasks whose failing checks were read in full
(the five reachable tasks with headroom and the failing not-reachable
rows); medium on the thirteen that pass at or near 35/35, classified from
check name plus assertion tags.

## Pre-registered sets (fixed before run 6 launched; do not edit)

- **Reachable (14):** ac-deep-link-return, ac-throttle-search,
  aj-enqueue-after-commit, aj-resumable-cleanup, ar-announce-once,
  ar-archive-book-access, ar-atomic-import, ar-compact-positions,
  ar-erase-account, ar-release-recap, ar-tenant-isolation,
  av-toc-cache-per-role, sec-audit-sweep, sup-legacy-conversions.
- **Not reachable (7):** ar-bulk-access-grants, as-purge-embedded-images,
  as-variant-processed-once, hw-scoped-broadcast, sup-cache-library-digest,
  sup-log-to-terminal, tst-error-page-flake.
- **Prediction:** process > baseline on the first set (one-sided), no
  difference on the second. Primary readout: arm-level pass per subset,
  two-proportion z, pooled with run 2's baseline and run 4's process arm
  (k=15). Secondary, per task at k=15: ar-erase-account,
  av-toc-cache-per-role, sec-audit-sweep, sup-legacy-conversions,
  ar-announce-once.
- **Kill:** reachable delta under +5 points or z < 1.64 → the lens is
  "behaviour only"; the 7 moving as much as the 14 → the split is wrong.

## Files

- `checks.rb` — dumps every hidden check of an ai-evals-style task dir with
  assertion-style tags (`ruby split/checks.rb bench/lemans/pilot/baseline/tasks`).
  Its output, `stage1-checks.txt`, is the input the hand classification was
  made on. **It is gitignored on purpose:** the check names are the hidden
  tests' own names, which is ai-evals task data, and the repo's rule is that
  task data never gets a second public copy. Regenerate it locally.
- `reanalysis.py` — the post-hoc k=5 split over the seven existing luna arms
  (the 86% vs 76%, z 1.94 that motivated run 6). Hypothesis-generating, not
  a result; kept verbatim as the record of what was seen before registering.
- `readout6.rb` — the mechanical run 6 readout: headline, split table at
  k=10 and k=15 pooled, kill criteria applied, per-task table, provenance
  (model id, profile and task digests against the prior arms).
  `ruby bench/lemans/pilot/split/readout6.rb <date> > bench/lemans/pilot/RESULTS-<date>-run6.md`
- `lemans-report-run6-<arm>.txt` — `lemans report` per arm, written by
  `run6.sh` on completion and appended to the RESULTS file.
