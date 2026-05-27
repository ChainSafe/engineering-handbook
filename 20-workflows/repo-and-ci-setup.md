---
title: Repo and CI Setup
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 3_development/1_development-flow/1_setup_repository.md
last_updated: 2026-05-27
---

# Repo and CI Setup

The per-repo hygiene checklist for a new (or newly-audited) repository at ChainSafe, structured as an agent-runnable runbook. The operator approves the plan; the agent executes; each step has a rollback path.

> **In one line:** Branch protection, CODEOWNERS, CI, security baseline. Anything cluster-, account-, or env-level defers to [`ChainSafe/infrastructure-general`](https://github.com/ChainSafe/infrastructure-general).

## How to use this page

This is a checklist, not a tutorial. Each item names what gets configured, why, and how the agent verifies success. When run by an agent under operator supervision, every step gets:

1. A plan (what the agent will change, in concrete terms).
2. Operator approval.
3. Execution.
4. Verification.
5. A rollback note if the step did anything destructive.

Per the [repo-boundaries gate](../00-operating-model/gates-and-escalation.md#6-repository-and-account-boundaries), the agent operates only on the repo the operator names.

## 1. Project creation

- **Action.** Create the repo under the `ChainSafe` GitHub organization.
- **Defaults.** Public, with a `README.md` and a `LICENSE`. License is Apache 2.0 unless the project has a documented reason otherwise (see [`../README.md` License section](../README.md#license)).
- **If permission is missing,** reach out to an org owner (the Heads of Engineering, currently).
- **Rollback.** Delete the repo if no commits beyond the initial scaffolding have landed.

## 2. Team permissions

- **Create or reuse two GitHub teams:** `<project>-admins` for senior/admin staff, `<project>` for the working group.
- **Grant `<project>` Write permission**; grant `<project>-admins` Admin.
- **Add the org-wide `ChainSafe` team with Read** unless the project is sensitive (private repo, audit-restricted code). If so, omit and note the reason in the repo README.
- **Verification.** Org-level audit log shows the team additions.
- **Rollback.** Remove team permissions; no data loss.

## 3. Branch protection

Configure `Settings → Branches → Add Rule` (or edit existing) for `main` (and any other long-lived branch like `develop` or `release`).

Baseline rule set:

- **Require pull request before merging.** Always.
- **Required approving reviews:** 1 for small teams, 2 for security-critical or high-traffic repos.
- **Dismiss stale approvals when new commits are pushed.** On.
- **Require review from CODEOWNERS.** On (after [§5](#5-codeowners) below).
- **Require status checks to pass before merging.** On. Listed checks come from [§6](#6-ci) below.
- **Require branches to be up to date before merging.** On.
- **Require linear history.** Optional; depends on whether the repo's convention is squash or merge commits.
- **Require signed commits.** On for security-critical repos; consider for all.
- **Restrict who can push to matching branches.** Disable direct push for everyone (force PR flow).
- **Allow force pushes / Allow deletions.** Off.

Verification: open a PR against `main` with no reviewers; confirm merge is blocked.

Rollback: branch protection settings are version-history'd in GitHub's audit log; you can revert to a prior state. Not destructive.

## 4. Merge button settings

`Settings → General → Pull Requests`:

- **Allow squash merging.** On (default).
- **Allow merge commits.** Off unless the repo has a reason (release branches, etc.).
- **Allow rebase merging.** Off by default; enable per-project if the team uses it.
- **Always suggest updating PR branches.** On.
- **Automatically delete head branches.** On.

The legacy guide called for disabling merge commits and rebase by default — this preference holds. Squash keeps `main` history clean.

## 5. CODEOWNERS

- **Create `.github/CODEOWNERS`** with the structure:
  - Catch-all owner at the top (a team or set of individuals).
  - Section-specific overrides below, ordered from general to specific.
- **For the handbook repo specifically,** the v2 model uses [@kalambet](https://github.com/kalambet) as the catch-all curator with overrides for `10-invariants/invariance-framework.md` (@boorich), `20-workflows/*` infra pointer pages (@joshdougall), etc. See [`../.github/CODEOWNERS`](../.github/CODEOWNERS).
- **Verify by opening a test PR** touching the catch-all area and confirming the right reviewer is auto-requested.
- **Rollback.** Revert the `.github/CODEOWNERS` file via PR.

## 6. CI

The CI baseline for ChainSafe repos:

- **Lint.** Run the language-appropriate linter (ESLint/TypeScript, golangci-lint, clippy, etc.).
- **Format check.** Run formatter in check-mode (prettier, gofmt, rustfmt, etc.). Fail the build if formatting is off.
- **Type check.** For typed languages, run the typechecker as a separate step (avoids "tests pass but types break" outcomes).
- **Tests.** Unit, integration, end-to-end as the project warrants. See [`testing-and-qa.md`](./testing-and-qa.md).
- **Build.** Confirm the artifact actually builds.
- **License-checker.** Verify no GPL or otherwise incompatible licenses entered dependencies (especially for products meant to be Apache 2.0–licensed downstream).

Each becomes a required check in branch protection (§3 above).

## 7. Security baseline

- **Secret scanning.** GitHub native secret scanning enabled (`Settings → Code security and analysis`).
- **Dependency review.** GitHub's dependency review action on PRs, configured to fail on critical/high vulnerabilities.
- **SBOM generation.** As part of release artifacts where applicable. CycloneDX or SPDX format.
- **Dependabot or Renovate.** For automated dependency updates with security-patch auto-merge gated by a human review.
- **Signed commits.** Strongly recommended; required for security-critical repos.
- **CodeQL or equivalent SAST.** For repos producing user-facing or smart-contract code.

## 8. Labels

A consistent label taxonomy makes triage and reporting tractable. ChainSafe baseline:

- **Status:** `triage`, `accepted`, `in-progress`, `blocked`, `wontfix`.
- **Type:** `bug`, `feature`, `chore`, `docs`, `security`, `refactor`.
- **Priority:** `p0` (critical), `p1` (high), `p2` (medium), `p3` (low).
- **Special:** `good-first-issue`, `help-wanted`, `breaking-change`.

Apply via the `labels` API or a labels-config tool (e.g., `github-label-sync`) so the set is reproducible across repos.

## 9. CLA bot

For public repos accepting external contributions, install the [CLA Assistant](https://github.com/cla-assistant/cla-assistant) (or equivalent). External contributors sign the ChainSafe CLA before their PR can merge.

Internal-only repos can skip this step.

## 10. Notifications and integrations

- **Slack notifications.** Wire the relevant team channel for PR opens, reviews, and merges. Volume: opt for "all events" on small repos, "review requested + merged" on large ones.
- **Scheduled reminders.** A weekly bot ping for stale PRs (>3 business days without review).
- **Linear / Jira integration.** If the project tracks work outside GitHub, wire the integration so PRs link issues and vice versa.

## What this page does NOT cover

Anything cluster-, account-, or env-level defers to [`infrastructure-general`](https://github.com/ChainSafe/infrastructure-general):

- Cluster setup (EKS, Hetzner k8s).
- IaC provisioning (Terraform).
- Configuration management (Ansible).
- Observability (Grafana, Prometheus, alerting).
- Deploy pipelines and release tooling.
- On-call rotations.

See [`infrastructure-and-devops.md`](./infrastructure-and-devops.md) for the pointer.

## Verification: end-to-end smoke test

After running through the checklist, the agent (or operator) verifies the setup with one PR:

1. Open a PR with a trivial change.
2. Confirm CI runs all required checks.
3. Confirm CODEOWNERS auto-requested the right reviewer.
4. Confirm merge is blocked until checks pass and review approves.
5. Approve and merge; confirm the head branch is auto-deleted.

If any of those don't happen, fix the misconfiguration before considering the repo "set up."

## Related

- [`pr-authoring.md`](./pr-authoring.md) — how PRs against this repo get authored.
- [`code-review.md`](./code-review.md) — how PRs get reviewed.
- [`testing-and-qa.md`](./testing-and-qa.md) — the testing baseline CI enforces.
- [`infrastructure-and-devops.md`](./infrastructure-and-devops.md) — anything beyond per-repo hygiene.
- [`../00-operating-model/gates-and-escalation.md`](../00-operating-model/gates-and-escalation.md) — the gates relevant when running this checklist as an agent.
