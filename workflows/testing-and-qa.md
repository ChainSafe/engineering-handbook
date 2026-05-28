---
title: Testing and QA
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 3_development/3_quality_assurance/qa-principles.md; Forest AI_POLICY.md (lineage from Ghostty)
last_updated: 2026-05-27
---

# Testing and QA

How quality is built into the work — what agents generate, what operators own, where the boundary is, and how Forest's AI policy (carried from Ghostty) shapes the agent-era posture.

> **In one line:** Agents generate the verification artifacts; operators own the verification *judgment*. Both are required; neither substitutes for the other.

## Principles

These carry forward from the legacy QA principles, sharpened:

- **Quality is everyone's responsibility.** Not "the QA team's"; not "the senior reviewer's." Authors, reviewers, operators, and the agents working under them are all on the hook.
- **Plan to succeed.** A definition of "done" before implementation, not after. See [Engineering Invariant §3 — Quality is defined before the build](../invariants/engineering-invariants.md#3-quality-is-defined-before-the-build-not-after).
- **Prevention beats reaction.** Catching a defect in a PR is cheap; catching it in production is expensive; catching it after it costs users is incomparable. Test early and thoroughly on every PR.
- **Be exploratory.** Test across scenarios users actually hit — devices, networks, wallet extensions, edge timing. Lab-only testing misses the field.

## What agents generate

Agents are good at producing verification *surface*. The default expectation when an agent drafts a change:

- **Unit tests** for the new or changed functions, covering the happy path and the obvious edge cases.
- **Property-based tests** where the input space is large or the invariants are formal (cryptographic code, parsing, serialization). Quickcheck/proptest/fast-check style.
- **Fuzz inputs** for code that accepts untrusted input — protocol parsers, RPC handlers, anything taking bytes from the network.
- **Integration scaffolding** — test fixtures, mock servers, recorded traces — that make the operator's own verification cheaper.
- **A test plan in the PR description** stating what was tested, what wasn't, and why.

Agents do these by default because they are easy to generate and hard to skip without losing review-time. If the agent's PR doesn't include any of the above and the change warrants it, the reviewer pushes back.

## What operators own

Some verification cannot be delegated to an agent without losing the point of the verification:

- **Acceptance criteria.** What "shipped" means is an operator decision. If the agent invents the criteria, the criteria match what the agent built — not what was needed.
- **Manual exploratory testing.** "Click around and see if anything feels off" is not an agent task. It's a human pattern-matching against tacit knowledge of how the product should feel. Operators do this for any user-facing change.
- **Security-sensitive paths.** Code that gates authorization, handles secrets, signs transactions, validates user input that hits a privileged path — the operator reviews these by hand, regardless of what the agent's tests claim. See also [agent-era invariant §7 (HARD FAIL bypass)](../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).
- **The decision that tests are sufficient.** An agent can produce 50 tests; whether those 50 tests cover the change is an operator's judgment. Coverage as a number is not the same as coverage as a property.
- **The integration tests that touch real systems.** Anything that exercises a real network, a real database, a real signer — gated by the operator. Agents draft them; operators decide when to run them.

## The Forest / Ghostty pattern

Forest's `AI_POLICY.md` (in [`ChainSafe/forest`](https://github.com/ChainSafe/forest), originally adapted from the [Ghostty](https://github.com/ghostty-org/ghostty) project; attribution preserved in `forest/AI_POLICY.md` and in this repo's [`../NOTICE`](../NOTICE)) sets out a sharp version of the operator-first posture for AI-assisted work in a Filecoin client. The key takeaways carried into this handbook:

