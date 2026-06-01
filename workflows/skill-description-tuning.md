# Skill Description Tuning

A runbook for running Anthropic's `skill-creator` description-optimization loop on one of the skills in [`skills/`](../skills/). The loop iteratively sharpens a SKILL.md's `description` field for better triggering accuracy.

> **In one line:** Opt-in, local-only, ~30–45 min wall-clock, Opus by default. Run when you have a reason to; not on a schedule, not in CI.

## Policy

The handbook's policy for this loop, in four points:

- **Opt-in.** No skill in this repo is *required* to go through the loop. The lightweight "draft + self-check" approach is the floor for any skill; the loop is sharpening, not enforcement.
- **Local-only.** The loop calls `claude -p` (real Anthropic API spend) and takes ~30–45 minutes per skill. It runs on the operator's machine, on demand. CI does not invoke it. PRs touching a SKILL.md description are not gated by it.
- **Opus by default.** When you do run the loop, default to the most capable tier (`--model claude-opus-4-6` or current Opus generation). The per-skill quality gain is worth the extra cost on an opt-in run. Sonnet/Haiku overrides are available for cheaper iteration.
- **Non-deterministic, so re-run if outputs look off.** The optimizer is an LLM; the same input can produce different best-descriptions across runs. A single run is a draft, not an oracle.

The rest of this page is the *how*.

## When to run

Three legitimate triggers:

1. **A new skill is being added** and you want its description tuned before first commit.
2. **Engineers report triggering issues** — the skill keeps firing when it shouldn't, or never fires when it should. The complaint is your eval-set raw material.
3. **Periodic hygiene pass** before a release or every quarter — re-check that descriptions still match actual triggering needs.

If none of those apply, don't run it. The lightweight "draft + self-check" floor is sufficient.

## Prerequisites

- **Claude Code installed** on your local machine with `claude -p` working (the loop calls it as a subprocess).
- **An active Anthropic API key** or whatever auth your Claude Code uses — the loop will consume real tokens.
- **Local clone of `engineering-handbook` on the branch you want to update** (typically `main`, or the working branch your team designates).
- **The skill-creator package available.** It's bundled with Claude Code; the script path is typically:
  ```
  ~/.claude/skills/skill-creator/scripts/run_loop.py
  ```
  Confirm with `find ~/.claude -name run_loop.py 2>/dev/null` if uncertain.
- **A defined skill to tune.** This runbook assumes a skill already exists in `skills/chainsafe-<name>/SKILL.md`.

## The flow

### Step 1: Draft the eval set

The eval set is ~20 realistic prompts split between *should-trigger* (the skill ought to fire) and *should-not-trigger* (near-misses that share keywords but actually need something else). Quality of the eval set determines quality of the tuned description.

**What makes a good eval query:**

- Concrete. Mention specific files, products, error messages, or refactor scopes.
- Realistic. Phrased the way an engineer would actually type it in chat — including casual phrasing, abbreviations, sometimes typos.
- ChainSafe-flavored where helpful. Reference Lodestar, Forest, Gossamer, Sygma, Canton — the product context an internal user would carry.
- Mixed-length. Some short queries, some with full backstory.
- Edge cases over clear-cut ones. The boundary cases teach the optimizer where the boundary actually is.

**Bad eval queries** to avoid:

- *"Format this data"* — too vague, not specific enough to test triggering.
- *"Write a Fibonacci function"* — too generic, doesn't test anything domain-specific.
- *"Write code for X"* — won't actually trigger any complex skill since simple coding tasks are handled directly.

**Save as JSON:**

```json
[
  {"query": "the user's prompt text", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false},
  ...
]
```

Default file location: `<skill-name>-eval-workspace/eval-set.json` outside the handbook repo (or inside it under `.gitignore`d scratch space — the eval workspace is not committed).

**Review the eval set carefully before running** — the loop will treat the labels as ground truth. A mis-labeled query gives a mis-tuned description.

### Step 2: Run the loop

Default command (Opus):

```bash
python -m scripts.run_loop \
  --eval-set <path-to-eval-set.json> \
  --skill-path <path-to-handbook>/skills/chainsafe-<name> \
  --model claude-opus-4-6 \
  --max-iterations 5 \
  --verbose
```

