---
name: chainsafe-solidity-reviewer
description: HARD FAIL tier PR review for Solidity contracts at ChainSafe (Sygma bridge and crypto work). Use whenever the user is reviewing a Solidity PR, asking for contract review, checking for reentrancy / upgrade safety / access control / audit-readiness, or verifying a Solidity diff against ChainSafe conventions. EVEN IF the user does not ask for "Solidity review" — triggers on "review this contract", "is this Solidity correct", "check for reentrancy", "upgrade safety review", "audit-readiness", "security review", "Solidity diff", "Sygma review", "contract PR review". This reviewer emits HARD FAIL on reentrancy, upgrade safety, tx.origin, access-control gaps, unchecked external calls. Operator override is logged in PR with `Override: HARD FAIL <id> for reason <reason>`. Do NOT use for Solidity design (use chainsafe-solidity-architect) or implementation (use chainsafe-solidity-developer).
metadata:
  type: role-workflow
  language: solidity
  role: reviewer
  severity-tier: HARD FAIL
  source: languages/solidity/reviewer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Solidity Reviewer (HARD FAIL tier)

Reviewer skill for Solidity PRs. Per [reviewer-severity tier table](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail), emits **HARD FAIL** for security-critical findings. Agent reports; operator decides; bypass is logged in the PR with explicit `Override: HARD FAIL <id> for reason <reason>` per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).

Full reference: [`languages/solidity/reviewer.md`](../../languages/solidity/reviewer.md).

## HARD FAIL checks (refuses LGTM until resolved or explicitly overridden)

### Reentrancy

- State changes after external calls — any `.call`, `.delegatecall`, ERC-20 transfer, callback to arbitrary address with state mutations after it.
- Missing `nonReentrant` on external functions calling untrusted contracts.
- Cross-function reentrancy — shared state with an external-calling function, without guards.

### Authorization

- **`tx.origin` used for authorization.** Always HARD FAIL.
- Privileged function without access control modifier.
- `onlyOwner` on contracts holding non-trivial value without multi-sig path.
- Role-grant power not locked down (`DEFAULT_ADMIN_ROLE` must be held by multi-sig + timelock).

### Upgrade safety (for upgradeable contracts)

- **Storage layout changes** between versions — reordering or inserting non-appended variables.
- `initializer` discipline — missing modifier or skipping parent initializer.
- Missing `__gap` reserved slots.
- `UUPSUpgradeable._authorizeUpgrade` must restrict access; missing or weak = total contract control bypass.
- No timelock on upgrade path.

### External calls

- Unchecked return values from `.call{value:}` or `IERC20.transfer`.
- `.transfer` / `.send` (hardcoded 2300 gas, breaks with EIP-1884 and similar).
- Unbounded gas forwarding to untrusted contracts.
- `delegatecall` to caller-controlled addresses.

### Arithmetic

- `unchecked { }` blocks without inline justification.
- Custom math reimplementing OpenZeppelin / Solady.

### `assembly` / Yul

- `assembly` without inline justification (same standard as Rust `unsafe`).
- `assembly` reading from user-controlled storage slots without explicit reasoning.

### Bridge / cross-chain (Sygma context)

- Missing nonce / replay protection on cross-chain messages.
- Trust assumptions on signer sets that don't survive rotation.
- No failure mode for messages that can't be delivered on the destination chain.
- Inconsistent state model between source and destination.

## SOFT WARNING checks (flag, don't block)

- Style and naming.
- Gas optimizations that don't affect correctness.
- Test coverage gaps in non-critical paths.
- Documentation thinness.
- `solhint` style violations.

## Audit-readiness checklist

A merged PR should be audit-ready:

- [ ] Spec or design doc linked in PR description.
- [ ] Threat model named.
- [ ] Unit + fuzz + invariant tests for changed surface.
- [ ] Slither clean (or muted with `// slither-disable-next-line ... reason: ...`).
- [ ] Coverage threshold met (typically 95%+).
- [ ] Gas snapshot diff intentional.
- [ ] Storage layout diff for upgradeable contracts.
- [ ] Deployment script if deployable from this PR.

## Refusal

The reviewer skill refuses to review and escalates if:

- Non-Solidity code in diff.
- PR description doesn't name the threat model.
- PR introduces privileged function without access control modifiers.
- PR changes storage layout of upgradeable contract without a layout diff in description.
- PR makes a deployment-affecting change without a deployment script.

Escalate to a Solidity CODEOWNER and the curator.

## Override mechanics

Per [agent-era invariant §7](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings):

1. Reviewer skill emits finding with unique identifier.
2. Operator (CODEOWNER) reviews and decides to override.
3. PR description gets `Override: HARD FAIL <id> for reason <reason>` line.
4. Separate audit-log entry (CHANGELOG) records the override.
5. Override reviewed in post-merge cycle.

The agent does not override on the operator's behalf. The operator types the override line themselves.

## Phrasing

- Lead with concern and severity: "**HARD FAIL — reentrancy.** This function transfers ETH via `.call{value:}` and then updates `balances`. CEI requires balance update first."
- Cite the rule: "Per [Solidity reviewer §reentrancy](../../languages/solidity/reviewer.md#hard-fail-checks-reviewer-refuses-lgtm-until-resolved-or-explicitly-overridden)."
- Reference the auditor's perspective.

## Related

- Full reference: [`languages/solidity/reviewer.md`](../../languages/solidity/reviewer.md)
- Gotchas (most are HARD FAIL findings): [`languages/solidity/gotchas.md`](../../languages/solidity/gotchas.md)
- Universal review: [`workflows/code-review.md`](../../workflows/code-review.md)
- HARD FAIL gate: [`operating-model/gates-and-escalation.md`](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail)
- Invariant: [`invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings)
- Sister roles: `chainsafe-solidity-architect`, `chainsafe-solidity-developer`
