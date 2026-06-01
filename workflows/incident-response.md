# Incident Response

This handbook holds only the **operator decision policy** layer for incidents. The *how-to* — the actual runbooks, paging procedures, escalation chains, and recovery steps — lives in [`ChainSafe/infrastructure-general/docs/runbooks/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/runbooks).

> **In one line:** When to page, when to roll back, who approves a recovery action. The *how* defers to the runbooks.

## Operator decision policy

These are the calls a human makes during an incident. The runbooks tell you the mechanics; this page tells you the decisions.

### When to page

Page the on-call (and yourself) when any of these are true:

- A user-facing service is degraded or down.
- A validator or signer is missing duties or producing invalid attestations.
- A monitoring alert fires that the [`infrastructure-alerts`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/infrastructure-alerts.md) runbook classifies as page-worthy.
- Funds, assets, or signing keys are at risk.
- A security event is suspected (suspicious access, leaked credential, exploited vulnerability).
- The chain you're operating against is in a degraded state and the runbook for that chain (Polkadot, Ethereum, Filecoin, etc.) calls for it.

Do not page for transient blips that auto-recover within the runbook's threshold. The runbooks define those thresholds; defer to them.

### When to roll back

Roll back when:

- A deploy correlates with a regression and the regression is user-visible or affects validator duties.
- A configuration change has produced unexpected behavior in production and the change is reversible.
- An ongoing degradation is worsening, not stabilizing, and the next escalation step is "roll forward and find out."

Do **not** roll back when:

- The degradation is unrelated to a recent change (rolling back won't fix it, and may add complexity).
- The rollback itself is irreversible at this point (e.g., schema changes already applied — see [`gates-and-escalation.md` §3](../operating-model/gates-and-escalation.md#3-irreversible-writes)).
- The runbook for this specific failure mode calls for roll-forward.

Rollback decisions are owned by the on-call operator in consultation with the change author (if reachable) and the relevant CODEOWNER. Agents do not execute rollbacks autonomously — the [protected-branch and irreversible-writes gates](../operating-model/gates-and-escalation.md#3-irreversible-writes) require explicit operator approval.

### Who approves what

| Action | Approves |
|---|---|
| Acknowledging a page | The on-call (immediately) |
| Initiating roll-back | The on-call, with a CODEOWNER for the affected service |
| Bypassing a HARD FAIL during incident recovery | The on-call **and** the CODEOWNER; override is logged in the post-incident review |
| Comms to external stakeholders (status page, customers, validators) | Per the [external-comms gate](../operating-model/gates-and-escalation.md#4-external-communication); on-call coordinates with the comms / leadership chain |
| Closing the incident | The on-call, after the runbook's exit criteria are met |
| Calling for a post-incident review | Always — every page-worthy incident gets one |

## Runbook deep-link map

> **Status note.** File-level targets below are confirmed against the current state of `infrastructure-general/docs/runbooks/`. Heading anchors within the runbooks are pending [@joshdougall](https://github.com/joshdougall)'s confirmation. See [PLAN.md §4c](../PLAN.md#4c-convention-deep-links-not-see-also) for the deep-link convention.

### By chain / product

| Scenario | Runbook |
|---|---|
| General infrastructure alerts (cross-product) | [`infrastructure-alerts.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/infrastructure-alerts.md) |
| Ethereum / Lodestar alerts | [`lodestar-alerts.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/lodestar-alerts.md) |
| Filecoin alerts | [`filecoin-alerts.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/filecoin-alerts.md) |
| Forest upgrade procedures | [`forest-upgrade-procedures.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/forest-upgrade-procedures.md) |
| Polkadot alerts | [`polkadot-alerts.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/polkadot-alerts.md) |
| Optimism alerts | [`optimism-alerts.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/optimism-alerts.md) |
| Lido validator operations | [`lido-validator-operations.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/lido-validator-operations.md) |
| Rocketpool node operations | [`rocketpool-node-operations.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/rocketpool-node-operations.md) |
| IPFS gateway operations | [`ipfs-gateway-operations.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/ipfs-gateway-operations.md) |
| Canton unclaimed rewards | [`canton-unclaimed-rewards.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/runbooks/canton-unclaimed-rewards.md) |

If your scenario isn't listed: the runbook may not exist yet. Surface the gap to [@joshdougall](https://github.com/joshdougall) and the on-call; do not improvise from this page.

## Agent role during an incident

Agents are useful for support tasks during an incident; they are not on-call:

- **Useful:** searching logs, summarizing metrics, generating draft status updates for human approval, cross-referencing similar past incidents, drafting the post-incident review document.
- **Not useful:** making the rollback decision, posting to status pages, paging humans, running recovery commands against production without explicit per-command operator approval.

During an active incident, the [secrets gate](../operating-model/gates-and-escalation.md#2-secrets-and-credentials), [external-communication gate](../operating-model/gates-and-escalation.md#4-external-communication), and [protected-branch gate](../operating-model/gates-and-escalation.md#5-version-control-state) tighten, not loosen. Time pressure is the textbook way for these gates to be silently violated; agents should be more cautious during incidents, not less.

## Post-incident review

Every page-worthy incident gets a written post-incident review. The format follows blameless-postmortem conventions:

- What happened, in order.
- What we expected vs. what happened.
- Why the gap.
- What went well during the response.
- What we'd change about the response itself.
- Concrete action items, owned, with dates.

Agents can draft the document from chat logs, runbook executions, and PR history. The operator reviews, edits, and owns the conclusions. The document lives in `infrastructure-general` (location per Josh's convention) and is linked from the original incident ticket.

## Related

- [`infrastructure-and-devops.md`](./infrastructure-and-devops.md) — the broader infra deep-link map; this page is incident-specific.
- [`release-and-deploy.md`](./release-and-deploy.md) — release decisions whose backstop is this page when they go wrong.
- [`../operating-model/gates-and-escalation.md`](../operating-model/gates-and-escalation.md) — the gates incidents put under stress.
- [`../operating-model/collaborator-statement.md`](../operating-model/collaborator-statement.md) — operator-first applies under time pressure too.
- Upstream: [`ChainSafe/infrastructure-general/docs/runbooks/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/runbooks) — the runbooks themselves.
