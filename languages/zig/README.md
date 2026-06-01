# Zig at ChainSafe

> **In one line:** Zig has no confirmed production use at ChainSafe as of v2. This page exists to be honest about that and to set a rebuttable presumption against reaching for Zig before talking to the curator.

## Status

Zig appears in the language coverage list in [PLAN.md §5](../../PLAN.md) as a v2/aspirational language. As of the v2 launch, **there is no confirmed production Zig codebase at ChainSafe** that requires architect / developer / reviewer role pages. Rather than fabricate a full role triad for a language that doesn't have an established practice at the org, this single page records what we know and what to do if Zig comes up.

## When not to reach for Zig

For typical ChainSafe work, the language is **already chosen** by the product:

- **Filecoin client work** → Rust (Forest).
- **Ethereum consensus client** → TypeScript (Lodestar).
- **Polkadot client** → Go (Gossamer).
- **Smart contracts** → Solidity.
- **Canton applications** → Daml.
- **Internal tooling / scripts / ops** → Python.
- **Performance-critical native libraries** → Rust by default, given the team's existing depth and the ecosystem.

Zig's strengths — explicit memory control, compile-time evaluation, C interop — are real, but for each strength one of the languages above is already the better fit for the existing surface area at ChainSafe.

## When to reach for Zig (escalate first)

Plausible cases where Zig might be the right choice:

- A library where C-level performance is required and the Rust ecosystem lacks a suitable primitive, *and* the maintenance cost of introducing a new language to the team is justified.
- A C interop layer where Zig's `@cImport` and explicit ABI control offer real ergonomic value over Rust's `bindgen` / `cc`.
- A research / experimental project where the language choice is part of the experiment.

In every case: **escalate to the curator before starting**. Adding a new production language is an org-level decision, not an individual-PR decision.

## What to do if you find Zig in a ChainSafe repo

If you encounter Zig code in a ChainSafe repository:

1. Find the operator who owns the repo (CODEOWNERS, recent commit authors).
2. Ask why Zig — there should be a documented rationale, ideally an ADR.
3. If there's no ADR, the language choice itself is the first finding to surface in any review.
4. Update this page with the actual scope so it stops being a placeholder.

## If this page should become real

When ChainSafe genuinely adopts Zig in production:

- Replace this `README.md` with the full role triad (`architect.md`, `developer.md`, `reviewer.md`) plus `idioms.md` and `gotchas.md` following the [Phase 4 v0 language pattern](../../PLAN.md#5-language-ecosystems--role--language-matrix).
- Add the corresponding `chainsafe-zig-*` skills in `skills/` via `skill-creator`.
- Update [`llms.txt`](../../llms.txt) to index the new pages.
- Add a reviewer-severity entry to [`PLAN.md §7.5`](../../PLAN.md#7-decisions-resolved-2026-05-27) — most Zig contexts at a blockchain org would be SOFT WARNING unless directly handling cryptography, in which case HARD FAIL territory.

This page is the placeholder that admits the gap rather than fabricating coverage.

## Related

- [`../../PLAN.md`](../../PLAN.md) — language coverage rationale.
- [`../../operating-model/collaborator-statement.md`](../../operating-model/collaborator-statement.md) — no-fabrication invariant: this page exists because the alternative would have been fabricating Zig practice from a vacuum.
