---
title: Solidity Developer
status: draft (v2)
authors:
  - "@kalambet"
language: solidity
role: developer
last_updated: 2026-05-27
---

# Solidity Developer

Idiomatic Solidity development at ChainSafe. Tooling, testing, common patterns, and the discipline that keeps PRs out of HARD-FAIL territory at review.

> **In one line:** Foundry for new work. Tests are fuzz + invariant by default. OpenZeppelin for primitives. Every external call is a security decision.

## Tooling

### Toolchain

- **Foundry** for new projects. `forge` for tests and builds, `cast` for chain interaction, `anvil` for local nodes.
- **Hardhat** in projects where it's already entrenched. Don't migrate without reason.
- **Pin the Solidity version** in `foundry.toml` / `hardhat.config.ts` and at the top of every contract:
  ```solidity
  pragma solidity 0.8.24;
  ```
  Floating pragmas (`^0.8.0`) are a smell — they make audit findings ambiguous and CI non-deterministic.

### Dependencies

- **OpenZeppelin Contracts** for standard primitives (ERC-20, ERC-721, AccessControl, ReentrancyGuard, etc.).
- **Solady** or **Solmate** when gas optimization matters and you have the audit capacity to back gas-tuned code.
- **Vendor via git submodule** (Foundry default) or **npm package** (Hardhat). Pin to specific versions; don't track `main`.

### Static analysis

- **slither** as a baseline. Runs in CI; specific rules can be muted with `// slither-disable-next-line ...` + a comment.
- **mythril** for symbolic execution on critical contracts.
- **solhint** for style.

These are required CI checks, not optional.

## Code structure

### Imports

```solidity
// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
```

- **Named imports** (`import {Foo} from "..."`) over wildcard `import "..."`. Clear what's imported; helps audit.
- **SPDX identifier** at the top of every file. Apache 2.0 to match the repo, or per-project license if different.

### Function visibility

- **`external`** by default for callable-from-outside functions; saves gas vs. `public` for calldata-sized args.
- **`public`** when the function is also called internally.
- **`internal`** for cross-contract-inheritance helpers.
- **`private`** rarely; `internal` is usually right for inheritance.

### State variables

- **Pack storage** — group same-size types together to share slots.
- **`immutable`** for values set once in the constructor (saves storage reads).
- **`constant`** for compile-time-known values.
- **Document storage layout** for upgradeable contracts (`__gap` array reserves slots for future fields).

## Reentrancy and external calls

```solidity
function withdraw(uint256 amount) external nonReentrant {
    // Checks
    require(amount > 0, "WrongAmount");
    require(balances[msg.sender] >= amount, "Insufficient");

    // Effects
    balances[msg.sender] -= amount;
    totalDeposits -= amount;

    // Interactions
    (bool ok, ) = msg.sender.call{value: amount}("");
    require(ok, "TransferFailed");
}
```

- **`nonReentrant`** on every external function that calls untrusted code.
- **Checks-Effects-Interactions** as a rigid pattern. State changes before external calls. Always.
- **`.call{value: ...}("")` over `.transfer` / `.send`** — those have hard gas limits that break with new opcode gas costs.
- **Check return values.** A failed call that you don't check is a silent bug.
- **Use OpenZeppelin's `SafeERC20`** for token transfers. Standard ERC-20 implementations differ; SafeERC20 normalizes.

## Access control

```solidity
contract Vault is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");

    function setFee(uint256 newFee) external onlyRole(ADMIN_ROLE) {
        // ...
    }
}
```

- **`AccessControl`** over `Ownable` for any contract with more than one privileged action.
- **Role-grant authority** is itself a privileged action; lock down `DEFAULT_ADMIN_ROLE`.
- **Multi-sig** holds privileged roles in production; EOAs are for dev/test only.
- **Timelocks** on parameter changes and upgrades.

## Errors

Custom errors over `require` strings (Solidity 0.8.4+):

```solidity
error Insufficient(uint256 requested, uint256 available);
error WrongCaller(address caller);

function withdraw(uint256 amount) external {
    if (balances[msg.sender] < amount) revert Insufficient(amount, balances[msg.sender]);
    // ...
}
```

- Smaller bytecode than `require` strings.
- Structured data the caller can decode.
- `require(condition, "Message")` is acceptable for very simple cases but the trend is toward custom errors.

## Testing

Foundry's testing model is the baseline:

- **Unit tests** in `test/*.t.sol`.
- **Fuzz tests** by parameterizing function arguments — `forge` fuzzes by default.
- **Invariant tests** — declare a property that should always hold, `forge` finds sequences that break it.
- **Differential tests** against a reference implementation (Yul, Vyper, off-chain) when one exists.
- **Mainnet fork tests** for integrations with deployed contracts.

```solidity
function testFuzz_Withdraw(uint256 amount) public {
    vm.assume(amount > 0 && amount <= INITIAL_DEPOSIT);
    vault.deposit{value: amount}();
    vault.withdraw(amount);
    assertEq(vault.balanceOf(address(this)), 0);
}
```

Coverage via `forge coverage`. The bar for security-critical code is high — 100% line coverage is necessary, not sufficient (you also need fuzz and invariant tests).

## Deployment

- **Deployment scripts** in `script/` (Foundry) or `deploy/` (Hardhat). Reproducible from source.
- **Verified source** on the relevant block explorer (Etherscan, Sourcify) for every public deployment.
- **Audit before public deployment** for any contract holding value. The architect ADR names the audit plan.
- **Constructor args recorded** alongside the deployment script, for verification.

## CI

Baseline (extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md)):

- `forge build`
- `forge test -vvv`
- `forge coverage` with a threshold (typically 95%+ for security-critical code)
- `slither .`
- `solhint 'src/**/*.sol'`
- Mainnet fork tests on a schedule (every PR if cheap, daily if expensive)
- Gas snapshot via `forge snapshot --check` to catch gas regressions

## Anti-patterns

- **`tx.origin` for authorization.** Always `msg.sender`.
- **Floating pragma** (`^0.8.0`). Pin the version.
- **Unbounded loops over user-controlled data.** Gas griefing.
- **State changes after external calls.** Reentrancy.
- **`.transfer` / `.send` for ETH transfers.** Use `.call{value:}("")`.
- **Custom math reimplementing audited primitives.** Use OpenZeppelin / Solady.
- **`assembly` without inline justification.** Auditor will flag.
- **Owner-key control of production contracts.** Multi-sig.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md) **(HARD FAIL tier)**, [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md).
