---
title: Daml Architect
status: draft (v2)
authors:
  - "@kalambet"
language: daml
role: architect
last_updated: 2026-05-27
---

# Daml Architect

Architectural guidance for Daml work at ChainSafe — primarily Canton applications including Super Validator and Featured App work. The architectural framework is `.invariance` ([pointer page](../../invariants/invariance-framework.md)); this page covers Daml-specific shaping.

> **In one line:** Templates encode the contract. Signatories authorize. Choices are atomic. Upgrades are versioned packages, not patches. Every authorization decision is a security decision.

## Defer to `.invariance` for

| Decision | `.invariance` section |
|---|---|
| Ledger-state invariants | Ledger invariants *[anchor pending]* |
| Authorization invariants | Authorization model *[anchor pending]* |
| Upgrade lifecycle | Package upgrade invariants *[anchor pending]* |
| Cross-application invariants (Canton multi-app) | Inter-app contracts *[anchor pending]* |

## Daml-specific architectural choices

### Project layout

Canonical Daml project structure:

- `daml.yaml` at the root — package metadata, version, dependencies, sandbox options.
- `daml/` — source modules. One file per major template or module concern.
- `test/` (or `daml-test/` per project convention) — scenario / script tests.
- For multi-package projects (workspaces in Canton): each package in its own subdirectory with its own `daml.yaml`, plus a top-level `Dars.lock` or equivalent.
- Generated bindings (Java, TypeScript, Scala) in `gen/` or per-language subdirectories.

### Template design

Templates are the unit of contract. Design commitments at the architectural stage:

- **Signatories.** Who authorizes creation? Who authorizes archival? The signatory set is the strongest authorization primitive — it cannot be relaxed at runtime. Design it tightly.
- **Observers.** Who sees the contract? Observers are the privacy/visibility surface. A wider observer set is a wider information leak.
- **Choice authorization.** Each `choice` declares its `controller`. The controller's authorization is required to exercise. Non-consuming choices stay; consuming choices archive the contract.
- **Key uniqueness.** If a template has a `key`, the (signatory-set, key) tuple is unique on the ledger. Use keys deliberately — they constrain concurrency.

### Workflow shape

- **Atomic choices.** A choice's body executes as one ledger transaction. Either every effect happens, or none does. Split a workflow into multiple choices when partial commit is acceptable; keep it in one when atomicity is required.
- **No external I/O during a choice.** Daml is deterministic by design. Calls to oracles or off-ledger services happen *outside* a transaction; the result is then submitted as an input.
- **Time bounds.** Use `getTime` and ledger-effective-time semantics deliberately. Submission time, record time, and ledger effective time are distinct; the choice between them shapes the trust model.

### Upgrade strategy

Daml contracts are immutable. Upgrades happen via:

- **New template version** in a new package. The old contracts continue to exist; new contracts use the new template.
- **Migration choices** on the old template that archive the old contract and create the new template's contract.
- **Daml smart contract upgrades** (SCU) — `@upgrade` annotations for compatible upgrades within the same template name.

Architectural decisions:

- Plan the migration choice into the template from day one. Adding it later is harder than including it from the start.
- Version every package. Production packages stay on their version once deployed; new logic ships as a new version.
- For Canton: domain operators may control which packages are uploaded — coordinate the upgrade path with the domain governance.

### Privacy model

Canton's privacy is structural. The party visibility model determines who knows what:

- A party sees only contracts where they are signatory, observer, or controller of an exercised choice.
- The sub-transaction privacy means even within a transaction, parts may be hidden from non-stakeholders.
- Designing for privacy means designing observer sets — wider observer sets reduce privacy in exchange for visibility.

## ADR shape for Daml work

Every Daml ADR covers:

- **Templates and choices.** What templates exist, with their signatories, observers, controllers, key, and consuming/non-consuming choice classification.
- **Authorization model.** Who can create / observe / exercise / archive each contract. Justify each authority.
- **Upgrade path.** Migration choices designed in. Version-numbered packages.
- **Atomicity boundaries.** Which workflows are single-choice atomic; which are multi-choice with explicit intermediate states.
- **Privacy commitments.** Which parties see what.
- **Invariants impacted.** Deep links into `.invariance`.

## Canton-specific considerations

For Canton-deployed applications (Super Validator, Featured App, broader ecosystem work):

- **Domain participation.** Which domain(s) does this application participate in? Cross-domain workflows have specific semantics.
- **Synchronizer choice.** For multi-domain workflows, which synchronizer coordinates the cross-domain transaction.
- **Sequencer integration.** How transactions reach the sequencer and what the back-pressure model is.
- **Mediator authorization.** Mediator validation rules for the chosen domain.

See [`../../workflows/infrastructure-and-devops.md`](../../workflows/infrastructure-and-devops.md) for Canton deployment topology, deep-linked into `infrastructure-general/docs/projects/canton/`.

## Anti-patterns

- **Wide observer sets** because "we might need it later." Observers leak; design the privacy surface deliberately.
- **`tx.origin`-equivalent thinking.** Authorization should follow signatories, not chain inferences.
- **Long workflows in a single choice** when intermediate states would be cleaner — the atomicity isn't free.
- **Unversioned packages in production.** Upgrade migrations become guesswork.
- **External I/O reaches into choices** — destroys determinism.
- **Keys overused** as a constraint when they aren't needed — they constrain throughput.

## Related

- [`reviewer.md`](./reviewer.md) **(HARD FAIL tier)** — what to look for in a Daml PR.
- [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../invariants/invariance-framework.md`](../../invariants/invariance-framework.md).
- [`../../workflows/infrastructure-and-devops.md`](../../workflows/infrastructure-and-devops.md) — Canton infra context.
