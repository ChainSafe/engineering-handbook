# Daml Reviewer

Language-specific review for Daml PRs. Per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27), Daml is security-critical: this reviewer emits **HARD FAIL** findings for ledger invariants, authorization correctness, upgrade safety, and privacy violations. Override is explicit and logged in the PR with `Override: HARD FAIL <id> for reason <reason>` per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).

> **In one line:** Authorization, atomicity, upgrade safety, privacy. HARD FAIL stops the PR until a CODEOWNER signs off on the override.

## Severity tier

**HARD FAIL.** Override path is explicit and audit-logged. The agent does not push through; the operator does, in writing.

## HARD FAIL checks (reviewer refuses LGTM until resolved or explicitly overridden)

### Authorization

- **Signatory set on a template grants authority to any party** that shouldn't have it. Signatories are creation authorizers; mis-naming opens the contract to forged creation.
- **Controller of a consuming choice is not a signatory or observer** in a way that creates authorization-chain confusion. Verify the controller can actually authorize the choice.
- **`exerciseByKey` or `fetchByKey`** patterns that bypass authorization checks. The key-based variants still respect signatory authorization; misuse here is a security finding.
- **Missing `ensure` clauses** on templates where invariants should be enforced at creation time.
- **`canActAs`/`canReadAs`** delegation that broadens authority beyond what the design intended.

### Atomicity

- **Workflow split across choices where atomicity was required.** Intermediate state visible on the ledger; an attacker could exploit the partial commit.
- **Long-running choice with multiple side-effects** where partial commit semantics aren't documented.
- **Choices that depend on external oracle state** read at submission time without ledger-time bounds — submission-vs-record-time confusion.

### Upgrade safety

- **Template signature changes** (adding/removing/reordering fields, changing types) in a package version that doesn't carry the appropriate `@upgrade` annotations or migration choices.
- **Choices renamed or removed** without a deprecation path. Existing contracts and downstream code break silently.
- **Key structure changes.** Keys are part of the ledger identity; changing them migrates nothing automatically.
- **No migration choice** designed into a template that will need to be upgraded. Adding it later means manual operator workarounds.
- **Package version not bumped** when the template surface changed.

### Privacy

- **Observer set widened beyond design intent.** A new `observer` clause that adds parties without an explicit "why" is leaking visibility.
- **`delegate`/`disclose`** patterns that broaden the implicit visibility surface.
- **Sub-transaction visibility holes** — a private sub-choice that exposes data to a non-stakeholder when fetched.

### Determinism

- **Non-deterministic operations in a choice body** — anything that depends on submission timing, oracle state read mid-choice, or external I/O. Daml choices must be deterministic; non-determinism breaks the ledger.

### Canton-specific (for Canton-deployed contracts)

- **Cross-domain workflow without explicit synchronizer choice** when the contract participates in multiple domains.
- **Sequencer back-pressure assumptions** that don't survive the actual deployment topology.
- **Mediator response time assumptions** baked into the contract logic without justification.

## SOFT WARNING checks (flag, don't block)

- Style and naming.
- Performance optimizations that don't affect correctness.
- Test scenario coverage gaps in non-critical paths.
- Documentation thinness on templates.

## Audit-readiness checklist

A merged Daml PR for production work should be audit-ready:

- [ ] Spec or design doc linked.
- [ ] Threat model named — what's the attacker capability, what's the asset, what's the trust boundary.
- [ ] Scenario / script tests covering happy path + failure modes + authorization edge cases.
- [ ] Privacy review: party-by-party check of what each party can see at each ledger state.
- [ ] Upgrade plan documented — how this version is migrated from the previous, how it's upgraded to the next.
- [ ] Coverage threshold met (project-specific).
- [ ] If Canton-deployed: deployment script and domain governance coordination.

## When the reviewer skill refuses to review

- Non-Daml code in the diff.
- PR description doesn't name the threat model.
- PR introduces template changes without an `@upgrade` strategy or migration choice.
- PR widens observer sets without an inline justification.
- PR changes signatory set without explicit security review.

In each case, escalate to a Daml CODEOWNER and the curator.

## Override mechanics

Per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings):

1. Reviewer skill emits finding with unique identifier.
2. Operator (CODEOWNER) reviews and decides to override.
3. PR description gets `Override: HARD FAIL <id> for reason <reason>` line.
4. Audit log entry (CHANGELOG or equivalent) records the override.
5. Override reviewed in post-merge cycle.

The agent does not override on the operator's behalf. The operator types the override line themselves.

## Phrasing

- Lead with concern and severity: "**HARD FAIL — authorization.** This `choice Withdraw` has `controller alice` but `alice` is not a signatory or observer. The authorization chain is unclear; the choice can't be exercised by `alice` and probably shouldn't be."
- Cite the rule: "Per [Daml reviewer §authorization](#authorization)."
- Reference Canton context where applicable.

## Related

- [`architect.md`](./architect.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md).
- [`../../operating-model/gates-and-escalation.md`](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail) — HARD FAIL gate mechanics.
- [`../../invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).
