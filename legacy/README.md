# Legacy handbook

This directory preserves the pre-v2 ChainSafe Engineering Handbook — the Docusaurus-era markdown tree as it stood when the AI-native rewrite began.

**Why it's here.** The rewrite is a content replacement, not a fresh start. Many pages in the new handbook (under `operating-model/`, `invariants/`, `workflows/`, `languages/`) carry forward, reframe, or deliberately drop material from these legacy pages. Keeping the source available in-tree means rewrites can reference the original without checking out an old tag.

**Status.** Not maintained. Not authoritative. Not linked from the active handbook navigation. The canonical pre-v2 state is the `v1` tag on `main`; this directory is a working-tree convenience copy.

**When to consult it.**

- Cross-referencing during a rewrite (e.g., "what did the legacy reviewer guide actually say?")
- Auditing what content has and hasn't been carried forward at v0 launch
- Recovering attribution and historical context for an original author

**What was moved here on 2026-05-27** (TODO 0.3):

- `1_principles/` — the legacy 10 engineering principles
- `3_development/` — development flow, peer reviews, tech-stack pages (Go, Rust, TypeScript, Unity stub), QA principles, documentation tooling
- `4_the-formal-stuff/` — 360 reviews, career-development ladders, process and policy
- `HOME.md` — Docusaurus welcome page

**What stayed at the root** (not legacy):

- `VISION.md` — the mission, vision, and core values; carried forward verbatim, not archived.

**Removal policy.** Whether `legacy/` ships in the public v0 (or gets stripped before the final merge to `main`) is a Phase 8 decision. Until then it stays.
