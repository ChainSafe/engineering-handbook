#!/usr/bin/env bash
# scripts/check-skill-descriptions.sh
#
# Verifies that every `description` in a skills/*/SKILL.md frontmatter fits
# inside the 1024-character limit that Claude Code enforces when it loads a
# skill. An over-length description is not a style nit — the skill fails to
# load, so the skill is silently unavailable. That makes it a CI failure.
#
# The limit is characters, not bytes: descriptions routinely contain em-dashes
# and other multi-byte punctuation, so counting is done under a UTF-8 locale.
#
# Run from the repo root:
#   bash scripts/check-skill-descriptions.sh
#
# Exit codes:
#   0 — every description is within the limit.
#   1 — at least one description is over the limit.
#   2 — usage / environment error.

set -euo pipefail

cd "$(dirname "$0")/.."

readonly MAX_CHARS=1024

if [[ ! -d skills ]]; then
    echo "ERROR: skills/ directory not found. Run from repo root." >&2
    exit 2
fi

# Count characters, not bytes. C.UTF-8 exists on the CI runners; en_US.UTF-8 is
# the macOS fallback. Either way `wc -m` then counts code points.
if locale -a 2>/dev/null | grep -qi '^C\.UTF-\?8$'; then
    export LC_ALL=C.UTF-8
else
    export LC_ALL=en_US.UTF-8
fi

# Extract the frontmatter `description:` value. Handles the value spilling onto
# continuation lines (YAML folds them) by accumulating until the next top-level
# key or the closing `---`.
extract_description() {
    awk '
        NR == 1 && $0 == "---" { in_fm = 1; next }
        !in_fm { exit }
        $0 == "---" { exit }
        /^description:[[:space:]]*/ {
            sub(/^description:[[:space:]]*/, "")
            print
            capturing = 1
            next
        }
        capturing && /^[A-Za-z_-]+:/ { exit }
        capturing { sub(/^[[:space:]]+/, ""); print }
    ' "$1" | tr '\n' ' ' | sed -e 's/[[:space:]]\{1,\}/ /g' -e 's/^ //' -e 's/ $//'
}

status=0
checked=0

for dir in skills/*/; do
    file="${dir%/}/SKILL.md"
    [[ -f "$file" ]] || continue
    checked=$((checked + 1))

    description=$(extract_description "$file")
    if [[ -z "$description" ]]; then
        echo "ERROR: no frontmatter description found in $file"
        status=1
        continue
    fi

    # printf '%s' — no trailing newline, so it is not counted.
    length=$(printf '%s' "$description" | wc -m | tr -d ' ')
    if (( length > MAX_CHARS )); then
        echo "ERROR: $file — description is $length chars (limit $MAX_CHARS, over by $((length - MAX_CHARS)))"
        status=1
    fi
done

if (( checked == 0 )); then
    echo "ERROR: no SKILL.md files found under skills/." >&2
    exit 2
fi

if (( status == 0 )); then
    echo "OK: $checked skill descriptions, all within the $MAX_CHARS-character limit."
fi

exit $status