(Replace `claude-opus-4-6` with the current Opus generation if it's been bumped — `claude-opus-4-7`, etc.)

**Where to run from:** the skill-creator package directory, so `python -m scripts.run_loop` resolves:

```bash
cd ~/.claude/skills/skill-creator   # or wherever scripts/ lives
```

**Override flags worth knowing:**

| Flag | Purpose | Default |
|---|---|---|
| `--model` | Which Claude model to use as the optimizer + triggering tester | `claude-opus-4-6` (ChainSafe default — Opus is the recommended tier when running the loop) |
| `--max-iterations` | How many improve-and-re-evaluate cycles | 5 (good default) |
| `--verbose` | Print iteration progress to stdout | recommended on |

**Cheaper iteration:** for experimental skills or rapid prototyping, override with `--model claude-sonnet-4-6` or `--model claude-haiku-4-5`. The quality of the resulting description will likely be worse, but the run is faster and cheaper. Document the model used in the PR that lands the resulting `best_description`.

**Wall-clock expectation:** ~30–45 minutes on Opus, ~15–25 minutes on Sonnet, ~10 minutes on Haiku. The loop runs each query 3× per iteration for stable trigger-rate measurement, which is most of the time.

### Step 3: Review the report

The loop produces an HTML report — typically `report.html` in the workspace directory. Open it in your browser. It shows:

- **Per-iteration triggering scores** (train + held-out test).
- **The `best_description`** (selected by *test* score, not train, to guard against overfitting).
- **Per-query diagnostics** — which queries triggered, which didn't, and how the trigger rate changed across iterations.

The non-deterministic note: re-running the loop on the same eval set gives slightly different `best_description` outputs. The test score is what determines the winner across the iteration set; that's the number to compare.

### Step 4: Apply the result

Take `best_description` from the report (or from the JSON output the script also writes), and update the skill's SKILL.md frontmatter:

```yaml
---
name: chainsafe-<name>
description: <the new best_description>
metadata:
  ...
  description-tuned: <YYYY-MM-DD> (run_loop on <opus-class model>)
---
```

The `description-tuned` metadata field is optional but worth adding — it records when the description was last optimized and on what model, so future hygiene passes know when it's time for another run.

### Step 5: Ship as a normal PR

A SKILL.md description change is just another PR.

- Target branch is `main` (or the working branch your team designates).
- PR description includes the before/after description plus the test-score delta from the report.
- Standard review — see [`pr-authoring.md`](./pr-authoring.md) and [`code-review.md`](./code-review.md).
- The skills-sync CI check ([`scripts/check-skills-sync.sh`](../scripts/check-skills-sync.sh)) keeps the index honest; if you didn't change `llms.txt`, no update needed (descriptions are inlined in `llms.txt`'s skill entries — see if your one-line description in `llms.txt` should be refreshed alongside).

## Common pitfalls

- **Eval set too generic.** Generic queries don't trigger any skill cleanly; the loop has nothing to optimize against. Be specific.
- **Eval set too narrow.** All should-trigger queries phrased the same way → the optimizer over-fits to that phrasing → real users phrasing things differently still don't trigger. Mix phrasings.
- **Mis-labeled near-misses.** A *should-not-trigger* query that's actually a legitimate use of the skill confuses the loop into making the description narrower than it should be. Review labels carefully.
- **Running on Haiku for production-grade output.** Haiku's `best_description` is often weaker than the original. Use it only for experimentation; default is Opus for a reason.
- **Skipping the test-score check.** The loop selects `best_description` by held-out test score; spot-check that the test score is materially better than the original's test score. If it's not, the optimization didn't help — keep the original.

## Anti-patterns

- **Running the loop in CI.** Don't. Per the policy at the top of this page: the loop is opt-in and local-only.
- **Running the loop on every skill in one batch.** It's a per-skill exercise; batching introduces context-switching that doesn't pay off.
- **Letting the loop run without an eval set review pass.** The eval set is the contract; treat it as load-bearing.
- **Committing the eval workspace.** The workspace is scratch space — `report.html`, intermediate JSON, partial logs. None of it belongs in the repo. Add a `.gitignore` entry if you're keeping the workspace inside the clone.

## Related



- [`pr-authoring.md`](./pr-authoring.md) — how the resulting description change gets shipped.
- Upstream: [`anthropic-skills:skill-creator`](https://github.com/anthropics/skills) — the canonical playbook the runbook implements.
