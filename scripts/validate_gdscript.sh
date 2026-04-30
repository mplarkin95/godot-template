#!/bin/bash
# validate_gdscript.sh
# Called by the PostToolUse hook after any .gd file is written.
# Uses godot-ai MCP's script validation if the server is running,
# otherwise just checks for common GDScript 1.x patterns that
# indicate the model wrote outdated syntax.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only act on .gd files
if [[ "$FILE_PATH" != *.gd ]]; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

CONTENT=$(cat "$FILE_PATH")
WARNINGS=""

# Check for GDScript 1.x patterns
if echo "$CONTENT" | grep -qE '^\s*onready\s+var\s'; then
  WARNINGS="$WARNINGS\n  ⚠ Found 'onready var' — should be '@onready var' (GDScript 2.0)"
fi

if echo "$CONTENT" | grep -qE '^\s*export\s+var\s'; then
  WARNINGS="$WARNINGS\n  ⚠ Found 'export var' — should be '@export var' (GDScript 2.0)"
fi

if echo "$CONTENT" | grep -qE '\byield\s*\('; then
  WARNINGS="$WARNINGS\n  ⚠ Found 'yield()' — use 'await' instead (GDScript 2.0)"
fi

if echo "$CONTENT" | grep -qE '\.connect\s*\(\s*"[^"]+"\s*,\s*self\s*,\s*"[^"]+"\s*\)'; then
  WARNINGS="$WARNINGS\n  ⚠ Found old signal.connect(name, self, method) syntax — use signal.connect(callable)"
fi

if echo "$CONTENT" | grep -qE '\._[a-z_]+\s*\('; then
  WARNINGS="$WARNINGS\n  ⚠ Found '._method()' — use 'super.method()' for parent calls (GDScript 2.0)"
fi

if [ -n "$WARNINGS" ]; then
  echo -e "GDScript 2.0 issues detected in $FILE_PATH:$WARNINGS\n\nPlease fix before continuing." >&2
  # Return as a context injection (not a block — just a warning)
  echo "{\"type\":\"text\",\"text\":\"GDScript validation warnings for $FILE_PATH:$WARNINGS\"}"
fi

exit 0