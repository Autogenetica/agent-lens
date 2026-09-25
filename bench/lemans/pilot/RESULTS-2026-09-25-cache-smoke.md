# Lens pilot: prompt-cache smoke for a Haiku run 2

Run 2026-09-25 on the mini. Three baseline trials of ac-throttle-search,
Haiku 4.5 routed through OpenRouter as `openrouter/anthropic/claude-haiku-4.5`,
lemans 1.3.1 with host-side miniswen 1.3.5, docker backend, upstream trial
limits. Nine minutes wall clock, $0.71 total.

## Why

Run 1 (RESULTS-2026-09-22) sent 55M input tokens through Haiku at list
price with zero cached tokens on all 88 trials, and blamed the ruby_llm
path for never setting a cache breakpoint. That was half right. miniswen
already marks the system prompt and the last message with `cache_control`
(`Miniswen::Agent#with_cache_breakpoints`), but only when the provider is
OpenRouter and the model id starts with `anthropic/`. Run 1 used the direct
Anthropic provider, so the gate was closed. The fix is one line in
bench.yml: the same model, through OpenRouter.

## What happened

| trial | checks | steps | input tokens | cached | cache hit | output | cost |
|---|---|---|---|---|---|---|---|
| 1VHxwtI | 4/5 | 48 | 717,947 | 658,834 | 92% | 12,154 | $0.197 |
| 2qD2h9j | 5/5 | 56 | 1,168,675 | 1,109,995 | 95% | 20,062 | $0.281 |
| Uvjqw3z | 4/5 | 54 | 979,757 | 924,206 | 94% | 14,415 | $0.230 |

Mean $0.24 a trial, 53 steps. Same shape as run 1's Haiku trials (62 steps,
$1.33 mean across the baseline arm), so the cheaper number is the cache
and not a shorter trajectory.

Priced without the cache, at $1/M input and $5/M output, these three
trials would have cost $0.78, $1.27 and $1.05: a mean of $1.03, or 4.4x
what they actually cost. Run 1's $117 lands near $27 at that ratio, close
to the $20 the run 1 write-up guessed.

The per-call metrics show where the cache turns on. The first seven calls
of each trial report zero cached tokens; the eighth, at a 4,990-token
prompt, reads 4,439 from cache and every call after that is mostly cached.
That matches a minimum cacheable prefix of about 4k tokens for Haiku 4.5,
so the short early steps pay list price and everything past them rides the
prefix.

## Verdict

The gate fires. Run 2 on Haiku costs a quarter of run 1 with no code change,
and the caching lands on the transcript growth that made Haiku expensive.

The upstream ask (widen `explicit_cache?` to the direct `anthropic` provider
in miniswen) is no longer needed for this bench. It is still a real gap for
anyone billing against an Anthropic key directly, and ruby_llm 1.16's
Anthropic provider accepts the same `cache_control` content, so the change
is small. Worth an issue, not worth blocking on.

Pass rate (1/3 solved, 4/5 checks on the two misses) is noise at this
sample size and not what the smoke was for.
