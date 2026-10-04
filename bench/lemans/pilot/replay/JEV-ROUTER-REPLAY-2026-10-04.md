# Lens-as-gate, offline replay, second reader: jev-router with the full diff

Same question as the laya replay, different reader. Does something that
reads a finished patch tell a passing trial from a failing one? laya at
1,500 characters of diff could not (comparator AUC 0.518). This run gives
a capable reader the whole thing.

What this is and is not: `typesafe/jev-router` on OpenRouter is a chat
model that routes each request to an LLM of its choosing and answers
through that model. It is not Jev's typed-decision (systemone) endpoint,
which typesafe serves only from its own API with its own key. So this
measures "an LLM judge, routed by Jev, reading the full diff", and the
routed model is recorded per row.

Data: the same 330 run-2 trials as the laya replay (gpt-5.6-luna, three
arms, 22 Writebook tasks × 5 attempts). 328 answered; two
sup-legacy-conversions trials were dropped by a thread race and not
retried. 224 pass, 104 fail.

State: the full task text (frontmatter stripped, 6,000-char cap, never
hit) and the full unified diff, app code first, 24,000-char cap. Same
16 questions as the laya replay (15 lens items plus the comparator),
asked once per trial as a strict JSON schema of 16 probabilities,
temperature 0. Cost: $3.98 for 328 calls.

## Result: the comparator has signal, the lens items have none

| | all | baseline | lensed | vocab |
|---|---|---|---|---|
| comparator | 0.629 | 0.639 | 0.659 | 0.592 |
| mean of 15 items | 0.430 | 0.440 | 0.435 | 0.415 |
| min of 15 items | 0.462 | 0.413 | 0.445 | 0.526 |
| count of items below 0.5 | 0.435 | 0.457 | 0.437 | 0.411 |

Every one of the 15 lens items lands between 0.415 and 0.474, all below
chance. A reader with the whole diff in front of it still cannot use "does
the change use placeholders / eager-load / allowlist params / …" to
predict whether the verifier passes. The items are not noisy; they are
pointed at the wrong thing. The failures in this corpus are logic and
ordering, not idiom.

The comparator is a different story, and it depends on who the router
picked:

| routed model | trials | comparator AUC |
|---|---|---|
| openai/gpt-6.1-sol | 146 | 0.745 |
| deepseek/deepseek-v4.1-flash | 50 | 0.705 |
| google/gemini-3.8-flash | 114 | 0.583 |
| gpt-6-luna, opus-5.5, fable-5.1 | 18 | too few failures to score |

Two thirds of the signal is gpt-6.1-sol. Gemini flash, which took a third
of the requests, is close to chance.

## Would it work as a gate?

The comparator saturates: 180 of 328 trials score 0.95 or above, 65 score
below 0.5. On the gpt-6.1-sol subset:

| threshold | lets through | blocks | precision of "blocked" | recall of failures |
|---|---|---|---|---|
| 0.50 | 76 pass + 17 fail | 26 pass + 27 fail | 51% | 61% |
| 0.80 | 71 pass + 14 fail | 31 pass + 30 fail | 49% | 68% |
| 0.95 | 44 pass + 5 fail | 58 pass + 39 fail | 40% | 89% |

At the gentlest threshold the gate blocks one good patch for every bad one
it catches and misses four in ten failures. At the strict one it catches
nine in ten failures and blocks more than half of the good patches. For
an agent that passes 68% of the time, that trade only pays if a blocked
patch costs much less than a shipped failure, and the gate would need a
fixed strong judge rather than a router that hands a third of the calls
to a model at chance.

Per task the judge is sometimes confidently wrong in both directions:
ac-throttle-search passes 15/15 and averages 0.24; as-purge-embedded-images
fails 15/15 and averages 0.98. Those are tasks where the verifier checks
something the diff alone does not show (a rate limit's exact threshold, an
attachment actually purged), which is the ceiling on any reader that sees
only the patch.

## What three replays say together

| reader | state | comparator AUC | lens items |
|---|---|---|---|
| laya typed-decisions (local) | 1,500 chars | 0.518 | 0.38 to 0.58 |
| jev-router, any model | full diff | 0.629 | 0.42 to 0.47 |
| jev-router, gpt-6.1-sol | full diff | 0.745 | n/a (subset) |

Context helps the correctness question and does nothing for the lens
questions. The lens content does not predict verifier outcomes when the
agent reads it (runs 1 to 3), when a small decision model reads it over
the diff, or when a frontier model reads it over the diff. Whatever the
Rails Guides checklist encodes, it is orthogonal to why these patches
fail.

The surviving idea is a plain correctness judge, strong model, full diff
plus test output, at a threshold chosen for the cost ratio. That has
nothing to do with agent-lens and is a lemans or miniswen feature.

## Not run

Jev's actual systemone API with the full diff in its 32K window. It would
need a `TYPESAFE_API_KEY`; cost would be about ten cents for the set.
Given that a frontier LLM with the same input reaches 0.745 on the
comparator and chance on the items, the open question for Jev is only
whether its decision head beats gpt-6.1-sol on the comparator, not whether
the lens items carry signal. They do not.

## Reproduce

`jev-replay.rb <laya csv>` reads the trial list from the laya CSV so the
readers see the same trials, writes `jev-router-replay-2026-10-04.csv`
(committed); `laya-analyze.rb` prints the AUC tables for either CSV.
Needs `OPENROUTER_API_KEY` in the environment.
