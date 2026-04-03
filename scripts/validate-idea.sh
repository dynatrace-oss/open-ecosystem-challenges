#!/usr/bin/env bash
# validate-idea.sh — Checks that an adventure idea file follows the required template format.
#
# Usage:
#   ./scripts/validate-idea.sh ideas/my-idea.md
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed

# ---------------------------------------------------------------------------
# Strict mode
# ---------------------------------------------------------------------------
# -e is intentionally NOT set — we want all checks to run and collect every
# failure before exiting, so the contributor sees everything at once.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/scripts/idea-parser.sh
source "$SCRIPT_DIR/../lib/scripts/idea-parser.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ERRORS=()

# fail   — collects a failure; execution continues so all checks run
# hard_fail — for fatal pre-conditions where continuing makes no sense
fail() {
  ERRORS+=("❌ $1")
}

pass() {
  echo "✅ $1"
}

hard_fail() {
  echo "❌ $1" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Argument handling
# ---------------------------------------------------------------------------
[[ $# -ne 1 ]] && hard_fail "Usage: $0 <path-to-idea-file>"

FILE="$1"
[[ -f "$FILE" ]] || hard_fail "File not found: $FILE"

echo ""
echo "Validating: $FILE"
echo "-------------------------------------------"

# ---------------------------------------------------------------------------
# Check 1 — File guard
# ---------------------------------------------------------------------------
# Block .implemented/ files — they predate the current format and would fail.
[[ "$FILE" =~ ideas/\.implemented/ ]] \
  && hard_fail "Skipping already-implemented idea: $FILE"

pass "File guard passed"

# ---------------------------------------------------------------------------
# Check 2 — Required top-level sections
# ---------------------------------------------------------------------------
ERRORS_BEFORE=${#ERRORS[@]}

grep -qE "$ADVENTURE_HEADER_PATTERN" "$FILE" \
  || fail "Missing or incomplete file header — first line must be: # Adventure Idea: [emoji] [Your Adventure Name]"
parse_adventure_header "$FILE"

grep -q "^## Overview" "$FILE" \
  || fail "Missing required section: '## Overview' — use ATX heading style (## Overview), not bold text (**Overview**) or underline-style headings"

grep -q "^## Levels" "$FILE" \
  || fail "Missing required section: '## Levels' — use ATX heading style (## Levels), not bold text or underline-style headings"

[[ ${#ERRORS[@]} -eq $ERRORS_BEFORE ]] && pass "Required top-level sections present"

# ---------------------------------------------------------------------------
# Check 3 — Required Overview fields
# ---------------------------------------------------------------------------
ERRORS_BEFORE=${#ERRORS[@]}

theme=$(extract_overview_field "$FILE" "Theme")
printf '%s' "$theme" | grep -q '\S' \
  || fail "Missing or empty required field: '**Theme:**' — add 2-3 sentences after the field label"

grep -q "^\*\*Skills:\*\*" "$FILE" \
  || fail "Missing required Overview field: '**Skills:**'"

technologies=$(extract_overview_field "$FILE" "Technologies")
printf '%s' "$technologies" | grep -q '\S' \
  || fail "Missing or empty required field: '**Technologies:**' — list the tools on the same line"

[[ ${#ERRORS[@]} -eq $ERRORS_BEFORE ]] && pass "Required Overview fields present"

# ---------------------------------------------------------------------------
# Check 4 — Level heading format and parseability
# ---------------------------------------------------------------------------
# new-adventure.sh parses each ### heading via parse_level_heading() to extract
# emoji, difficulty, name, and slug. We validate format here AND exercise the
# same parser so both scripts stay in sync.

ERRORS_BEFORE=${#ERRORS[@]}

if ! grep -q '^### ' "$FILE"; then
  fail "No level headings found — add at least one '### EMOJI DIFFICULTY: Name' heading under '## Levels'"
else
  while IFS= read -r heading; do
    stripped="${heading#\#\#\# }"

    if echo "$heading" | grep -qE "$LEVEL_HEADING_PATTERN"; then
      parse_level_heading "$stripped"
      [[ -n "$level_emoji" ]]      || fail "Could not parse emoji from: '$heading'"
      [[ -n "$level_difficulty" ]] || fail "Could not parse difficulty from: '$heading'"
      [[ -n "$level_name" ]]       || fail "Could not parse level name from: '$heading'"
      [[ -n "$level_slug" ]]       || fail "Could not parse level slug from: '$heading'"
    else
      fail "Malformed level heading: '$heading' — expected format: ### 🟢 Beginner: Level Name"
    fi
  done < <(grep '^### ' "$FILE")
fi

[[ ${#ERRORS[@]} -eq $ERRORS_BEFORE ]] && pass "Level heading format valid"

# ---------------------------------------------------------------------------
# Check 5 — Required subsections present and non-empty for each level
# ---------------------------------------------------------------------------
# Checks every level individually so a section missing from one level is caught
# even if another level has it. Mirrors exactly what new-adventure.sh extracts.

ERRORS_BEFORE=${#ERRORS[@]}

while IFS= read -r heading; do
  stripped="${heading#\#\#\# }"

  desc=$(extract_level_description "$FILE" "$stripped")
  [[ -n "$desc" ]] \
    || fail "Level '$stripped': '#### Description' is missing or has no content"

  for section in "Story" "The Problem" "Objective" "What You'll Learn" "Tools & Infrastructure"; do
    content=$(extract_level_section "$FILE" "$stripped" "$section")
    printf '%s' "$content" | grep -q '\S' \
      || fail "Level '$stripped': '#### $section' is missing or has no content"
  done
done < <(grep '^### ' "$FILE")

[[ ${#ERRORS[@]} -eq $ERRORS_BEFORE ]] && pass "All required level sections present"

# ---------------------------------------------------------------------------
# Check 6 — No unfilled template placeholders (Python one-liner)
# ---------------------------------------------------------------------------
# Shell regex can't cleanly distinguish [placeholder] from [link text](url).
# Python's negative lookahead (?!\() handles this: matches [text] not followed
# by '(', which filters out Markdown links. [x] and [ ] (checkboxes) are excluded.
# Skipped for the template file itself, which intentionally contains placeholders.

if [[ "$FILE" != *"adventure-idea-template.md" ]]; then

  ERRORS_BEFORE=${#ERRORS[@]}

  PLACEHOLDER_OUTPUT=$(python3 -c "
import re, sys
content = open(sys.argv[1]).read()
hits = [m for m in re.findall(r'\[([^\]\n]+)\](?!\()', content) if m not in ('x', ' ')]
if hits:
    print(' '.join(hits))
    sys.exit(1)
" "$FILE") || fail "Unfilled template placeholders — replace: $PLACEHOLDER_OUTPUT"

  [[ ${#ERRORS[@]} -eq $ERRORS_BEFORE ]] && pass "No unfilled template placeholders"

fi

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
echo ""
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "Found ${#ERRORS[@]} problem(s) in: $FILE"
  echo ""
  for msg in "${ERRORS[@]}"; do
    echo "  $msg"
  done
  echo ""
  exit 1
else
  echo "✅ All checks passed for: $FILE"
  echo ""
fi
