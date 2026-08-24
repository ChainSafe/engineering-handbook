# Infrastructure and DevOps

For all infrastructure, IaC, deployment topology, observability, on-call, and DevOps practice, the canonical source is **[`ChainSafe/infrastructure-general`](https://github.com/ChainSafe/infrastructure-general)**. This handbook does not duplicate it.

> **In one line:** This page is a navigation surface, not a tutorial. Deep links by intent into the canonical repo; no "see also" gestures.

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
| How is our monitoring stack put together? | [`docs/observability/monitoring-overview.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/monitoring-overview.md) |
| How is alerting and on-call actually wired? | [`docs/observability/alerting-and-oncall.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/alerting-and-oncall.md) |
| How are metrics collected and stored? | [`docs/observability/metrics.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/metrics.md) |
| How is logging wired? | [`docs/observability/logging.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/logging.md) |
| How is tracing wired? | [`docs/observability/tracing.md`](https://github.com/ChainSafe/infrastructure-general/blob/main/docs/observability/tracing.md) |

### By configuration domain

| Need to change… | Go to (upstream) |
|---|---|
| Ansible roles / config management | [`ansible/`](https://github.com/ChainSafe/infrastructure-general/tree/main/ansible) — one self-contained execution directory per project, each with its own `ansible.cfg`, inventory, `group_vars/`, and `Makefile`. Being collapsed onto the consolidated `ansible/general/` pattern with YAML inventory ([#1238](https://github.com/ChainSafe/infrastructure-general/issues/1238)); superseded directories move to `ansible/_OLD/`. Read the tree, not a list here — it changes monthly. |
| Terraform / cloud provisioning | [`terragrunt/`](https://github.com/ChainSafe/infrastructure-general/tree/main/terragrunt) — **the live home for all Terraform.** `_modules/` holds the actual `.tf`; `stacks/` holds leaf `terragrunt.hcl` only, grouped `aws/<account>/` and `saas/<provider>/`. Per-account S3 state bootstrapped from `_bootstrap/tf-state/`. Consolidation epic [#1400](https://github.com/ChainSafe/infrastructure-general/issues/1400) is closed. |
| Legacy Terraform (do not add to) | [`terraform/`](https://github.com/ChainSafe/infrastructure-general/tree/main/terraform) — **legacy, being decommissioned** ([#1416](https://github.com/ChainSafe/infrastructure-general/issues/1416)). New stacks go in `terragrunt/`. |
| Docker images we build | [`images/`](https://github.com/ChainSafe/infrastructure-general/tree/main/images) — `filecoin-boonode-monitor` (spelling is upstream's), `grafana-alloy`, `nebula`, `polkadot-crunch`, `snapshot-service` |
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

