---
name: chainsafe-solidity-architect
description: Architectural guidance for designing Solidity contracts and EVM systems at ChainSafe (Sygma bridge and broader crypto work). Use whenever the user starts a new contract, designs a contract system, picks an upgrade strategy (immutable / UUPS / Transparent / Diamond), chooses access control (Ownable vs AccessControl, multi-sig, timelocks), designs reentrancy posture, plans a deployment, or writes an ADR for Solidity work. EVEN IF the user does not say "architecture" — triggers on "design a contract", "Sygma bridge architecture", "upgrade strategy", "UUPS or Transparent", "multi-sig setup", "access control design", "reentrancy strategy", "audit plan", "deployment plan", "bridge invariants", "cross-chain replay", "storage layout upgradeable". Every Solidity decision is a security decision. Do NOT use for line-level Solidity (use chainsafe-solidity-developer) or PR review (use chainsafe-solidity-reviewer).
metadata:
  type: role-workflow
  language: solidity
  role: architect
  source: 30-languages/solidity/architect.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Solidity Architect

Use this when designing Solidity systems at ChainSafe — Sygma-shaped work or any contract. **Every decision here is a security decision.** The reviewer skill is HARD FAIL tier. Architecture that doesn't anticipate that will get blocked. Full reference: [`30-languages/solidity/architect.md`](../../30-languages/solidity/architect.md).

## Key Solidity-specific decisions

### Project layout

- Foundry preferred for new projects. Hardhat only where entrenched.
- `src/` (Foundry) or `contracts/` (Hardhat), grouped by domain (`bridge/`, `tokens/`, `governance/`).
- `test/` for tests, `script/` for deploy/ops, `lib/` for vendored libraries (OpenZeppelin, Solady, Solmate).
- `foundry.toml` / `hardhat.config.ts` at the root.

### Upgrade strategy (binding for the contract's life)

- **Immutable.** No upgrade path. Simplest and safest; locks in mistakes forever. **Default unless you have a concrete reason for upgradeability.**
- **UUPS** (Universal Upgradeable Proxy Standard). Logic contract holds the upgrade method; requires authorization for `upgradeTo`.
- **Transparent proxy.** Admin/user separation in the proxy; familiar from OpenZeppelin tooling.
- **Diamond (EIP-2535).** Multi-facet, modular; more surface to audit.

Migrating between upgrade strategies is itself a migration risk. Pick once.

### Access control

- **OpenZeppelin `AccessControl`** for role-based authorization in most cases.
- **`Ownable` only for genuinely-single-owner cases.** Owner-key compromise is total compromise.
- **Multi-sig (Gnosis Safe)** for any production deployment's privileged operations. Single-key control of production = finding.
- **Timelocks** on upgrades and parameter changes. Gives stakeholders time to react.

### Reentrancy posture

- **Checks-Effects-Interactions** pattern, rigid. State changes before external calls.
- **OpenZeppelin `ReentrancyGuard`** on every external function that calls untrusted contracts.
- **Pull over push** for payments where reasonable.

### External calls

- Address every call's failure mode (revert, wrong return, reentrancy).
- `.transfer` and `.send` deprecated; use `.call{value:}("")` and check return.
- Approval-then-transfer for ERC-20: be aware of the classic approval race; use `safeIncreaseAllowance` / `safeDecreaseAllowance`.

### Bridge-specific (Sygma)

- Consistent state across chains — what invariant is the bridge maintaining?
- Replay protection via nonces, domain separators, or both.
- Failure mode for destination chain — what happens if delivery fails or is censored?
- Slashing / signer-set rotation — how do signer changes propagate?

## ADR template for Solidity work

- Upgrade strategy — immutable / UUPS / Transparent / Diamond. Justify.
- Access control model — roles, granting, renouncing, multi-sig vs EOA.
- External-call surface — which functions, reentrancy posture.
- Storage layout — slot map for upgradeable; gap pattern.
- Audit plan — when, by whom, recurring vs pre-deploy.
- Test coverage commitments — unit, fuzz, invariant, formal verification.
- Invariants impacted — deep links into `.invariance`.

## Anti-patterns at design time

- Owner key controls production contracts. Use a multi-sig.
- Upgrade path with no timelock.
- State changes after external calls.
- `tx.origin` for authorization.
- Unbounded loops over caller-controlled data (gas griefing).
- Custom math instead of OpenZeppelin / Solady.
- `assembly` blocks without inline justification.

## Related

- Full reference: [`30-languages/solidity/architect.md`](../../30-languages/solidity/architect.md)
- Sister roles: `chainsafe-solidity-developer`, `chainsafe-solidity-reviewer` (HARD FAIL tier)
- Workflow: `chainsafe-research-plan-implement`
