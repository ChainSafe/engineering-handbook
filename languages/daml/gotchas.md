# Daml Gotchas

Bug classes and surprising behavior in Daml. Many are HARD FAIL findings under the [reviewer](./reviewer.md).

> Many of these are authorization or upgrade traps. ChainSafe's own [`daml-autopilot`](https://daml-autopilot.chainsafe.io) (Daml Reason) catches several by extracting the authorization model from your code — see [`developer.md`](./developer.md). For authoritative semantics, defer to the [Canton docs](https://docs.canton.network): the [Authorization Model](https://docs.canton.network/appdev/modules/m3-authorization) underpins the authorization gotchas below.

## Signatory set too wide

```daml
template Order
  with
    buyer : Party
    seller : Party
    notary : Party
  where
    signatory buyer, seller, notary   -- all three must authorize creation
```

If the notary should only observe, putting them in the signatory set means they must authorize every creation. Often misdesigned; ask whether they really need to sign.

## Signatory set too narrow

```daml
template Sensitive
  with
    issuer : Party
    holder : Party
  where
    signatory issuer   -- the holder doesn't authorize — can be created without their knowledge
```

If the holder hasn't consented, the contract still exists on the ledger. Verify whose authorization is actually needed.

## Controller can't actually authorize

```daml
template Order
  with
    buyer : Party
    seller : Party
  where
    signatory buyer, seller

    choice Resell : ()
      controller stranger   -- `stranger` is not a signatory or observer
      do return ()
```

If the controller isn't a signatory, observer, or someone the contract has otherwise informed, they can't see or exercise the choice. Authorization-chain confusion — usually a HARD FAIL finding.

## Observer leak

```daml
template Loan
  with
    lender : Party
    borrower : Party
    amount : Decimal
    rate : Decimal
  where
    signatory lender, borrower
    observer rateAuditors   -- now every rate auditor sees every loan's amount
```

Observer adds visibility, not just authorization. Widening the observer set leaks contract data. Design observers explicitly per template; review when widening.

## `submit` vs `submitMustFail` confusion in tests

```daml
-- Wrong: passing test because we expected success and got success but the success was meaningless
submit alice $ createCmd Trivial with party = alice
```

If you wrote a `submit` where you meant `submitMustFail`, the test passes vacuously. Especially common in negative-authorization tests. Read every test assertion line.

## Non-deterministic choice body

```daml
choice CalcInterest : Decimal
  controller borrower
  do
    rate <- callExternalOracle   -- non-deterministic!
    return (amount * rate)
```

Choice bodies must be deterministic. Reading from an external oracle within the choice is wrong; the oracle's value must be passed in as a parameter (which the submitter computed off-ledger before submitting).

## Submission time vs ledger-effective time

```daml
choice CheckDeadline : ()
  controller buyer
  do
    now <- getTime    -- ledger-effective time, not submission time
    assertMsg "Past deadline" (now <= deadline)
```

`getTime` returns ledger-effective time. The submitter's wall clock can differ. Time-sensitive logic must use the right semantics — Canton sequences time deliberately, but submitters can race. See [Working with Time](https://docs.canton.network/appdev/modules/m3-working-with-time).

## Adding a field to a deployed template

```daml
template Order
  with
    buyer : Party
    seller : Party
    -- newField : Text   <-- can't add this to an existing template version
```

You can't mutate a deployed template. Adding a field requires a new package version with the new template; existing contracts continue under the old version until migrated. Forgetting this means CI fails on type checks against deployed packages. See [Upgrade Compatibility](https://docs.canton.network/appdev/modules/m6-upgrade-compatibility) and [Upgrade Limitations](https://docs.canton.network/appdev/modules/m6-limitations) for the allowed/breaking-change rules.

## Removing a choice silently

Removing a choice (or renaming) from an existing template version breaks downstream code that exercises it. You can deprecate; you can't remove until consumers are off the old version.

## Key change without migration

```daml
template Order
  with
    buyer : Party
    seller : Party
    orderId : Text
  where
    signatory buyer
    -- key changed from (buyer, orderId) to (buyer, seller, orderId)
```

The key is part of the contract's ledger identity. Changing it without a migration means new contracts have new keys; old contracts have old keys; lookups won't find what callers expect.

## `fetch` after `archive` in the same choice

```daml
choice DoStuff : ()
  controller alice
  do
    archive cid
    fetched <- fetch cid   -- ERROR: contract is archived
```

Within a transaction, once you archive a contract, it's gone for the rest of the transaction. Fetch will fail.

## `exerciseByKey` with mismatched authorization

```daml
exerciseByKey @Order (buyer, orderId) Cancel
```

Even with `exerciseByKey`, the underlying choice's controller must authorize. The key lookup doesn't bypass the authorization model.

## Long workflow in a single choice when partial commit is fine

If the choice body has 50 operations and any of them can fail, the whole thing rolls back. If that's the intent, fine. If you actually want intermediate commits, split into multiple choices with intermediate template states.

## Long workflow split into choices when atomicity was required

Symmetric to the above. Splitting a workflow means intermediate states are visible on the ledger between exercises. An attacker can exploit the gap. If atomicity is required, keep it in one choice.

## `delegate` granting more than intended

```daml
choice GrantDelegate : ()
  controller principal
  do
    create DelegateAuthority with
      delegator = principal
      delegate = agent
      -- powers: too broad?
```

`delegate` patterns broaden the effective party visibility. Audit every delegate authorization for scope creep.

## Test data leakage between scenarios

Daml Script `setup` blocks can leak state between scenarios if not isolated. Each scenario gets fresh `allocateParty` calls; don't reuse party IDs across tests.

## `assertMsg` vs `assert`

```daml
assertMsg "Order amount must be positive" (amount > 0.0)
```

`assertMsg` gives a useful failure message; `assert` gives a generic one. Prefer `assertMsg` in production code.

## Forgetting `ensure`

```daml
template Order
  with
    amount : Decimal
  where
    signatory ...
    -- no ensure: amount can be 0 or negative; no invariant enforcement at creation
```

`ensure` clauses validate at creation time. Without one, invalid data lands on the ledger and is harder to fix.

## Canton-specific: cross-domain workflow without synchronizer

For Canton workflows that span multiple domains, the synchronizer choice matters. Without an explicit synchronizer, behavior may be ambiguous. Coordinate with the Canton operator (`@joshdougall` and the Canton deploy guide).

## Related

- [`reviewer.md`](./reviewer.md) — most of these are HARD FAIL findings.
- [`idioms.md`](./idioms.md) — the inverse.
- [`developer.md`](./developer.md) — tooling (`daml-autopilot`), testing, CI.
- Upstream: [Canton Network Docs](https://docs.canton.network) — authoritative Daml language reference.
