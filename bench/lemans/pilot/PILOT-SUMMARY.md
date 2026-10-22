# The lens pilot, 2026-09-16 to 2026-10-05: what we learned

One question: does a skill shaped by `lens shape` from an opinionated
corpus change what a coding agent ships? Measured with the Rails
Foundation's Agents on Rails corpus (22 Writebook tasks, hidden
verifiers) through lemans, five runs and three offline replays, about
$152 in model spend. This file is the index and the verdict; the
per-run notes carry the numbers.

## Verdict

1. **Knowledge lenses did nothing.** A 15-item Rails-idiom checklist
   shaped from the Rails Guides did not move pass rate on a weak model
   (Haiku 4.5: 13 vs 14 of 44) or a competent one (gpt-5.6-luna: 75 vs
   77 of 110). A control with the API names rewritten as descriptions
   scored the same. A lens shaped from Writebook's own source, naming
   the app's conventions, scored the same. Across 1,100 lensed trials
   the only content effect was that naming an API made the agent use
   that API slightly more often, in both directions, without passing
   more tasks.
2. **A process lens changed behaviour every time, and correctness a
   little.** The Testing Guide, shaped toward "every stated behaviour
   has a test", made luna write tests in 89 to 93 of 110 trials against
   baseline's 50, with three times the test lines, in all three arms it
   ran. Pass rate: 84, 75, 82 against 75. Pooled 73% vs 68%, z = 0.98.
   Small, consistent in direction, not significant at this sample.
3. **Nothing that reads a finished patch can gate it on this corpus
   except a frontier generative model, and even that only weakly.**
   laya (local decision model, 1,500 chars) 0.518 AUC; Jev systemone
   (hosted decision model, full diff) 0.519; an LLM routed by jev-router
   with the full diff 0.629, 0.745 when it picked gpt-6.1-sol. The 15
   lens items were at or below chance for every reader. Whether these
   patches pass is not visible on the diff's surface.
4. **The corpus set the ceiling.** The verifier checks that fail are
   application behaviour at the edges: an attachment actually purged, a
   variant not reprocessed, a cascade erase, the first conflicting row
   reported, who receives a broadcast. Three tasks fail 0/5 in every arm
   of every run. A checklist the agent reads cannot reach those; a
   self-written test mostly cannot either.

## What this means for agent-lens

The tool did what it says every time: a faithful 15-item RFC-2119
checklist from whatever corpus it was given, with provenance. The
question was never faithfulness. It was which corpus and which framing.
Shape process lenses (how to work) rather than knowledge lenses (what to
know), and measure them on tasks where self-verification can reach the
failure mode. Writebook stage 1 is not that corpus.

Two side findings worth keeping. Any loaded skill, regardless of
content, with or without its standing "internally verify" paragraph,
drops ar-bulk-access-grants from 4/5 to 1/5 by making the agent hoist a
validation pass ahead of the real one. And at five attempts per task,
per-task counts between identical arms swing by up to four trials, so
per-task claims need k of ten or more; arm-level counts at 110 trials
are stable.

## The runs

| run | date | model | arms | trials | cost | note |
|---|---|---|---|---|---|---|
| 1 | 09-22 | Haiku 4.5, direct API, uncached | baseline, lensed (k=2) | 88 | $116.81 | [RESULTS-2026-09-22](RESULTS-2026-09-22.md) |
| 2 | 09-23 | gpt-5.6-luna via OpenRouter | baseline, lensed, vocab (k=5) | 330 | $4.86 | [RESULTS-2026-09-23](RESULTS-2026-09-23.md) |
| 3 | 09-25 | Haiku 4.5 via OpenRouter, cached | baseline, lensed, vocab (k=3) | 198 (65 ran) | $17.06 | [RESULTS-2026-09-25](RESULTS-2026-09-25.md); credit balance died at 02:15Z, scored-only baseline replicates run 1 at 5x lower cost |
| 4 | 10-05 | luna | process, app (k=5) | 220 | $3.34 | [RESULTS-2026-10-05](RESULTS-2026-10-05.md) |
| 5 | 10-05 | luna | process2, noheader (k=5) | 220 | $3.41 | [RESULTS-2026-10-05-run5](RESULTS-2026-10-05-run5.md) |

Replays over run 2's 330 final diffs:

| reader | cost | note |
|---|---|---|
| laya typed-decisions, local CPU | $0 | [LAYA-REPLAY-2026-09-24](replay/LAYA-REPLAY-2026-09-24.md) |
| jev-router via OpenRouter (LLM judge) | $3.98 | [JEV-ROUTER-REPLAY-2026-10-04](replay/JEV-ROUTER-REPLAY-2026-10-04.md) |
| Jev systemone (typed-decision API) | $0.02 | same file, addendum |

Shape calls, smokes, and the caching smoke: about $3.

## Harness lessons, in the order they cost time

- Haiku 4.5 was the worst model on the Foundation's board for this
  corpus: lowest pass rate and among the most expensive per trial. Pick
  the model from their run directories, not from list price.
- The direct Anthropic path through ruby_llm/miniswen set no cache
  breakpoints; 55M input tokens an arm at list price. OpenRouter passes
  caching through (automatic for OpenAI, explicit for Anthropic) and
  cut per-trial cost 5x on Haiku and 100x on luna.
- lemans's docker backend supports `public` or `none` for the sandbox
  network, not the Daytona `allowlist`. The host-side `miniswen` agent
  with network `none` keeps the key out of the container.
- json 3.0.x in the global gem set breaks faraday 2.14's JSON
  middleware; the pilot ran under its own Gemfile pinning json 2.x.
- The lens spliced as task text gets committed into the app as a file.
  Framed as a loaded skill it does not, mostly.
- A heartbeat tick reset the clone to main under a parked run; the
  runner now snapshots the arm directories before starting.
- Never edit a runner script while a copy is executing; bash reads by
  byte offset.

## What survives

- `task-092aaa85`: a plain correctness judge as a submit gate (fixed
  strong model, full diff plus test output), a lemans or miniswen
  feature, level 0, needs a decision.
- A second corpus where the failing checks are ones a test can catch,
  to see whether the process lens's behaviour change converts.
- Journal material: five runs on a question with a clean negative and a
  qualified positive.

Everything else is closed. Run 3b (the 133 credit-starved trials) is
withdrawn; its question was answered by the 65 that ran.
