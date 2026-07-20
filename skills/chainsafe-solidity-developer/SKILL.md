---
name: chainsafe-solidity-developer
description: Idiomatic Solidity development at ChainSafe — implementation-level guidance for writing Solidity in Sygma and other smart-contract work. Use this skill whenever the user is writing Solidity, asking how to do something in Solidity, implementing a contract function, dealing with reentrancy, access control, external calls, custom errors, storage packing, deployment scripts, Foundry tests (unit/fuzz/invariant), or setting up Solidity tooling. EVEN IF the user does not explicitly say "Solidity" but the file is .sol. Triggers on "write a contract", "implement in Solidity", "fix this contract", "how do I X in Solidity", "Foundry test", "fuzz test", "invariant test", "reentrancy guard", "AccessControl roles", "SafeERC20", "custom error", "Foundry vs Hardhat", "slither", "deploy script". Solidity reviewer is HARD FAIL tier — this skill teaches you to stay out of HARD-FAIL territory. Do NOT use for Solidity design (use chainsafe-solidity-architect) or PR review (use chainsafe-solidity-reviewer).
metadata:
  type: role-workflow
  language: solidity
  role: developer
  source: languages/solidity/developer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Solidity Developer

Idiomatic Solidity at ChainSafe. Reviewer is **HARD FAIL** tier; this skill teaches you to stay out of HARD-FAIL territory. Full reference: [`languages/solidity/developer.md`](../../languages/solidity/developer.md).

## Tooling baselines

- **Foundry preferred** for new projects. `forge`, `cast`, `anvil`.
- **Hardhat** in entrenched projects.
- **Pin pragma:** `pragma solidity 0.8.24;` (not floating `^0.8.0`).
- **OpenZeppelin Contracts** for ERC-20, ERC-721, AccessControl, ReentrancyGuard, Pausable.
- **Solady / Solmate** when gas matters and audit capacity backs gas-tuned code.
- **slither** as a CI baseline. Specific findings muted with `// slither-disable-next-line ... reason: ...` comments.
- **mythril** for symbolic execution on critical contracts.
- **solhint** for style.

## Imports

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
```

- **Named imports** over wildcard `import "..."`.
- **SPDX identifier** at top of every file.

## Checks-Effects-Interactions (the canonical pattern)

```solidity
function withdraw(uint256 amount) external nonReentrant {
    // Checks
    if (amount == 0) revert ZeroAmount();
    if (balances[msg.sender] < amount) revert Insufficient(amount, balances[msg.sender]);

    // Effects
    balances[msg.sender] -= amount;
    totalDeposits -= amount;

    // Interactions
    (bool ok, ) = msg.sender.call{value: amount}("");
    if (!ok) revert TransferFailed();
}
```

Always in this order. `nonReentrant` on every external function calling untrusted code.

## Access control

```solidity
contract Vault is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    function setFee(uint256 newFee) external onlyRole(ADMIN_ROLE) { /* ... */ }
}
```

- `AccessControl` over `Ownable` for multi-action contracts.
- Lock down `DEFAULT_ADMIN_ROLE`.
- Multi-sig (Gnosis Safe) holds privileged roles in production. EOA only in dev/test.
- Timelocks on parameter changes.

## Custom errors (0.8.4+)

```solidity
error Insufficient(uint256 requested, uint256 available);

function withdraw(uint256 amount) external {
    if (balances[msg.sender] < amount) revert Insufficient(amount, balances[msg.sender]);
}
```

Smaller bytecode than `require` strings; structured data for callers.

## External calls

- `.call{value: amount}("")` over `.transfer` / `.send` (which break with new gas pricing).
- Check return values. Unchecked = silent bugs.
- Use OpenZeppelin's `SafeERC20.safeTransfer` / `safeTransferFrom` — normalizes broken ERC-20s like USDT.

## Function visibility

- `external` default for callable-from-outside (saves gas vs `public` for calldata args).
- `public` only when also called internally.
- `internal` for cross-contract-inheritance helpers.
- `private` rarely.

## State variables

- **Pack storage** — group same-size types to share slots.
- `immutable` for constructor-set values.
- `constant` for compile-time-known values.
- Document storage layout for upgradeable contracts; `__gap` reserves slots.

## Testing (Foundry)

- **Unit tests** in `test/*.t.sol`.
- **Fuzz tests** by parameterizing function arguments.
- **Invariant tests** declare properties that must always hold; `forge` finds breaking sequences.
- **Differential tests** against a reference implementation.
- **Mainnet fork tests** for integrations with deployed contracts.

Coverage via `forge coverage`. Security-critical code: 100% line coverage is necessary, not sufficient. Add fuzz + invariant tests.

## CI baseline

- `forge build`
- `forge test -vvv`
- `forge coverage` with threshold (typically 95%+ for security-critical)
- `slither .`
- `solhint 'src/**/*.sol'`
- Mainnet fork tests on schedule
- Gas snapshot via `forge snapshot --check` to catch regressions

## Anti-patterns (most are HARD FAIL findings)

- `tx.origin` for authorization.
- Floating pragma.
- Unbounded loops over user-controlled data.
- State changes after external calls.
- `.transfer` / `.send` for ETH.
- Custom math reimplementing audited primitives.
- `assembly` without justification.
- Owner-key control of production contracts.

## Related

- Full reference: [`languages/solidity/developer.md`](../../languages/solidity/developer.md)
- Idioms: [`languages/solidity/idioms.md`](../../languages/solidity/idioms.md)
- Gotchas: [`languages/solidity/gotchas.md`](../../languages/solidity/gotchas.md)
- Sister roles: `chainsafe-solidity-architect`, `chainsafe-solidity-reviewer` (HARD FAIL tier)
