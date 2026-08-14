# Work Decomposition

How a piece of planned work becomes tracked work — epic, milestones, issues — before any code is written. This is the bridge between the approved `plan.md` produced by [`chainsafe-research-plan-implement`](../skills/chainsafe-research-plan-implement/SKILL.md) and the stream of small PRs described in [`pr-authoring.md`](./pr-authoring.md).

> **In one line:** Every non-trivial effort decomposes into one epic, a set of milestones, and bite-sized issues. An issue is bite-sized when one PR closes it and one reviewer can hold that PR in their head.

## Why this page exists

The handbook already says PRs must be small ([`pr-authoring.md`](./pr-authoring.md)) and that agents stay inside operator-named scope ([agent-era invariant 1](../invariants/agent-era-invariants.md#1-no-silent-edits-outside-the-operator-named-scope)). Neither holds unless the work was *decomposed that way in the first place*. A PR is only as small as the issue behind it; an issue is only as small as the milestone that spawned it.

In the agent era this matters more, not less. An agent can produce a 3,000-line diff in one pass. The constraint that keeps that diff reviewable is not the agent's restraint — it is the decomposition the operator approved before implementation started.

## The three levels

| Level | What it is | Done when | Typical span |
|---|---|---|---|
| **Epic** | One coherent outcome a stakeholder would recognize by name ("Sprinter supports Base", "migrate Forest to the new state store"). Carries the `research.md`, `plan.md`, and any ADR. | Every milestone under it is closed and the outcome is demonstrable. | Weeks |
| **Milestone** | A demonstrable, independently-shippable slice of the epic. `main` is releasable at the end of each one. | Its issues are closed and the slice can be shown working. | Days to a week |
| **Issue** | One bite-sized unit of work. One PR closes it. | Its PR is merged and its acceptance criteria are met. | Hours to ~a day |

Every level links up and down: an issue names its milestone, a milestone names its epic, the epic links the plan artifact. That chain is what makes the [audit trail](../invariants/agent-era-invariants.md#8-every-agent-generated-change-carries-an-audit-trail) reconstructible six months later.

**Small work does not need all three levels.** A single-issue bug fix is a single issue. The rule is that work *large enough to need a plan* is large enough to need decomposition — do not invent an epic to hold one issue, and do not hide fifteen issues' worth of work inside one.

## What makes an issue bite-sized

An issue is bite-sized when **all** of these hold. There is deliberately no line-count threshold — the bar is reviewability, not arithmetic.

- **One PR closes it.** If closing it needs two PRs, it is two issues.
- **One reviewer can review that PR in a single focused pass** — the ~10-minute standard from [`pr-authoring.md`](./pr-authoring.md#small-focused-self-contained). If a reviewer would have to schedule time for it, it is too big.
- **It has written acceptance criteria** before work starts. "Done" is testable, not a matter of opinion.
- **It carries no open design decision.** All the creative choices were made in the plan and annotation cycles. Implementation of a bite-sized issue is mechanical.
- **It names the files or areas it expects to touch.** This is the scope statement the reviewer checks the diff against.
- **It is independently understandable.** Someone can pick it up without reading the entire epic.

If an issue fails any of these, split it. The usual split lines: interface before implementation; migration before cutover; one call site per issue; tests-for-existing-behavior before the behavior change.

## From `plan.md` to the tracker

The [`chainsafe-research-plan-implement`](../skills/chainsafe-research-plan-implement/SKILL.md) workflow already ends its annotation cycle by producing a phased todo list. That artifact *is* the decomposition — it just needs to be mapped:

| In `plan.md` | In the tracker |
|---|---|
| The plan as a whole | The epic |
| Each phase | A milestone |
| Each individual task | An issue |

Sequence:

1. **Agent proposes the breakdown inside `plan.md`** — epic statement, milestones, and the issue list with acceptance criteria and expected file scope per issue. It does not create anything in the tracker yet.
2. **Operator annotates and approves it** as part of the normal annotation cycle. Re-cutting the decomposition is cheap here and expensive later.
3. **Issues get created only after approval.** Creating issues on a human's behalf trips the [external-communication gate](../operating-model/gates-and-escalation.md#4-external-communication) — the agent proposes, the operator authorizes.
4. **Implementation runs issue by issue**, one PR per issue, each PR linking its issue.
5. **The plan stays the source of truth.** If implementation reveals the decomposition was wrong, update `plan.md` and re-cut the issues; do not silently merge two issues into one PR.

## Tracker conventions

Tracker-agnostic by design — GitHub is the ChainSafe default, and projects on Linear or Jira map the same three levels onto their own primitives ([`repo-and-ci-setup.md`](./repo-and-ci-setup.md#10-notifications-and-integrations)).

On GitHub:

- **Epic** — an issue labelled `epic`, listing its milestones as a task list, linking `plan.md`.
- **Milestone** — a native GitHub milestone. Issues are assigned to it; the milestone burns down to zero.
- **Issue** — a normal issue with the standard label taxonomy from [`repo-and-ci-setup.md`](./repo-and-ci-setup.md#8-labels), assigned to a milestone, referenced by its PR with `Closes: #N`.

## Anti-patterns

- **The ticket that is really an epic.** "Add multi-chain support" as a single issue. Nobody can review the PR that closes it.
- **Decomposition after the fact.** Writing the issues once the branch is already 2,000 lines deep. The breakdown is a planning artifact, not a filing exercise.
- **Milestones that cannot ship.** A "milestone" that leaves `main` broken until the next one lands is not a milestone; it is a checkpoint. Re-cut it.
- **Issues without acceptance criteria.** These become "done when the author says so," which is exactly what the reviewer cannot verify.
- **The agent that creates the tracker structure unasked.** Proposing the breakdown is the job; creating issues without approval is a gate violation.
- **Silent re-merging.** Closing three issues with one PR because "they were all related." If they really were, the decomposition should have been fixed in `plan.md` first.

## Related

- [`../skills/chainsafe-research-plan-implement/SKILL.md`](../skills/chainsafe-research-plan-implement/SKILL.md) — the workflow that produces the plan this page decomposes.
- [`pr-authoring.md`](./pr-authoring.md) — the PR half of the same discipline: one issue, one PR, small enough to review.
- [`code-review.md`](./code-review.md) — where an under-decomposed change gets caught.
- [`repo-and-ci-setup.md`](./repo-and-ci-setup.md) — label taxonomy and tracker integration this page assumes.
- [`../operating-model/gates-and-escalation.md`](../operating-model/gates-and-escalation.md#10-oversized-or-multi-concern-changes) — the gate for changes that outgrow their issue.
- [`../invariants/agent-era-invariants.md`](../invariants/agent-era-invariants.md#1-no-silent-edits-outside-the-operator-named-scope) — scope discipline, which decomposition is the precondition for.
