#!/usr/bin/env bash
# idea-parser.sh — Shared parsing functions for adventure idea files.
# Sourced by scripts/validate-idea.sh and scripts/new-adventure.sh.
#
# IMPORTANT: The level heading format is enforced here and in both scripts.
# If you change the format, update this file, adventure-idea-template.md,
# and any existing idea files in ideas/.

# Expected format for the # Adventure Idea: header line:
#   # Adventure Idea: EMOJI Adventure Name
ADVENTURE_HEADER_PATTERN='^# Adventure Idea: \S+ .+'

# Expected format for a ### level heading line (full line including ###):
#   ### EMOJI DIFFICULTY: Level Name
LEVEL_HEADING_PATTERN='^### \S+ \S+: .+'

# parse_adventure_header FILE
# Parses the '# Adventure Idea: EMOJI Name' header line.
# Sets: adventure_emoji, adventure_name
parse_adventure_header() {
  local file="$1"
  local header
  header=$(grep -m1 '^# Adventure Idea:' "$file" | sed 's/^# Adventure Idea: *//')
  adventure_emoji=$(echo "$header" | awk '{print $1}')
  adventure_name=$(echo "$header" | cut -d' ' -f2-)
}

# parse_level_heading HEADING
# Parses a stripped level heading (without leading "### ") into components.
# Sets: level_emoji, level_difficulty, level_name, level_slug
parse_level_heading() {
  local heading="$1"
  level_emoji=$(echo "$heading" | awk '{print $1}')
  level_difficulty=$(echo "$heading" | awk '{print $2}' | tr -d ':')
  level_name=$(echo "$heading" | sed 's/[^ ]* [^:]*: //')
  level_slug=$(echo "$level_difficulty" | tr '[:upper:]' '[:lower:]')
}

# extract_overview_field FILE FIELD
# Prints the content of a **FIELD:** block: any inline text on the same line,
# plus continuation lines, until the next bold field (**...**) or ## heading.
extract_overview_field() {
  local file="$1" field="$2"
  awk -v field="$field" '
    $0 ~ ("^\\*\\*" field ":\\*\\*") {
      sub("^\\*\\*" field ":\\*\\* *", "")
      if (NF > 0) print
      in_field = 1
      next
    }
    in_field && (/^\*\*/ || /^##/ || /^---/) { exit }
    in_field { print }
  ' "$file"
}

# extract_level_section FILE LEVEL SECTION
# Prints the content of a #### subsection within a ### level block.
extract_level_section() {
  local file="$1" level="$2" section="$3"
  awk -v level="$level" -v section="$section" '
    /^### /  { in_level = ($0 == "### " level); next }
    in_level && $0 == "#### " section { in_section=1; next }
    in_level && in_section && (/^#### / || /^---/) { in_section=0 }
    in_level && in_section { print }
  ' "$file"
}

# extract_level_description FILE LEVEL
# Prints the Description line for a level block.
extract_level_description() {
  local file="$1" level="$2"
  awk -v level="$level" '
    /^### / { in_level = ($0 == "### " level); in_desc = 0; next }
    in_level && /^#### / { if (/^#### Description/) { in_desc = 1 } else { in_desc = 0 }; next }
    in_level && in_desc && NF > 0 { print; exit }
  ' "$file"
}
