# Lens pilot, run 5: does the process lens replicate, and is the header the confound?

Run 2026-10-05 on the mini, same luna profile as runs 2 and 4. Two arms,
220 trials, $3.41.

- **process2**: the process lens unchanged. Does 84/110 hold?
- **noheader**: the same 15 items with the standing paragraph removed
  ("Before responding to the user, internally verify each applicable item
  below…"). Every lens arm had dropped ar-bulk-access-grants from 4/5 to
  1/5 regardless of content; the paragraph was what they shared.

## Headline, all seven luna arms

| | baseline | lensed | vocab | app | process | process2 | noheader |
|---|---|---|---|---|---|---|---|
| solved of 110 | 75 | 77 | 73 | 78 | 84 | 75 | 82 |
| pass@5 | 19 | 19 | 18 | 18 | 19 | 17 | 19 |
| steps | 14.0 | 14.8 | 14.0 | 14.1 | 15.5 | 15.3 | 14.9 |
| cost | $1.57 | $1.71 | $1.59 | $1.52 | $1.82 | $1.76 | $1.65 |
| trials touching `test/` | 50 | 57 | 58 | 62 | **93** | **92** | **89** |
| added test lines per trial | 12 | 15 | 17 | 16 | **35** | **33** | **31** |

## The process lens: behaviour replicates, the pass rate mostly does not

The mechanism is rock solid. All three process-type arms wrote tests in
89 to 93 of 110 trials against baseline's 50, with three times the test
lines, and spent about a step more per trial doing it. The lens changes
what the agent does, every time.

The pass rate is another matter. 84, 75, 82. Pooled, the three
process-type arms solved 241 of 330 (73%) against baseline's 75 of 110
(68%). Two-proportion z is about 0.97, p around 0.33. The direction is
consistent (none of the three fell below baseline) and the size is about
five trials in a hundred and ten. That is a real-looking small effect
with a confidence interval that comfortably includes zero. Run 4's nine
trials was the high draw of three.

Per-task variance at five attempts is large enough to make any single
arm's per-task table unreliable:

| task | process | process2 | noheader |
|---|---|---|---|
| av-toc-cache-per-role | 4 | 0 | 3 |
| hw-scoped-broadcast | 4 | 1 | 1 |
| ar-archive-book-access | 5 | 3 | 5 |
| tst-error-page-flake | 5 | 4 | 3 |

Same lens, same model, same tasks, and av-toc-cache-per-role swings from
4/5 to 0/5 between runs. Run 4's "largest single gain" was a draw. The
sign test in RESULTS-2026-10-05 treated per-task counts as stable; they
are not at k = 5, and that reading is withdrawn.

## The header is not the confound

noheader scored 82, inside the process band, so removing the standing
paragraph cost nothing. And ar-bulk-access-grants did not come back:
baseline 4, process 1, process2 0, noheader 2. Whatever makes luna hoist
a validation pass ahead of the roster pass on that task, it is not the
"internally verify" wording. It survives with any loaded skill, in six
arms with four different checklists, with and without the paragraph.
The remaining common factor is the loaded-skill preamble itself, or
simply the presence of a checklist. Bounded at about three trials per
arm; not worth another arm on this corpus.

## What five runs say

| lens | corpus | effect on luna |
|---|---|---|
| idiom (lensed) | Rails Guides | none |
| vocabulary control | Guides, API names removed | none |
| app conventions | Writebook source | none |
| process | Testing Guide | behaviour changes every time; pass rate +5 ± 5 trials in 110 |

A checklist about how to work is the only kind that changed what the
agent did, and it changed it reliably: three times the tests, visibly,
in every run. Whether those tests buy correctness on this corpus is a
smaller question than it looked after run 4. On these 22 tasks the
agent's failures are mostly behaviours the verifier checks that a
self-written test is unlikely to reach (an attachment purged, a variant
not reprocessed, a cascade), so the ceiling for any lens here is low.
The honest summary for agent-lens: shape process lenses, not knowledge
lenses, and measure them on a corpus where self-verification can reach
the failure mode.

## Next, if anything

- A corpus where the failing checks are ones a test can catch, to see
  whether the process lens's behaviour change converts. Writebook stage 1
  is not that corpus; the three 0/5 tasks and most of the 2-to-4 band fail
  on side effects the diff cannot show.
- Ten attempts per task instead of five if per-task claims matter; the
  arm-level number is stable at 110 trials, the per-task numbers are not.
- Nothing more on the header.

## Reproduce

Arms `process2/` and `noheader/` carry the process profile; tasks built
with `lensify.rb` directly from `lens-process/` and
`lens-process-noheader/`. Readout as in RESULTS-2026-10-05 with the two
extra arms.
