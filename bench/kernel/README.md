# bench/kernel

The blind-rating A/B kernel: the part of an evaluation that stays fixed while the thing under test changes. Extracted from the ai-software-architect #35 run and adopted as the shared scorer for agent-lens milestone 2 and ruby-skills roadmap item 2. The design note, with the slot table per target, lives in the Minerva workspace: `research/eval-kernel-design.md` (private repo; ask Val for a copy).

## Six fixed parts

1. **Sealed arms.** `key.json` maps labels to commits and holds the prediction, written before any run and not opened until the last slot is rated. Schema in `key.schema.json`.
2. **One hashed prompt** shared by every arm.
3. **Seeded shuffle** of persona or pair order per run, seed logged.
4. **Metric 1, mechanical.** `overlap.py` for review-shaped output; for other targets, a pre-registered mechanical check named in the key.
5. **Metric 2, blind actionability rating.** `extract-rated.py` strips each output to the sections a maintainer would act on, redacts the treatment's vocabulary, shuffles into numbered slots, and writes a sealed slot key. A human rates each slot 1 to 5 against anchors written before rating.
6. **Keys opened last.** Overlap and ratings are tallied per label, then the key is read.

## Scripts

```
python3 -I overlap.py <arm_dir> [<arm_dir> ...]
python3 -I extract-rated.py <review.md> <outdir> [--seed N]
```

`overlap.py` expects `members/<member>.md` under each arm directory and prints a per-arm table plus the per-pair matrix. `extract-rated.py` writes `slot-NN.md` files and a `KEY-sealed.json` the rater does not open. Both are stdlib only.

The heading and vocabulary filters inside `extract-rated.py` are the asa #35 treatment's. They are the first thing to parameterise when a second target runs; the `redactions` field in the key is the intended source.

## Status

Nothing runs against a live target until milestone 2 is scheduled. Lessons from the first run that shaped this: a dominant finding can carry an arm, the 4 to 4.5 band compresses, the extractor is part of the instrument, and the rater is also the designer.
