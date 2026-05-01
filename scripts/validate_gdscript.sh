#!/bin/bash
# Called by the PostToolUse hook after any .gd file is written.
# 1. Fast pattern check for GDScript 1.x syntax
# 2. Headless Godot validation for real parse errors
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0
[[ "$FILE_PATH" != *.gd ]] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

CONTENT=$(cat "$FILE_PATH")
WARNINGS=""

if echo "$CONTENT" | grep -qE '^\s*onready\s+var\s'; then
  WARNINGS="$WARNINGS\n  - Found 'onready var' — should be '@onready var' (GDScript 2.0)"
fi
if echo "$CONTENT" | grep -qE '^\s*export\s+var\s'; then
  WARNINGS="$WARNINGS\n  - Found 'export var' — should be '@export var' (GDScript 2.0)"
fi
if echo "$CONTENT" | grep -qE '\byield\s*\('; then
  WARNINGS="$WARNINGS\n  - Found 'yield()' — use 'await' (GDScript 2.0)"
fi
if echo "$CONTENT" | grep -qE '\.connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"[^"]+"\s*\)'; then
  WARNINGS="$WARNINGS\n  - Old signal.connect(name, self, method) — use signal.connect(callable)"
fi
if echo "$CONTENT" | grep -qE '\._[a-z_]+\s*\('; then
  WARNINGS="$WARNINGS\n  - Found '._method()' — use 'super.method()' (GDScript 2.0)"
fi

if [ -n "$WARNINGS" ]; then
  echo -e "GDScript 1.x syntax detected in $(basename "$FILE_PATH"):$WARNINGS" >&2
  exit 1
fi

# Headless Godot parse check
GODOT=$(which godot 2>/dev/null || which godot4 2>/dev/null || \
  ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1 || true)

if [ -z "$GODOT" ]; then
  echo "Warning: godot not found, skipping parse validation" >&2
  exit 0
fi

# Walk up to find project root
PROJECT_ROOT=$(dirname "$FILE_PATH")
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/project.godot" ]; do
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done

if [ ! -f "$PROJECT_ROOT/project.godot" ]; then
  echo "Warning: project.godot not found, skipping parse validation" >&2
  exit 0
fi

cd "$PROJECT_ROOT"
if ! "$GODOT" --headless --check-only 2>&1; then
  echo "GDScript parse error in $FILE_PATH — fix before continuing." >&2
  exit 1
fi

exit 0