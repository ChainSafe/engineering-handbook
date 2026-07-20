#!/usr/bin/env bash
# scripts/check-skills-sync.sh
#
# Verifies that the set of skills in `skills/` matches the set referenced in
# `llms.txt`. Drift between the two is a CI failure — the index
# and the bundles ship together, not separately.
#
# Run from the repo root:
#   bash scripts/check-skills-sync.sh
#
# Exit codes:
#   0 — in sync.
#   1 — drift detected (skill present but not indexed, or indexed but missing).
#   2 — usage / environment error.

set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -d skills ]]; then
    echo "ERROR: skills/ directory not found. Run from repo root." >&2
    exit 2
fi
if [[ ! -f llms.txt ]]; then
    echo "ERROR: llms.txt not found at repo root." >&2
    exit 2
fi

# Skills on disk: every directory under skills/ that contains a SKILL.md.
on_disk=$(
    for d in skills/*/; do
        if [[ -f "$d/SKILL.md" ]]; then
            basename "$d"
        fi
    done | sort -u
)

# Skills indexed in llms.txt: URLs of the form
#   .../skills/<name>/SKILL.md
in_index=$(
    grep -oE 'skills/[a-z0-9-]+/SKILL\.md' llms.txt \
        | awk -F'/' '{print $2}' \
        | sort -u
)

# Identify drift.
missing_from_index=$(comm -23 <(echo "$on_disk") <(echo "$in_index") || true)
missing_from_disk=$(comm -13 <(echo "$on_disk") <(echo "$in_index") || true)

status=0

if [[ -n "$missing_from_index" ]]; then
    echo "ERROR: skill(s) present in skills/ but not indexed in llms.txt:"
    echo "$missing_from_index" | sed 's/^/  - /'
    status=1
fi

if [[ -n "$missing_from_disk" ]]; then
    echo "ERROR: skill(s) referenced in llms.txt but missing from skills/:"
    echo "$missing_from_disk" | sed 's/^/  - /'
    status=1
fi

if [[ $status -eq 0 ]]; then
    count=$(echo "$on_disk" | wc -l | tr -d ' ')
    echo "OK: $count skills, all synced between skills/ and llms.txt."
fi

exit $status
