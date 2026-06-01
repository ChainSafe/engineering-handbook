# Daml Idioms

Idiomatic patterns for Daml at ChainSafe — particularly Canton applications.

> These are the ChainSafe house patterns. For authoritative language semantics, defer to the [Canton docs](https://docs.canton.network) (machine index: [`llms.txt`](https://docs.canton.network/llms.txt)); for tooling, testing, and CI — including ChainSafe's own `daml-autopilot` — see [`developer.md`](./developer.md).

## Template structure

```daml
template Order
  with
    buyer : Party
    seller : Party
    sku : Text
    amount : Decimal
  where
    signatory buyer, seller
    observer buyer, seller

    ensure amount > 0.0

    choice Cancel : ()
      controller buyer
      do return ()

    nonconsuming choice GetStatus : Text
      controller buyer
      do return "Active"
```

- **Signatories** are mandatory authorities — both parties must sign for the contract to exist.
- **Observers** can see the contract but cannot exercise choices.
- **`ensure`** clauses validate invariants at creation/exercise.
- **`controller`** declares who can exercise a choice — their authorization is required.

## Choice patterns

```daml
choice Transfer : ContractId Order
  with
    newBuyer : Party
  controller buyer, newBuyer
  do create this with buyer = newBuyer
```

- **Multi-controller** choices require all named parties to authorize.
- **Consuming** by default — archives the contract and produces the return value.
- **`nonconsuming`** for read-only choices that leave the contract alive.

## Records and types

```daml
data OrderState = Draft | Active | Cancelled
  deriving (Eq, Show)

data Money = Money with
    amount : Decimal
    currency : Text
  deriving (Eq, Show)
```

- Algebraic data types for state machines.
- Record syntax for structured values.
- `deriving (Eq, Show)` for common typeclasses.

## Party patterns

```daml
withParty : Party -> Update (ContractId Order)
withParty p = do
  -- read what `p` can see
  ...
```

- Pass parties as parameters; don't bake them into the contract identity unless necessary.
- For Canton multi-party workflows, separate "agent" parties from "principal" parties when delegation matters.

## Keys

```daml
template UniqueOrder
  with
    buyer : Party
    seller : Party
    orderId : Text
  where
    signatory buyer, seller

    key (buyer, orderId) : (Party, Text)
    maintainer key._1
```

- Use keys when the (signatory, key) tuple should be globally unique.
- `maintainer` names the party responsible for key maintenance — typically the primary signatory.

## Scenario tests

```daml
import Daml.Script

setup : Script ()
setup = do
  alice <- allocateParty "Alice"
  bob <- allocateParty "Bob"

  orderId <- submit alice $ createCmd Order with
    buyer = alice
    seller = bob
    sku = "Widget"
    amount = 10.0

  submit alice $ exerciseCmd orderId Cancel
  return ()
```

- `Daml.Script` is the canonical test framework.
- `submit` runs as a specific party — authorization is checked.
- `submitMustFail` for negative tests.
- Full API: [Testing Daml Contracts](https://docs.canton.network/appdev/modules/m3-testing). Run in CI via ChainSafe's [`canton-ci`](https://github.com/ChainSafe/canton-ci) `daml-test` / `daml-script` actions — see [`developer.md`](./developer.md#ci).

## Time and dates

```daml
choice Expire : ()
  controller buyer
  do
    now <- getTime
    assertMsg "Order is not expired" (now > expirationTime)
    return ()
```

- `getTime` returns ledger-effective time, not wall clock.
- Document which time semantics you're using (submission, record, ledger-effective).

## Upgrade-friendly design

```daml
template Order
  with
    buyer : Party
    seller : Party
    sku : Text
    amount : Decimal
  where
    signatory buyer, seller

    choice MigrateToV2 : ContractId OrderV2
      controller buyer, seller
      do create OrderV2 with
        buyer = buyer
        seller = seller
        sku = sku
        amount = amount
        newField = ""  -- explicit default
```

- Design migration choices into templates from the start.
- Version package names; old contracts continue to exist on the ledger.
- Authoritative rules: [Upgrade Compatibility](https://docs.canton.network/appdev/modules/m6-upgrade-compatibility) · [Writing Your First Upgrade](https://docs.canton.network/appdev/modules/m6-writing-first-upgrade).

## Canton workspace layout

```
my-canton-app/
├── daml.yaml
├── daml/
│   ├── Main.daml
│   ├── Orders.daml
│   └── Workflows.daml
├── test/
│   └── Test.daml
└── README.md
```

- One template per file when templates grow non-trivially.
- Keep `Main.daml` as the entry point / re-export module.

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`reviewer.md`](./reviewer.md) **(HARD FAIL tier)**, [`gotchas.md`](./gotchas.md).
- Upstream: [Canton Network Docs](https://docs.canton.network) — authoritative Daml language reference.
