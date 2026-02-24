#!/usr/bin/env bash
# Generate vimdoc from LuaCATS annotations using lemmy-help
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$ROOT_DIR/doc/do-the-needful.txt"

# Check for lemmy-help
if command -v lemmy-help &>/dev/null; then
  LEMMY=lemmy-help
elif [ -x "$ROOT_DIR/deps/lemmy-help" ]; then
  LEMMY="$ROOT_DIR/deps/lemmy-help"
else
  echo "lemmy-help not found. Install via:"
  echo "  cargo install lemmy-help"
  echo "  or download from https://github.com/numToStr/lemmy-help/releases"
  exit 1
fi

echo "Generating vimdoc with $LEMMY..."

# Ordered list of source files for doc generation
# Priority A — public API first, then internals
$LEMMY -f -a \
  "$ROOT_DIR/lua/do-the-needful/init.lua" \
  "$ROOT_DIR/lua/do-the-needful/config.lua" \
  "$ROOT_DIR/lua/do-the-needful/constants.lua" \
  "$ROOT_DIR/lua/do-the-needful/commands.lua" \
  > "$OUT"

echo "Generated $OUT"
