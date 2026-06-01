# Solidity Architect

Architectural guidance for Solidity (and EVM-adjacent) work at ChainSafe — [Sygma](https://github.com/sygmaprotocol) and the broader crypto/bridging surface. The architectural framework is `.invariance` (see the [pointer page](../../invariants/invariance-framework.md)); this page covers Solidity-specific shaping.

> **In one line:** Every Solidity decision is a security decision. Upgrade safety, reentrancy, and audit-readiness are first-class architectural concerns.

## Defer to `.invariance` for

| Decision | `.invariance` section |
|---|---|
| Cross-contract contracts and invariants | Component contracts *[anchor pending — @boorich]* |
| Upgrade lifecycle invariants | Lifecycle / migration invariants *[anchor pending — @boorich]* |
| Authorization invariants | Authorization model *[anchor pending — @boorich]* |
| Bridge / cross-chain invariants | Cross-chain invariants *[anchor pending — @boorich]* |

## Solidity-specific architectural choices

Reviewer skills for Solidity are **HARD FAIL tier** per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27). Architecture decisions that don't anticipate this will get blocked at review.

### Project layout

ChainSafe Solidity projects use Foundry (preferred) or Hardhat. Layout:

- `src/` (Foundry) or `contracts/` (Hardhat) — Solidity sources, split by domain.
- `test/` — Foundry-style fuzz and unit tests, or Hardhat tests in JS/TS.
- `script/` — deployment and operations scripts.
- `lib/` — vendored libraries (OpenZeppelin, Solady, Solmate, etc.).
- `foundry.toml` / `hardhat.config.ts` at the root.

For multi-contract systems, group by domain (`bridge/`, `tokens/`, `governance/`) not by file kind.

### Upgrade strategy

Pick one at design time:

- **Immutable.** No upgrade path. Simplest, safest, locks in mistakes forever.
- **UUPS (Universal Upgradeable Proxy Standard).** Logic contract holds the upgrade method; thinner proxy. Requires authorization for `upgradeTo`.
- **Transparent proxy.** Admin/user separation handled by the proxy; familiar from OpenZeppelin tooling.
- **Diamond (EIP-2535).** Multi-facet, modular. Powerful, complex, more surface to audit.

The decision is binding for the contract's life. Migrating between upgrade strategies is itself a migration risk. Default to **immutable** unless you have a concrete reason for upgradeability.

### Access control

- **OpenZeppelin `AccessControl`** for role-based authorization in most cases.
- **`Ownable`** only for genuinely-single-owner cases. Owner key compromise is total compromise.
- **Multi-sig** (Gnosis Safe) for any production deployment's privileged operations. Single-key control of production contracts is a finding.
- **Timelocks** on upgrade and parameter changes. Gives stakeholders time to react.

### Reentrancy posture

- **Checks-Effects-Interactions** pattern, always. State changes happen before external calls.
- **OpenZeppelin `ReentrancyGuard`** on every external function that calls untrusted contracts (transfers, callbacks, etc.).
- **Pull over push** for payments where reasonable — let recipients withdraw rather than pushing transfers.

### External calls

- **Address every call's failure mode.** What happens if the call reverts? Returns wrong data? Reentrancy?
- **`.transfer` and `.send` are deprecated**; use `.call{value: amount}("")` and check the return value.
- **Approval-then-transfer patterns** for ERC-20: be aware of the classic approval race; use `safeIncreaseAllowance` / `safeDecreaseAllowance` from OpenZeppelin.

### Bridge-specific invariants (Sygma context)

For cross-chain code:

- **Consistent state across chains** — what invariant is the bridge maintaining?
- **Replay protection** — message uniqueness via nonces, domain separators, or both.
- **Failure mode for the destination chain** — what happens if delivery fails or is censored?
- **Slashing / signer-set rotation** — how do signer changes propagate?

Each becomes an `.invariance` entry; reviewer skills check them per-PR.

## ADR shape for Solidity contracts

Every non-trivial Solidity ADR covers:

- **Upgrade strategy.** Immutable / UUPS / Transparent / Diamond. Justification.
- **Access control model.** Roles, role-granting, role-renouncing, multi-sig vs. EOA.
- **External-call surface.** Which functions make external calls; what's the reentrancy posture.
- **Storage layout.** For upgradeable contracts, storage layout is part of the contract; ADR documents the layout and the gap pattern.
- **Audit plan.** When the contract is audited (pre-deploy, post-deploy, recurring), by whom.
- **Test coverage commitments.** Unit, fuzz, invariant tests, formal verification if applicable.
- **Invariants impacted.** Deep links into `.invariance`.

## Anti-patterns

- **Owner key controls production contracts.** Use a multi-sig.
- **Upgrade path with no timelock.** Stakeholders need time to react.
- **State changes after external calls.** Reentrancy waiting to happen.
- **`tx.origin` for authorization.** Use `msg.sender`.
- **Unbounded loops over caller-controlled data.** Gas-griefing waiting to happen.
- **Custom math instead of OpenZeppelin SafeMath / Solady.** Reinventing audited primitives.
- **`assembly` blocks without inline justification.** Same standard as Rust `unsafe`.

## Related

- [`developer.md`](./developer.md), [`reviewer.md`](./reviewer.md) (HARD FAIL tier), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md) — security-sensitive path discipline.
- [`../../invariants/invariance-framework.md`](../../invariants/invariance-framework.md).