- **AI may draft; humans must verify.** Agents may produce tests, but a passing test suite is not a substitute for review. The human reviewer reads what the test actually checks, not just that it passes.
- **AI may not be the sole reviewer of security-critical code.** A reviewer skill HARD FAIL on a security path stops the PR; a human must engage. This is the [HARD FAIL gate](../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail) generalized.
- **AI-authored tests need the same scrutiny as AI-authored code.** A test that asserts "the function was called" rather than "the function did the right thing" is theatre. Operators read test bodies; reviewer skills flag asserting-mock patterns where they can.
- **Documentation, attribution, and provenance are part of quality.** A PR without an AI-generated declaration is a PR with a gap in its audit trail. Quality includes knowing who (or what) wrote what.

Forest extends these into Filecoin-specific norms. The same shape applies across products at ChainSafe — Lodestar, Gossamer, Sygma, Canton — with each product's reviewer skill filling in the language-specific specifics.

## Test types and when to use which

- **Unit tests.** Default. Every non-trivial function, every changed function. Fast, isolated, deterministic.
- **Property-based tests.** When you can state an invariant: "for all valid inputs, this property holds." Strong for parsers, serializers, math, cryptography.
- **Integration tests.** When the unit boundary doesn't catch the bug class. Wire two real components together; mock the rest.
- **End-to-end tests.** For user-facing flows, when a regression there would be visible to users. Run on a schedule, not on every PR (too slow).
- **Fuzz tests.** For attack surfaces. Run continuously in CI for security-critical code.
- **Snapshot tests.** Useful for UI and structured output; brittle if overused. Use when the *shape* is the property you care about; not for everything.
- **Manual exploratory.** Operator-owned (see above).
- **Test plans / manual test cases.** Documented, repeatable, for hard-to-automate scenarios (multi-device, hardware-wallet flows, etc.). Legacy guidance: [`legacy guide on test plans`](https://github.com/ChainSafe/engineering-handbook/blob/v1/3_development/3_quality_assurance/test-plan-guidelines.md).

## What "covered" means

Not 100% line coverage. Not a metric. Instead:

- **Every change is covered to the depth its risk warrants.** A renaming pass needs no new tests. A new authorization check needs unit + integration + a security review.
- **The PR description states what was tested, what wasn't, and why.** If the answer is "I trusted the type system to catch this class of bug," say so explicitly — the reviewer can then agree or push back.
- **Reviewer skills check for thin tests** — assert-counts vs. behavior assertions, mock-heavy tests, etc. See [`code-review.md` mode (b)](./code-review.md#mode-b--agent-reviewing-a-pr).

## Anti-patterns

- **Tests written after the code, to match the code.** Tests need to assert what the code *should* do; if they were written to match what the code *does*, they aren't tests, they're documentation. The plan-first workflow ([`../skills/chainsafe-research-plan-implement/SKILL.md`](../skills/chainsafe-research-plan-implement/SKILL.md)) catches this when followed.
- **Mock-heavy unit tests** that assert which functions were called rather than what changed. Cheap to write, expensive to maintain, low confidence.
- **"It works on my machine" CI bypass.** The CI baseline ([`repo-and-ci-setup.md` §6](./repo-and-ci-setup.md#6-ci)) is the floor. Bypassing it for "small fix" PRs is how the floor gets quiet holes.
- **Operator approves blindly because the tests pass.** This is the failure mode this entire page exists to prevent. Tests are necessary, not sufficient.

## Related

- [`../invariants/engineering-invariants.md`](../invariants/engineering-invariants.md#3-quality-is-defined-before-the-build-not-after) — quality definition before the build.
- [`../invariants/agent-era-invariants.md`](../invariants/agent-era-invariants.md) — particularly §7 (HARD FAIL) and §8 (audit trail).
- [`pr-authoring.md`](./pr-authoring.md) — what the test plan looks like in a PR description.
- [`code-review.md`](./code-review.md) — how the reviewer evaluates test quality.
- [`repo-and-ci-setup.md`](./repo-and-ci-setup.md) — CI baseline that runs the tests.
- Upstream: [Forest `AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — the Filecoin-specific extension of this page's posture.
- [`../references/sources.md`](../references/sources.md) — catalog of the canonical sources this page draws on (Forest, Ghostty lineage).
