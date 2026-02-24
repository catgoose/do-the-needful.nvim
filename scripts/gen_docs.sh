#!/usr/bin/env bash

set -euo pipefail

# Generate vimdoc using lemmy-help
# Install: cargo install lemmy-help --features=cli
#      or: download from https://github.com/numToStr/lemmy-help/releases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="$PROJECT_DIR/doc/do-the-needful.txt"

if ! command -v lemmy-help &>/dev/null; then
  echo "Error: lemmy-help not found. Install with: cargo install lemmy-help --features=cli"
  exit 1
fi

mkdir -p "$PROJECT_DIR/doc"

# List source files in logical order: main module first, then config,
# then constants, then commands
lemmy-help \
  "$PROJECT_DIR/lua/do-the-needful/init.lua" \
  "$PROJECT_DIR/lua/do-the-needful/config.lua" \
  "$PROJECT_DIR/lua/do-the-needful/constants.lua" \
  "$PROJECT_DIR/lua/do-the-needful/commands.lua" \
  >"$OUTPUT"

echo "$OUTPUT created"
