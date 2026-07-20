# Eval-set assets for description tuning

Curated, **committed** inputs for the description-tuning loop documented in
[`../skill-description-tuning.md`](../skill-description-tuning.md).

Two kinds of file live here:

- **`eval-set.template.json`** — a fill-in-the-blank starting point. Copy it,
  rename it for your skill, and replace the placeholder queries.
- **`<skill-name>.eval-set.json`** — a gold-standard eval set for a specific
  skill (e.g. [`chainsafe-research-plan-implement.eval-set.json`](./chainsafe-research-plan-implement.eval-set.json)).
  These are the worked examples — read one before drafting your own.

## Committed inputs vs. scratch outputs

These eval sets are **inputs**: hand-curated, reviewed, version-controlled, and
treated as load-bearing (a mislabeled query produces a mis-tuned description).

The loop's **outputs** — `report.html`, `results.json`, `log.txt`, partial
logs — are scratch. They do **not** belong in the repo. The wrapper writes them
to a timestamped directory outside the working tree by default, and `.gitignore`
catches the `*-eval-workspace/` pattern as a backstop. Never commit a run's
workspace.

## Format

A JSON array of `{ "query", "should_trigger" }` objects:

```json
[
  { "query": "the prompt an engineer would actually type", "should_trigger": true },
  { "query": "a near-miss that shares keywords but needs something else", "should_trigger": false }
]
```

Aim for ~20 queries, mixed between should-trigger and should-not-trigger.
The should-not-trigger near-misses matter most — they teach the optimizer where
the skill's boundary actually is. See the parent runbook's "Draft the eval set"
step for what makes a good vs. bad query.

## Using one

```bash
# default path resolution (this directory, named after the skill):
bash scripts/tune-skill-description.sh chainsafe-research-plan-implement --dry-run

# or point at any eval set explicitly:
bash scripts/tune-skill-description.sh chainsafe-go-reviewer \
  --eval-set workflows/skill-description-tuning/chainsafe-go-reviewer.eval-set.json --dry-run
```

Drop `--dry-run` to run for real (opt-in, local-only, ~30–45 min on Opus).
