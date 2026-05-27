---
title: Solidity Idioms
status: draft (v2)
authors:
  - "@kalambet"
language: solidity
last_updated: 2026-05-27
---

# Solidity Idioms

Idiomatic patterns for Solidity at ChainSafe.

## Naming

- **Contracts, interfaces, libraries:** `PascalCase`. Interfaces prefixed `I` (`IERC20`).
- **Functions, variables, modifiers:** `camelCase`.
- **Constants and immutables:** `SCREAMING_SNAKE_CASE`.
- **Events:** `PascalCase`, past-tense verb (`Transferred`, `Upgraded`, `RoleGranted`).
- **Custom errors:** `PascalCase`, descriptive (`InsufficientBalance`, `NotAuthorized`).
- **Files:** `PascalCase.sol`, matching the main contract's name.

## CEI (Checks-Effects-Interactions)

```solidity
function withdraw(uint256 amount) external nonReentrant {
    // Checks
    if (amount == 0) revert ZeroAmount();
    if (balances[msg.sender] < amount) revert Insufficient(amount, balances[msg.sender]);

    // Effects
    balances[msg.sender] -= amount;

    // Interactions
    (bool ok, ) = msg.sender.call{value: amount}("");
    if (!ok) revert TransferFailed();
}
```

Always in this order. Make it a habit; reviewers expect it.

## Custom errors

```solidity
error Insufficient(uint256 requested, uint256 available);
error WrongCaller(address caller, address expected);
error AlreadyInitialized();

function check(uint256 amount) internal view {
    if (amount > balance) revert Insufficient(amount, balance);
}
```

Smaller bytecode than `require("string")`, structured data for callers, clearer at the call site.

## Events for state changes

```solidity
event Deposited(address indexed from, uint256 amount);
event Withdrew(address indexed to, uint256 amount);

function deposit() external payable {
    balances[msg.sender] += msg.value;
    emit Deposited(msg.sender, msg.value);
}
```

Every state-changing privileged action emits an event. Indexed parameters (max 3) make off-chain indexing efficient.

## OpenZeppelin primitives

```solidity
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

contract Vault is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");

    function withdraw(IERC20 token, address to, uint256 amount)
        external
        nonReentrant
        whenNotPaused
        onlyRole(OPERATOR_ROLE)
    {
        token.safeTransfer(to, amount);
    }
}
```

Compose audited primitives instead of reinventing.

## Pull over push

```solidity
mapping(address => uint256) public pendingWithdrawals;

function recordPayment(address recipient, uint256 amount) internal {
    pendingWithdrawals[recipient] += amount;
}

function withdraw() external nonReentrant {
    uint256 amount = pendingWithdrawals[msg.sender];
    if (amount == 0) revert NothingToWithdraw();
    pendingWithdrawals[msg.sender] = 0;
    (bool ok, ) = msg.sender.call{value: amount}("");
    if (!ok) revert TransferFailed();
}
```

Let recipients pull funds rather than pushing transfers. Avoids gas-griefing and reentrancy in many shapes.

## `immutable` for constructor-set values

```solidity
contract Token {
    address public immutable factory;
    uint256 public immutable initialSupply;

    constructor(uint256 _initialSupply) {
        factory = msg.sender;
        initialSupply = _initialSupply;
    }
}
```

`immutable` saves a SLOAD per access vs. regular storage. `constant` for compile-time-known values; `immutable` for constructor-time.

## Storage packing

```solidity
// 1 slot (32 bytes total)
struct Pack1 {
    uint128 a;
    uint64 b;
    uint64 c;
}

// 3 slots
struct Pack2 {
    uint256 a;
    uint128 b;
    uint128 c;
}
```

Group same-size types together. The compiler lays out by declaration order; rearranging can save gas.

## Upgradeable storage with `__gap`

```solidity
contract VaultV1 is Initializable, AccessControlUpgradeable {
    uint256 public totalDeposits;
    mapping(address => uint256) public balances;

    uint256[48] private __gap;  // reserve 48 slots for future fields
}
```

Reserves slots so V2 can add fields without breaking layout. Decrement `__gap` size when you add a real field.

## Custom errors with revert data

```solidity
error Insufficient(uint256 requested, uint256 available);

function transfer(uint256 amount) external {
    if (amount > balance) revert Insufficient(amount, balance);
}
```

The revert data is decodable off-chain — frontends can show "you requested X, only Y available" instead of "transaction failed."

## `using ... for ...`

```solidity
using SafeERC20 for IERC20;

function transferIn(IERC20 token, uint256 amount) internal {
    token.safeTransferFrom(msg.sender, address(this), amount);
}
```

Extends a type with library functions. The classic example is `SafeERC20`.

## Related

- [`developer.md`](./developer.md), [`gotchas.md`](./gotchas.md).
