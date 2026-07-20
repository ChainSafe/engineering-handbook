# Solidity Gotchas

Bug classes and surprising behavior in Solidity. Most of these are HARD FAIL findings under the [reviewer](./reviewer.md).

## Reentrancy (the classic)

```solidity
function withdraw() external {
    uint256 amount = balances[msg.sender];
    (bool ok, ) = msg.sender.call{value: amount}("");   // external call BEFORE state update
    require(ok);
    balances[msg.sender] = 0;                            // attacker can reenter before this
}
```

`msg.sender` can be a contract whose receive function calls back into `withdraw`. Always: Checks-Effects-Interactions.

## Cross-function reentrancy

```solidity
function depositA() external payable { balanceA[msg.sender] += msg.value; }
function withdrawB() external {
    uint256 amount = balanceB[msg.sender];
    msg.sender.call{value: amount}("");
    balanceB[msg.sender] = 0;
}
```

`withdrawB` is reentrant into `depositA` even though `depositA` itself doesn't make external calls. State shared across functions needs guarding too.

## `tx.origin` for authorization

```solidity
modifier onlyOwner() {
    require(tx.origin == owner);   // ALWAYS WRONG
    _;
}
```

`tx.origin` is the original EOA that started the transaction; any intermediate contract is `msg.sender`. A malicious contract the owner interacts with can call your contract during the same transaction. Use `msg.sender`.

## Floating pragma

```solidity
pragma solidity ^0.8.0;
```

Different compilers may produce different bytecode for the same source. Audit findings refer to specific compiler behavior. Pin: `pragma solidity 0.8.24;`.

## Unchecked `.transfer` / `.send`

```solidity
payable(recipient).transfer(amount);  // hardcoded 2300 gas; breaks with new opcode pricing
payable(recipient).send(amount);      // 2300 gas + returns bool you might ignore
```

Use `.call`:

```solidity
(bool ok, ) = payable(recipient).call{value: amount}("");
require(ok, "TransferFailed");
```

## ERC-20 `transfer` return value ignored

```solidity
IERC20(token).transfer(recipient, amount);   // some tokens return false instead of revert
```

Not all ERC-20s revert on failure (USDT famously doesn't return a bool at all). Use `SafeERC20.safeTransfer` / `safeTransferFrom`.

## Approval race condition

```solidity
token.approve(spender, oldAmount);
// attacker uses oldAmount
token.approve(spender, newAmount);
// attacker can now use newAmount as well — they got oldAmount + newAmount
```

Use `safeIncreaseAllowance` / `safeDecreaseAllowance` from OpenZeppelin, or approve to 0 before changing.

## Integer arithmetic edge cases (Solidity < 0.8)

Pre-0.8 Solidity wraps integer overflow silently. ChainSafe contracts should be ≥0.8 — if you find <0.8 code, it's a HARD FAIL until upgraded or wrapped with SafeMath.

## `unchecked` blocks

```solidity
unchecked { x = a + b; }   // overflow possible
```

`unchecked` removes overflow checks. Use only when you've proven overflow is impossible (e.g., loop counters bounded by storage). Comment why.

## `delegatecall` storage corruption

```solidity
contract A {
    address public owner;        // slot 0
}
contract B {
    bool public initialized;     // slot 0
    function init() external { A(target).delegatecall(...); }   // writes through to A's slot 0
}
```

`delegatecall` runs target code in the caller's storage context. Storage layout differences corrupt state. Only use with libraries that explicitly support delegatecall and whose storage layouts you control.

## Unbounded loops

```solidity
function distribute(address[] calldata recipients) external {
    for (uint256 i = 0; i < recipients.length; i++) {
        recipients[i].call{value: amount}("");
    }
}
```

Gas griefing: caller passes a huge array, transaction reverts out-of-gas, function is permanently unusable for any caller. Bound the loop or use pull-payment.

## Storage layout drift in upgradeable contracts

```solidity
// V1
contract V1 { uint256 totalDeposits; mapping(address => uint256) balances; }

// V2 — INSERTS a new field at top, shifts every existing field
contract V2 { uint256 fee; uint256 totalDeposits; mapping(address => uint256) balances; }
```

The proxy's storage is now interpreted with the V2 layout, but the actual storage was written under V1's layout. Existing balances become "fees." Catastrophic. Append-only, use `__gap`, and verify layout diff.

## Missing `initializer` modifier

```solidity
contract Upgradeable is Initializable {
    function initialize() external {   // missing `initializer` modifier
        owner = msg.sender;
    }
}
```

Without `initializer`, the function can be called repeatedly — anyone can become owner after the first init.

## `private` is not private

`private` and `internal` only restrict Solidity-level access. The actual storage is readable from off-chain via `eth_getStorageAt`. Don't store secrets in contract storage; they're public.

## Selector collision in proxy patterns

When a proxy delegates to a logic contract, the proxy's own functions can collide with the logic contract's selectors (4-byte hash of the signature). Transparent and UUPS proxies handle this differently. Be aware which you're using.

## `msg.value` in non-payable functions

```solidity
function foo() external { /* msg.value reverts */ }
```

`msg.value` is always zero for non-payable functions, but trying to call with ETH attached reverts before entering. Mark functions `payable` only when they should accept ETH.

## Block-based timing as authority

```solidity
if (block.timestamp > deadline) { /* ... */ }
```

`block.timestamp` is manipulable by miners within a small window. Don't use for randomness; don't use for short-window authorization. Bounds are typically ±15 seconds.

## `block.number` and chain reorgs

L1 reorgs are rare but happen. L2 reorgs are more common. Don't assume `block.number` ordering is final until enough confirmations.

## Forgetting events on critical state changes

State changes without events are invisible to off-chain indexers, dashboards, and security monitors. Emit events for every privileged action.

## Constructor in upgradeable contracts

Constructors run on the logic contract, not the proxy. Any state set in a constructor is lost from the proxy's perspective. Use `initialize` + `initializer` modifier.

## Related

- [`reviewer.md`](./reviewer.md) — uses this list as the screening surface; most entries are HARD FAIL findings.
- [`idioms.md`](./idioms.md) — how to do these right.
