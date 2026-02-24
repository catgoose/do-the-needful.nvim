#!/usr/bin/env bash
# Generate all documentation (vimdoc + HTML)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Generating vimdoc ==="
"$SCRIPT_DIR/gen_vimdoc.sh"

echo ""
echo "=== Generating HTML docs ==="
"$SCRIPT_DIR/gen_html.sh"

echo ""
echo "Done! All docs generated."
