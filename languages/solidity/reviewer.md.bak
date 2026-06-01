# Solidity Reviewer

Language-specific review for Solidity PRs. Per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27), Solidity reviewer findings emit at **HARD FAIL** severity for security-critical checks. The agent reports; the operator decides; bypass is logged in the PR with an explicit `Override: HARD FAIL X for reason Y` per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).

> **In one line:** Reentrancy, upgrade safety, access control, audit-readiness. HARD FAIL findings stop the PR until a CODEOWNER signs off on the override.

## Severity tier

**HARD FAIL.** Override path is explicit and audit-logged in the PR. The agent does not push through; the operator does, in writing.

## HARD FAIL checks (reviewer refuses LGTM until resolved or explicitly overridden)

### Reentrancy

- **State changes after external calls.** Any `.call`, `.delegatecall`, ERC-20 transfer, token callback, or call to an arbitrary address with state mutations after it.
- **Missing `nonReentrant`** on external functions that call untrusted contracts (transfers, callbacks, hooks).
- **Cross-function reentrancy.** A function that doesn't itself make external calls but shares state with one that does, without proper guards.

### Authorization

- **`tx.origin` used for authorization.** Always a HARD FAIL. Use `msg.sender`.
- **Privileged function without access control modifier.** Every state-changing function with privileged effects must have an explicit `onlyRole` / `onlyOwner` / equivalent.
- **`onlyOwner` on a contract holding non-trivial value** without a multi-sig path. The architect ADR named the multi-sig requirement; the implementation must honor it.
- **Role grant power not locked down.** `DEFAULT_ADMIN_ROLE` (in OpenZeppelin `AccessControl`) is the most powerful role; it must be held by a multi-sig and protected by a timelock.

### Upgrade safety (for upgradeable contracts)

- **Storage layout changes** between versions. Each storage variable in an upgradeable contract is addressed by slot; reordering or inserting non-appended variables corrupts state. Every PR touching an upgradeable contract is checked against the prior storage layout.
- **`initializer` discipline.** Upgradeable contracts use `initialize` instead of constructors; missing `initializer` modifier or skipping the parent initializer is a HARD FAIL.
- **Missing `__gap` reserved slots** for upgradeable base contracts.
- **`UUPSUpgradeable._authorizeUpgrade`** must restrict access. Missing or weak authorization = total contract control bypass.
- **No timelock** on the upgrade path for production contracts.

### External calls

- **Unchecked return values.** `.call{value:}("")` that doesn't check `ok`. `IERC20.transfer` that doesn't check return (use `SafeERC20`).
- **`.transfer` / `.send`** with hard-coded 2300 gas — breaks with EIP-1884 and similar gas changes. Use `.call`.
- **Unbounded gas forwarding to untrusted contracts** in critical paths.
- **`delegatecall` to caller-controlled addresses.** Can rewrite the caller's storage.

### Arithmetic

- **`unchecked { ... }` blocks** without inline justification. Solidity 0.8+ has overflow checks by default; removing them is a deliberate choice that needs a comment.
- **Custom math** instead of OpenZeppelin / Solady. Reinventing wheels invites bugs auditors have already caught upstream.

### `assembly` / Yul

- **`assembly` without an inline justification.** Same standard as Rust `unsafe`. Comment explains why assembly, what the invariants are, and how they're verified.
- **`assembly` reading from user-controlled storage slots** without explicit reasoning.

### Bridge / cross-chain (Sygma context)

- **Missing nonce / replay protection** on cross-chain messages.
- **Trust assumptions on signer sets** that don't survive signer-set rotation.
- **No failure mode** for messages that can't be delivered on the destination chain (lost funds risk).
- **Inconsistent state model** between source and destination contracts.

## SOFT WARNING checks (flag, don't block)

- Style and naming.
- Gas optimizations that don't affect correctness (suggest, don't require).
- Test coverage gaps in non-critical paths.
- Documentation thinness.
- `solhint` style violations.

## Audit-readiness checklist

A PR introducing or substantially changing a contract should be audit-ready by the time it merges:

- [ ] **Spec or design doc** linked in the PR description.
- [ ] **Threat model** named — what's the attacker capability, what's the asset, what's the boundary.
- [ ] **Unit tests + fuzz tests + invariant tests** for the changed surface.
- [ ] **Slither clean** or muted findings with explicit `// slither-disable-next-line ... reason: ...` comments.
- [ ] **Coverage threshold met** (typically 95%+).
- [ ] **Gas snapshot diff** intentional (regressions justified).
- [ ] **Storage layout diff** for upgradeable contracts, attached to the PR.
- [ ] **Deployment script** if the contract is deployable from this PR.

If the PR is in scope for a scheduled audit, the audit firm gets an artifact bundle (spec, tests, deployment script) — the PR should produce that bundle without extra work.

## When the reviewer skill refuses to review

- Non-Solidity code in the diff.
- PR description doesn't name the threat model.
- PR introduces a privileged function without access control modifiers.
- PR changes storage layout of an upgradeable contract without a layout-diff in the description.
- PR is making a deployment-affecting change without a deployment script.

In each case, escalate to a Solidity CODEOWNER and the curator.

## Override mechanics

Per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings), HARD FAIL bypass requires:

1. The reviewer skill emits the finding with a unique identifier.
2. The operator (CODEOWNER) reviews and decides to override.
3. The PR description gets an `Override: HARD FAIL <id> for reason <reason>` line.
4. A separate audit-log entry is created (CHANGELOG or similar) recording the override.
5. The override is reviewed in the post-merge cycle.

The agent does not override on the operator's behalf. The operator types the override line themselves.

## Phrasing

- Lead with the concern and its severity: "**HARD FAIL — reentrancy.** This function transfers ETH via `.call{value:}` and then updates `balances`. CEI requires balance update first."
- Cite the rule: "Per [Solidity reviewer §reentrancy](#reentrancy)."
- Reference the auditor's perspective: "An auditor reviewing this would flag the missing `nonReentrant` immediately; the override mechanics exist for exceptions, not for the default path."

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md).
- [`../../operating-model/gates-and-escalation.md`](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail) — HARD FAIL gate mechanics.
- [`../../invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).
