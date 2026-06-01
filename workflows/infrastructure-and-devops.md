# Infrastructure and DevOps

For all infrastructure, IaC, deployment topology, observability, on-call, and DevOps practice, the canonical source is **[`ChainSafe/infrastructure-general`](https://github.com/ChainSafe/infrastructure-general)**. This handbook does not duplicate it.

> **In one line:** This page is a navigation surface, not a tutorial. Deep links by intent into the canonical repo; no "see also" gestures.

> **Status note.** File-level deep-link targets on this page are confirmed against the current state of `infrastructure-general/docs/`. Heading anchors *within* those files are pending [@joshdougall](https://github.com/joshdougall)'s confirmation. Where the upstream lacks an anchor we need for clean linking, the convention is to add the anchor upstream rather than work around it here.

## Why we defer here

`infrastructure-general` is the authoritative artifact for ChainSafe infrastructure. It already ships its own [`AGENTS.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/AGENTS.md) and [`CLAUDE.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/CLAUDE.md), confirming the agent-native posture. The handbook treats it as canonical for any question whose answer involves how production systems are built, run, observed, or recovered.

Maintained by [@joshdougall](https://github.com/joshdougall) (Head of Infra). Coordination point for anything below.

## Deep-link map

### By intent

| If you are asking… | Go to (upstream) |
|---|---|
| What infrastructure runs at ChainSafe? Service catalog. | [`docs/service-catalog.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/service-catalog.md) |
| What's our tech stack across infra? | [`docs/tech-stack.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/tech-stack.md) |
| I'm joining the infra team / picking up infra work. Where do I start? | [`docs/onboarding.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/onboarding.md) |
| What's on the infra roadmap? | [`docs/endgame-roadmap.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/endgame-roadmap.md) |
| How do we triage infra backlog? | [`docs/backlog-triage.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/backlog-triage.md) |
| What's our monitoring footprint? | [`docs/observability/monitoring-inventory.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/monitoring-inventory.md) |
| How do we profile production services? | [`docs/observability/profiling.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/profiling.md) |

### By configuration domain

| Need to change… | Go to (upstream) |
|---|---|
| Ansible roles / config management | [`ansible/`](https://github.com/ChainSafe/infrastructure-general/tree/main/ansible) — 9 execution directories (Ethereum, Filecoin, Forest, Gossamer, IPFS, OP, Polkadot, zkVerify, general) |
| Terraform / cloud provisioning | [`terraform/`](https://github.com/ChainSafe/infrastructure-general/tree/main/terraform) — Auth0, data-analytics, Forest, Gossamer, Grafana Cloud, infra-dev, infra-prod, k8s, Sygma |
| Docker images we build | [`images/`](https://github.com/ChainSafe/infrastructure-general/tree/main/images) — filecoin-bootnode-monitor, grafana-alloy, nebula, polkadot-crunch, snapshot-service |
| Internal tooling and scripts | [`tools/`](https://github.com/ChainSafe/infrastructure-general/tree/main/tools) |

### By product

For product-specific infra (deployment patterns, service architecture, environment topology), the `docs/projects/` tree is the canonical home:

| Product area | Upstream path |
|---|---|
| Canton | [`docs/projects/canton/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/canton) — developer guide, k8s deployment, SV rewards, scan reports |
| Filecoin / Forest | [`docs/projects/filecoin/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/filecoin) — staging env, faucet ops, snapshot service, bootnodes, archival nodes |
| Ethereum / Lodestar | [`docs/projects/ethereum/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/ethereum) — Lodestar public services, production operations, SSV analysis, Lido validator ejector |
| SSV operators | [`docs/projects/ssv/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/ssv) — onboarding, operator registration, metadata updates, Hoodi testnet |
| IPFS | [`docs/projects/ipfs.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/projects/ipfs.md) |
| Drand | [`docs/projects/drand/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/drand) |
| WalletConnect | [`docs/projects/walletconnect/`](https://github.com/ChainSafe/infrastructure-general/tree/main/docs/projects/walletconnect) |

## How to use this page

- **As an agent:** before any task touching infrastructure, IaC, deploy, observability, or production systems, consult the intent table above. Read the upstream `AGENTS.md` for that repo's entrypoints. Do not paraphrase upstream content — fetch the actual file.
- **As an operator:** when reviewing an infra-adjacent PR, use this map to find the canonical reference. If a PR touches infra without referencing the relevant upstream doc, ask why.
- **As a contributor:** if you find yourself wanting to add infra content to this handbook, add it to `infrastructure-general` instead and update the deep-link here.

## What stays in this handbook vs. defers upstream

This handbook keeps the **operator decision policy** layer:

- When to deploy vs. when to wait (see [`release-and-deploy.md`](./release-and-deploy.md)).
- When to page vs. when to investigate quietly (see [`incident-response.md`](./incident-response.md)).
- Who approves what.

Everything else — *how* to deploy, *how* to page, *how* to investigate — defers to `infrastructure-general`. The split is intentional: policy in the handbook, execution in the infra repo.

## Coordination

[@joshdougall](https://github.com/joshdougall) is the upstream maintainer and the CODEOWNER for this pointer page (see [`../.github/CODEOWNERS`](../.github/CODEOWNERS)). Any change to the deep-link map goes through him.

When the upstream repo restructures, this page updates. The agreement is: the pointer page is the handbook's contract with `infrastructure-general`; broken links here are a bug.

## Related

- [`incident-response.md`](./incident-response.md) — incident workflow; deep-links into `infrastructure-general/docs/runbooks/`.
- [`release-and-deploy.md`](./release-and-deploy.md) — release/deploy workflow; deep-links into the same.
- [`repo-and-ci-setup.md`](./repo-and-ci-setup.md) — per-repo hygiene that sits *under* the infra layer.
- [`../references/sources.md`](../references/sources.md) — full catalog of external canonical sources.

