---
title: Release and Deploy (Pointer + Policy)
status: draft (v2) — deploy procedures live upstream; this page is policy + deep links
authors:
  - "@kalambet"
defers_to:
  upstream: "`ChainSafe/infrastructure-general` (deploy procedures, environment specs) — owned by @joshdougall"
last_updated: 2026-05-27
---

# Release and Deploy

This handbook holds the **operator decision policy** for shipping work. The *how-to* — deploy procedures, environment-specific commands, rollback mechanics — lives in [`ChainSafe/infrastructure-general`](https://github.com/ChainSafe/infrastructure-general).

> **In one line:** When to ship, who approves, what counts as ready. The *how* defers to the infra repo.

## Operator decision policy

These are the calls a human makes before, during, and after a deploy. The infra repo's runbooks tell you what to run; this page tells you whether to run it.

### Deploy readiness — pre-flight

Before any deploy to a non-dev environment, the operator confirms:

- **CI is green** on the release commit. Required checks from [`repo-and-ci-setup.md` §3](./repo-and-ci-setup.md#3-branch-protection) pass.
- **Acceptance criteria are met** for every change in the release (see [Engineering Invariant §3](../10-invariants/engineering-invariants.md#3-quality-is-defined-before-the-build-not-after)).
- **HARD FAIL findings are resolved** — or, in the explicit-override case, the override is logged in the PR per [agent-era invariant §7](../10-invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings).
- **The runbook for this product exists** and the deploy procedure is mapped. If the runbook is missing, the deploy is blocked until one is written or the missing-section gap is escalated.
- **Rollback path is known** before the deploy starts. "How do we undo this if it goes wrong" is not a question to figure out mid-incident.
- **No active release freeze.** Mobile or infrastructure-wide freezes (announced in advance) preempt individual deploys.

If any of these fails, the operator does not deploy. The agent does not push past the gate.

### Approval matrix

| Deploy target | Who approves |
|---|---|
| Local / dev environment | The author |
| Staging / test environment | The author + a CODEOWNER for the affected product |
| Canary / a subset of production | A CODEOWNER + the on-call for the affected product |
| Full production | A CODEOWNER + the on-call + (for security-critical or breaking changes) the curator or a Head of Engineering |
| Hot-fix during an incident | The on-call may proceed with a single CODEOWNER's approval; post-hoc review is mandatory |

Per the [version-control gate](../00-operating-model/gates-and-escalation.md#5-version-control-state), agents never push to protected branches or execute merges. The operator merges; the operator (or the deploy tooling under the operator's supervision) deploys.

### During the deploy

- **Watch the relevant dashboards** through the deploy. Inventory is in [`infrastructure-general/docs/observability/monitoring-inventory.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/monitoring-inventory.md); the runbook for the specific product names which dashboards to follow.
- **Don't multitask** during the watch window. Production deploys are a "your hands are on the wheel" task.
- **Have the rollback command ready** — typed but not executed — for the duration of the watch window.

### Post-deploy

- **Confirm the change took effect.** The deploy succeeded ≠ the change is doing what was intended. Verify against the acceptance criteria from §1.
- **Update the relevant status surface** if the deploy was announced (status page, internal channel, customer-facing release notes).
- **Note any anomalies** in the deploy log, even if they resolved on their own. They will help when something similar happens next time.

### Release freezes

Release freezes are announced in advance and noted in the relevant project tracker. The handbook does not maintain a freeze calendar — that's product-specific. When a freeze is active for a given product, deploys for that product require explicit lift-the-freeze approval from the Head of Engineering or the product lead.

If you are an agent helping with deploys and you have not been told whether a freeze is active, ask before proceeding.

## Deploy procedure deep links

Deploy procedures are product-specific and live in `infrastructure-general`:

| Product / area | Procedure location |
|---|---|
| Canton (k8s) | [`docs/projects/canton/canton-k8s-deployment.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/canton/canton-k8s-deployment.md), [`canton-deploy-new-app.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/canton/canton-deploy-new-app.md) |
| Forest staging environment | [`docs/projects/filecoin/forest-staging-environment.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/filecoin/forest-staging-environment.md) |
| Lodestar production operations | [`docs/projects/ethereum/lodestar-production-operations.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/ethereum/lodestar-production-operations.md) |
| Lodestar public services | [`docs/projects/ethereum/lodestar-public-services.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/ethereum/lodestar-public-services.md) |
| SSV operator onboarding | [`docs/projects/ssv/onboarding-validator.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/ssv/onboarding-validator.md), [`operator-registration.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/ssv/operator-registration.md) |
| Faucet operations | [`docs/projects/filecoin/faucet-operations.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/filecoin/faucet-operations.md) |
| Snapshot service | [`docs/projects/filecoin/snapshot-service.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/filecoin/snapshot-service.md) |
| IaC / Terraform changes | [`terraform/`](https://github.com/ChainSafe/infrastructure-general/tree/main/terraform) — each subdirectory has its own README |
| Ansible-driven deploys | [`ansible/`](https://github.com/ChainSafe/infrastructure-general/tree/main/ansible) |

If a procedure isn't listed: it may not exist yet. Surface to [@joshdougall](https://github.com/joshdougall) before improvising.

## Agent role in releases and deploys

Useful:

- Drafting the release notes from the PRs in the release.
- Generating the deploy plan (steps, commands, expected outputs) from the runbook for operator approval.
- Watching dashboards alongside the operator, summarizing anomalies in plain language.
- Running pre-flight verification (CI status, acceptance-criteria check against PRs).

Not useful:

- Executing the deploy commands without explicit per-step operator approval. Production deploy is an [§1 gate](../00-operating-model/gates-and-escalation.md#1-production-and-deployment); see the standard stop pattern.
- Approving HARD FAIL overrides on the operator's behalf.
- Authorizing a rollback. Rollbacks are the operator's call; the agent prepares the command, the operator runs it.

## Anti-patterns

- **"Deploy then verify."** Verification is part of the deploy, not after it.
- **Friday afternoon deploys.** Avoid unless the deploy is the fix to a Friday incident. The cost of a regression discovered Saturday is asymmetric.
- **Skipping the rollback path.** If you can't say how you'd undo this, you aren't ready to do it.
- **Multi-deploy parallelism.** Two deploys at once means you can't tell which one broke the dashboard. Sequential by default.
- **Agent auto-deploy on green CI.** Green CI is necessary, not sufficient. The operator makes the call.

## Related

- [`infrastructure-and-devops.md`](./infrastructure-and-devops.md) — broader infra deep-link map.
- [`incident-response.md`](./incident-response.md) — what to do when a deploy goes wrong.
- [`repo-and-ci-setup.md`](./repo-and-ci-setup.md) — CI baseline the pre-flight readiness check assumes.
- [`pr-authoring.md`](./pr-authoring.md) — where acceptance criteria come from.
- [`../00-operating-model/gates-and-escalation.md`](../00-operating-model/gates-and-escalation.md) — §1 (production / deployment) and §5 (version-control state).
- Upstream: [`ChainSafe/infrastructure-general`](https://github.com/ChainSafe/infrastructure-general) — every actual procedure.
