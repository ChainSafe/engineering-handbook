# Testing and QA

How quality is built into the work — what agents generate, what operators own, where the boundary is, and how Forest's AI policy (carried from Ghostty) shapes the agent-era posture.

> **In one line:** Agents generate the verification artifacts; operators own the verification *judgment*. Both are required; neither substitutes for the other.

## Principles

The core QA principles, sharpened for the agent era:

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

## The test plan, as a section of `plan.md`

In the agentic-first model, there is no standalone "test plan document" filled out once per project. The test plan is a **section of the agent's [`plan.md`](../skills/chainsafe-research-plan-implement/SKILL.md)**, prepared as part of the research-plan-implement workflow before any code lands. The operator reviews it as part of approving the plan. Trying to write a test plan after the implementation is already done is the same anti-pattern as writing acceptance criteria after the build — the plan becomes a description of what was built rather than a check on whether it was right.

The agent answers the following questions explicitly in the plan's test section. The operator's review verifies each is answered substantively, not just listed:

- **What is in scope to test?** A concrete list of the behaviors, units, paths, and edge cases this change introduces or touches. Generic "unit tests for the new function" doesn't count.
- **What level of the test pyramid?** Unit / property-based / integration / end-to-end / fuzz / mainnet-fork. Most changes touch multiple levels; the plan states which and why.
- **What is automated vs manual?** Default: automate everything that can be automated. Anything left to manual testing needs a reason (security-sensitive UX flow, multi-device behavior, hardware-wallet path, etc.) and a manual test case prepared per the next section.
- **What test data is required?** Fixtures, seed data, mainnet snapshots, signer keys, etc. For sensitive data: how it's handled and torn down. For multi-environment work: which data lives where.
- **What test environment runs this?** CI pipeline, local dev, mainnet fork, staging — explicit per test type. If any test requires a non-default environment, the plan names it and links the setup runbook.
- **What are the known risks the tests aren't catching?** This is the most-skipped section and the most useful. Tests cover what the author can imagine; the gap between "what's tested" and "what could go wrong" is where production breaks. Naming the gap explicitly is honest; pretending the test suite is exhaustive is theatre.

When the change is trivial (a typo fix, a one-line lint adjustment), the test plan section can be one line: "no new tests; existing suite covers." That's a valid answer. The point isn't a long plan — it's a deliberate one.

The reviewer skills check that PRs touching non-trivial code paths include this section. PRs without it draw a SOFT WARNING by default and a HARD FAIL for security-critical languages.

## Manual test cases (when automation isn't sufficient)

**Most tests are automated.** Automation is the default — it runs on every PR, costs nothing per execution after authoring, and gives the operator the verification surface they need to review agent-authored code at speed. A manual test case is the exception, not the norm.

A manual test case exists when the test plan (above) identifies a check that can't reasonably be automated. Common reasons:

- A **hardware path** — hardware wallet signing, USB device behavior, multi-device handoff.
- A **privileged action** that can't safely run in CI — mainnet signing, irreversible writes to shared infrastructure, deploys to systems whose state matters.
- A **user-facing flow** where the assertion is "does this feel right" or "does the UI degrade gracefully" — perception-level judgments a script can't make.
- A **multi-system orchestration** whose setup cost outweighs the value of automating — typically one-off integration validations.

If the manual case doesn't fit one of those, it's probably an automation gap, not a manual test. Ask "can this be automated within the next sprint?" before writing it as manual.

### The hard rule

**A manual test case always has step-by-step instructions.** No exceptions. A manual test without explicit steps is a test that won't run — the person running it three months from now (and that person might be future-you, or an on-call engineer at 3am) will not remember what you intended.

The agent never produces a manual test case that lacks steps and assertions. The operator reviewing one without them rejects it and asks for the steps.

### Required structure

Every manual test case has:

| Field | Required? | What it is |
|---|---|---|
| **Title** | Yes | One sentence stating the test's purpose, ending in a verifiable claim. *"User can successfully mint a test ERC-20 on Sepolia from the staging faucet UI"* — not *"Test the faucet"*. |
| **Component** | Yes | Which part of the system: UI, smart contract, validator, CLI, SDK, etc. |
| **Feature** | Yes | The named feature this case verifies. |
| **Environment** | Yes | Where this runs: staging, local, mainnet-fork, devnet, etc. |
| **Why manual?** | Yes | A one-line reason this isn't automated. Forces the question to be answered explicitly; defends against drift. |
| **Steps** | Yes — load-bearing | Numbered, single-action steps. Each one a click, a command, a wait. No collapsing multiple actions into one bullet. |
| **Assertions** | Yes — load-bearing | Numbered, specific success conditions. "Looks right" is not an assertion — name the property: a balance change, a UI element appearing, a log line written, an event emitted. |
| **Test Data** | When applicable | Specific addresses, fixtures, account states, network parameters. |
| **Prerequisites** | When applicable | Setup that must be complete before steps begin: contracts deployed, signer funded, environment provisioned. |
| **Priority** | Optional | If multiple test suites exist, mark which is critical-path vs. nice-to-have. |
| **Notes** | Optional | Tear-down, known flakiness, related tickets — anything not load-bearing for execution. |

