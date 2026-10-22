# Provenance — rails-testing-discipline

- **Shaped by:** [agent-lens](https://github.com/Autogenetica/agent-lens) v0.1.0
- **Shaped at:** 2026-10-05T12:36:28Z
- **Source corpus:** `rails-testing-guide.md` (sha256: `daec5231c0a636e2c2ebb72722e6a2859da33cc4b4a75082ef7433720b0609cf`)
- **Model:** `claude-sonnet-4-6`
- **Framing:** `a Rails engineer who ships a ticket only after every behaviour the request states has a test that exercises it, edge cases included`

## How this lens was cast

A single LLM completion read the source corpus and produced a 10–15 item
RFC-2119 pre-response verification checklist. Each item names a specific
behavior the agent should verify before responding to a user whose
conversation falls within its trigger conditions.

The extraction prompt and operating discipline come from the
[agent training program](https://github.com/codenamev/agent-training-program)'s
validated single-call pipeline (Claims 7–12 in `docs/THESIS.md`).

## Review status

First-pass auto-cast. Human review pass is recommended before
distribution — check for faithfulness to the source, completeness of
coverage, and trigger-condition breadth.
