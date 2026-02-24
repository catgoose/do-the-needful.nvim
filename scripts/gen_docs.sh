#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

main() {
  TMP_DIR="$(mktemp -d)"
  echo "$TMP_DIR"

  cleanup() { rm -rf "$TMP_DIR"; }
  trap cleanup EXIT

  project_name="do-the-needful"

  if command -v ldoc 1>/dev/null; then
    # Copy source and preprocess EmmyLua annotations for LDoc compatibility
    # LDoc's built-in @class handling conflicts with EmmyLua @class
    cp -r "$PROJECT_DIR/lua" "$TMP_DIR/lua"
    find "$TMP_DIR/lua" -name '*.lua' -exec sed -i 's/---@class/---@lclass/g' {} +

    # Minimal config for EmmyLua custom tags
    cat >"$TMP_DIR/config.ld" <<'EOF'
custom_tags = {
  { "mod", hidden = true },
  { "tag", hidden = true },
  { "brief", hidden = true },
  { "enum", hidden = true },
  { "lclass", hidden = true },
}
EOF

    # html docs
    ldoc -c "$TMP_DIR/config.ld" \
      -p "$project_name" \
      -t "${project_name} Docs" \
      -u "$TMP_DIR/lua" "${@}" \
      -s "$PROJECT_DIR/doc" \
      --date "- $(date +'%B')" || cleanup
  else
    echo "Error: Install ldoc first"
  fi

  # vimdoc via lemmy-help (understands EmmyLua annotations natively)
  if command -v lemmy-help 1>/dev/null; then
    mkdir -p "$PROJECT_DIR/doc"
    lemmy-help \
      "$PROJECT_DIR/lua/do-the-needful/init.lua" \
      "$PROJECT_DIR/lua/do-the-needful/config.lua" \
      "$PROJECT_DIR/lua/do-the-needful/constants.lua" \
      "$PROJECT_DIR/lua/do-the-needful/commands.lua" \
      >"$PROJECT_DIR/doc/$project_name.txt"
    echo
    echo "$PROJECT_DIR/doc/$project_name.txt created"
  else
    echo "Warning: lemmy-help not found, skipping vimdoc generation"
    echo "  Install with: cargo install lemmy-help --features=cli"
  fi
}

main "${@}"