### Step granularity

A step is **one action**. Not "go through the wallet flow" — that's a scenario, not a step. The granularity is:

- *Click the "Connect Wallet" button.*
- *Select MetaMask from the wallet list.*
- *Approve the connection in the MetaMask popup.*
- *Wait for the page to display the connected address.*

If a step contains "and then" or "also," split it.

### Assertion specificity

An assertion names **what changed** and **how to verify it**. Each assertion is independently checkable.

- ✗ *"The mint works."* — vague, not verifiable.
- ✓ *"Confirm a transaction-complete confirmation appears on the page within 30s."* — specific event, bounded time.
- ✓ *"Confirm the destination account's balance increased by exactly the minted amount (verify via block explorer)."* — specific quantity, named verification source.

If the test passes, every assertion fires. If any one fails, the test fails. There is no "pass with caveats" — caveats get written up as a new issue.

### When manual becomes automated

A manual test case is a candidate for automation as soon as the conditions that made it manual change. Examples:

- Hardware-wallet flow: when a CI-friendly hardware-wallet emulator is wired in.
- Mainnet-only signing: when a mainnet-fork environment with test signers becomes available.
- UI feel: when a screenshot-diff or visual-regression suite is set up.

The agent (or the operator) periodically reviews the manual-test-case set against these conditions. The reviewer skill flags manual cases that could now plausibly be automated.

### Worked example

```markdown
**Title:** Staging faucet UI can mint a test ERC-20 on Sepolia, end-to-end via MetaMask
**Component:** UI (web), Sepolia ERC-20 faucet contract
**Feature:** Faucet — token mint
**Environment:** Staging (faucet.staging.chainsafe.tech), Sepolia testnet
**Why manual?** Wallet popup interaction can't be CI-automated reliably with our current tooling
**Priority:** Critical (every release)

**Prerequisites:**
- Test ERC-20 contract deployed to Sepolia at the staging-faucet address
- MetaMask installed in the test browser profile, with a test account funded with at least 0.01 Sepolia ETH for gas

**Test Data:**
- Test destination account: 0xdc23f52868...  (do not reuse for other tests)

**Steps:**
1. Navigate to https://faucet.staging.chainsafe.tech in the test browser.
2. Click "Connect Wallet".
3. Select MetaMask from the wallet list.
4. Approve the connection in the MetaMask popup.
5. Wait for the page to display the connected address.
6. From the network dropdown, select "Sepolia".
7. From the token dropdown, select "ERC20Tst".
8. Paste the test destination account address into the "Destination" field.
9. Click "Mint".
10. Approve the transaction in the MetaMask popup.
11. Wait for the page's status indicator to change from "Pending" to "Complete" (typical: ≤30s).

**Assertions:**
1. Confirm the page shows a transaction-complete confirmation, including the tx hash.
2. Confirm, via Sepolia block explorer, the tx hash is mined and shows a Transfer event for the configured amount.
3. Confirm the destination account's ERC20Tst balance increased by exactly the configured amount.
4. Confirm the connected account's Sepolia ETH balance decreased by approximately the displayed gas fee.

**Notes:** Tear-down: the test ERC-20 contract has a public `burn` method — reset the destination account's balance after the test run to keep results comparable across runs.
```

The example is what good looks like: every step is one action, every assertion names a specific verifiable property, the "Why manual?" line defends against future drift toward automation forgetfulness.

## Test types and when to use which

- **Unit tests.** Default. Every non-trivial function, every changed function. Fast, isolated, deterministic.
- **Property-based tests.** When you can state an invariant: "for all valid inputs, this property holds." Strong for parsers, serializers, math, cryptography.
- **Integration tests.** When the unit boundary doesn't catch the bug class. Wire two real components together; mock the rest.
- **End-to-end tests.** For user-facing flows, when a regression there would be visible to users. Run on a schedule, not on every PR (too slow).
- **Fuzz tests.** For attack surfaces. Run continuously in CI for security-critical code.
- **Snapshot tests.** Useful for UI and structured output; brittle if overused. Use when the *shape* is the property you care about; not for everything.
- **Manual exploratory.** Operator-owned (see above).
- **Test plans / manual test cases.** Documented, repeatable, for hard-to-automate scenarios (multi-device, hardware-wallet flows, etc.).

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
