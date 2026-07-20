#!/usr/bin/env bash
# scripts/build-pages.sh
#
# Assembles the Cloudflare Pages publish directory (`public/`). This is the
# build command for the Git-connected `engineering-handbook` Pages project:
#
#   Build command:          bash scripts/build-pages.sh
#   Build output directory: public
#
# The static routing/header files (`public/_redirects`, `public/_headers`) are
# committed. Generated artifacts — currently just `llms.txt`, copied from the
# repo root so the root file stays the single source of truth — are produced
# here at build time and are git-ignored. Add further build steps below as the
# published surface grows (extra assets, generated pages, minification, etc.).
#
# Run from anywhere; it cd's to the repo root itself.
#
# Exit codes:
#   0 — publish dir assembled.
#   1 — a required source file is missing.

set -euo pipefail

cd "$(dirname "$0")/.."

PUBLIC_DIR="public"

if [[ ! -f llms.txt ]]; then
  echo "build-pages: llms.txt not found at repo root" >&2
  exit 1
fi

mkdir -p "$PUBLIC_DIR"

# --- generated artifacts ------------------------------------------------------
cp llms.txt "$PUBLIC_DIR/llms.txt"
echo "build-pages: copied llms.txt -> $PUBLIC_DIR/llms.txt"

# Add further publish steps here.
# ------------------------------------------------------------------------------

echo "build-pages: publish dir ready:"
ls -1 "$PUBLIC_DIR"
