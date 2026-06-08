#!/usr/bin/env bash
# scripts/tune-skill-description.sh
#
# Push-button on-ramp for the OPT-IN skill description-tuning loop.
# Wraps Anthropic skill-creator's `python -m scripts.run_loop` with the
# ChainSafe conventions baked in (Opus by default, sane flags, scratch
# outputs kept out of the repo).
#
# This is the executable form of workflows/skill-description-tuning.md.
# Read that runbook for the policy and the why. In one line: opt-in,
# local-only, ~30-45 min wall-clock on Opus, real Anthropic API spend.
# Not a CI gate. Run it only when you have a reason to.
#
# Usage:
#   bash scripts/tune-skill-description.sh <skill-name> [options]
#
#   <skill-name>            A directory under skills/ (e.g. chainsafe-go-reviewer)
#                           or a path to a skill directory containing SKILL.md.
#
# Options:
#   --eval-set PATH         Eval-set JSON. Default:
#                           workflows/skill-description-tuning/<skill>.eval-set.json
#   --model ID              Optimizer model. Default: claude-opus-4-6 (env: TUNE_MODEL).
#   --max-iterations N      Improve/re-evaluate cycles. Default: 5.
#   --results-dir DIR       Where results.json/report.html/log.txt land. Default: a
#                           timestamped scratch dir OUTSIDE the repo (env: TUNE_RESULTS_DIR).
#   --dry-run               Print the resolved command without running it.
#   -h, --help              Show this help.
#
# Environment overrides:
#   TUNE_MODEL              Default optimizer model.
#   TUNE_RESULTS_DIR        Base dir for scratch outputs.
#   SKILL_CREATOR_DIR       Path to the skill-creator package (auto-detected if unset).
#
# Exit codes: 0 ok / dry-run · 1 runtime failure · 2 usage or environment error.

set -euo pipefail

# --- locate the repo root (this script lives in <repo>/scripts/) ----------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- defaults -------------------------------------------------------------------
MODEL="${TUNE_MODEL:-claude-opus-4-6}"
MAX_ITER=5
EVAL_SET=""
RESULTS_DIR=""
DRY_RUN=0

usage() { sed -n '2,40p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

die() { printf 'ERROR: %s\n' "$*" >&2; exit 2; }

# --- parse args -----------------------------------------------------------------
SKILL_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)        usage; exit 0 ;;
    --dry-run)        DRY_RUN=1; shift ;;
    --eval-set)       EVAL_SET="${2:-}"; [[ -n "$EVAL_SET" ]] || die "--eval-set needs a path"; shift 2 ;;
    --model)          MODEL="${2:-}"; [[ -n "$MODEL" ]] || die "--model needs an id"; shift 2 ;;
    --max-iterations) MAX_ITER="${2:-}"; [[ "$MAX_ITER" =~ ^[0-9]+$ ]] || die "--max-iterations needs an integer"; shift 2 ;;
    --results-dir)    RESULTS_DIR="${2:-}"; [[ -n "$RESULTS_DIR" ]] || die "--results-dir needs a path"; shift 2 ;;
    --)               shift; break ;;
    -*)               die "unknown option: $1 (try --help)" ;;
    *)                [[ -z "$SKILL_ARG" ]] || die "unexpected extra argument: $1"; SKILL_ARG="$1"; shift ;;
  esac
done

[[ -n "$SKILL_ARG" ]] || { usage; echo; die "no skill specified"; }

# --- resolve the skill path -----------------------------------------------------
if [[ "$SKILL_ARG" == */* || -d "$SKILL_ARG" ]]; then
  SKILL_PATH="$(cd "$SKILL_ARG" 2>/dev/null && pwd || true)"
  [[ -n "$SKILL_PATH" ]] || die "skill path not found: $SKILL_ARG"
else
  SKILL_PATH="$REPO_ROOT/skills/$SKILL_ARG"
fi
SKILL_NAME="$(basename "$SKILL_PATH")"
[[ -f "$SKILL_PATH/SKILL.md" ]] || die "no SKILL.md under: $SKILL_PATH
       Pass a directory name under skills/ (e.g. chainsafe-go-reviewer) or a full path."

# --- resolve the eval set -------------------------------------------------------
if [[ -z "$EVAL_SET" ]]; then
  EVAL_SET="$REPO_ROOT/workflows/skill-description-tuning/$SKILL_NAME.eval-set.json"
fi
if [[ ! -f "$EVAL_SET" ]]; then
  die "eval set not found: $EVAL_SET
       Draft one from the template:
         workflows/skill-description-tuning/eval-set.template.json
       then pass it with --eval-set, or save it at the default path above."
fi

# --- locate the skill-creator package ------------------------------------------
if [[ -z "${SKILL_CREATOR_DIR:-}" ]]; then
  SKILL_CREATOR_DIR="$HOME/.claude/skills/skill-creator"
  if [[ ! -f "$SKILL_CREATOR_DIR/scripts/run_loop.py" ]]; then
    found="$(find "$HOME/.claude" -name run_loop.py -path '*skill-creator*' 2>/dev/null | head -1)"
    [[ -n "$found" ]] && SKILL_CREATOR_DIR="$(cd "$(dirname "$found")/.." && pwd)"
  fi
fi
[[ -f "$SKILL_CREATOR_DIR/scripts/run_loop.py" ]] || die "skill-creator's run_loop.py not found.
       Looked under: $SKILL_CREATOR_DIR/scripts/run_loop.py
       Set SKILL_CREATOR_DIR to the skill-creator package directory."

# --- preflight: the loop shells out to \`claude -p\` -----------------------------
command -v python3 >/dev/null 2>&1 || die "python3 not on PATH."
if ! command -v claude >/dev/null 2>&1; then
  echo "WARNING: the \`claude\` CLI is not on PATH. The loop calls \`claude -p\` as a" >&2
  echo "         subprocess and will fail without it. Install Claude Code first." >&2
fi

# --- default scratch results dir, OUTSIDE the repo ------------------------------
if [[ -z "$RESULTS_DIR" ]]; then
  RESULTS_DIR="${TUNE_RESULTS_DIR:-${TMPDIR:-/tmp}/skill-tuning}/${SKILL_NAME}-$(date +%Y%m%d-%H%M%S)"
fi

# --- assemble the command -------------------------------------------------------
CMD=(python3 -m scripts.run_loop
  --eval-set "$EVAL_SET"
  --skill-path "$SKILL_PATH"
  --model "$MODEL"
  --max-iterations "$MAX_ITER"
  --verbose
  --results-dir "$RESULTS_DIR")

echo "------------------------------------------------------------------"
echo " skill        : $SKILL_NAME"
echo " skill path   : $SKILL_PATH"
echo " eval set     : $EVAL_SET"
echo " model        : $MODEL"
echo " max-iter     : $MAX_ITER"
echo " results dir  : $RESULTS_DIR"
echo " run from     : $SKILL_CREATOR_DIR"
echo "------------------------------------------------------------------"
printf ' command      : (cd %q && ' "$SKILL_CREATOR_DIR"
printf '%q ' "${CMD[@]}"
printf ')\n'
echo "------------------------------------------------------------------"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] not executing. Drop --dry-run to run for real (~30-45 min on Opus)."
  exit 0
fi

echo "OPT-IN loop: local-only, ~30-45 min on Opus, real Anthropic API spend. Ctrl-C to abort."
mkdir -p "$RESULTS_DIR"
cd "$SKILL_CREATOR_DIR"
exec "${CMD[@]}"
