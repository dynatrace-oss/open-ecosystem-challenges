#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IDEAS_DIR="$REPO_ROOT/ideas"

# shellcheck source=../lib/scripts/idea-parser.sh
source "$REPO_ROOT/lib/scripts/idea-parser.sh"

# ─── Select adventure ────────────────────────────────────────────────────────

selected_slug=$(find "$IDEAS_DIR" -maxdepth 1 -name "*.md" ! -name "adventure-idea-template.md" -exec basename {} .md \; | sort \
  | gum choose --header "Which adventure do you want to scaffold?")
selected_file="$IDEAS_DIR/$selected_slug.md"
parse_adventure_header "$selected_file"

# ─── Select level ────────────────────────────────────────────────────────────

level_lines=$(grep '^### ' "$selected_file" | sed 's/^### //')
selected_level=$(echo "$level_lines" | gum choose --header "Which level do you want to scaffold?")

# ─── Parse level metadata ─────────────────────────────────────────────────────

parse_level_heading "$selected_level"

# position of selected level among ### headings (1st = 01, 2nd = 02, ...)
level_number=$(echo "$level_lines" \
  | awk -v target="$selected_level" '{n++; if ($0 == target) {printf "%02d", n; exit}}')

echo ""
echo "Adventure : $adventure_emoji $adventure_name ($selected_slug)"
echo "Level     : $level_emoji  $level_difficulty: $level_name"
echo "Slug      : $level_slug (level $level_number)"
echo ""

# ─── Scaffold adventure base ──────────────────────────────────────────────────

ADVENTURE_DIR="$REPO_ROOT/adventures/planned/00-$selected_slug"
adventure_technologies=$(extract_overview_field "$selected_file" "Technologies")
adventure_theme=$(extract_overview_field "$selected_file" "Theme")

if [[ ! -d "$ADVENTURE_DIR" ]]; then
  echo "Creating adventure base at adventures/planned/00-$selected_slug/ ..."
  mkdir -p "$ADVENTURE_DIR/docs"

  cat > "$ADVENTURE_DIR/README.md" << EOF
# $adventure_emoji Adventure 00: $adventure_name

$adventure_theme

**Technologies:** $adventure_technologies

The entire **infrastructure is pre-provisioned in your Codespace**
**You don't need to set up anything locally. Just focus on solving the problem.**

## 🚀 Ready to Start?

[Choose your level](https://dynatrace-oss.github.io/open-ecosystem-challenges/00-$selected_slug/) and begin
learning!
EOF

  cat > "$ADVENTURE_DIR/mkdocs.yaml" << EOF
site_name: '$adventure_emoji  00: $adventure_name'

nav:
  - Introduction: index.md
EOF

  cat > "$ADVENTURE_DIR/docs/index.md" << EOF
# $adventure_emoji Adventure 00: $adventure_name

<!-- TODO: brief intro (mission + key technologies + pre-provisioned note) -->

## 🪐 The Backstory

$adventure_theme

<!-- TODO: expand backstory if desired -->

## 🎮 Choose Your Level

Each level is a standalone challenge with its own Codespace that builds on the story while being technically
independent — pick your level and start wherever you feel comfortable.
EOF

  echo "✅ Adventure base created."
else
  echo "ℹ️  Adventure base already exists, skipping."
fi

# ─── Scaffold level doc ───────────────────────────────────────────────────────

level_summary=$(extract_level_description "$selected_file" "$selected_level")
level_story=$(extract_level_section "$selected_file" "$selected_level" "Story")
level_objective=$(extract_level_section "$selected_file" "$selected_level" "Objective")
level_learnings=$(extract_level_section "$selected_file" "$selected_level" "What You'll Learn")
level_tools=$(extract_level_section "$selected_file" "$selected_level" "Tools & Infrastructure")

LEVEL_DOC="$ADVENTURE_DIR/docs/$level_slug.md"

if [[ ! -f "$LEVEL_DOC" ]]; then
  echo "Creating level doc at docs/$level_slug.md ..."
  TICK='```'

  cat > "$LEVEL_DOC" << EOF
# $level_emoji $level_difficulty: $level_name
$level_story

<!-- TODO: expand story if desired -->

🏗️ Architecture

<!-- TODO: describe how the level is set up -->

## 🎯 Objective
$level_objective

## 🧠 What You'll Learn
$level_learnings

## 🧰 Toolbox

Your Codespace comes pre-configured with the following tools:
$level_tools

<!-- TODO: add links and usage notes -->

## ⏰ Deadline

<!-- Leave empty for now. This will be added once the adventure goes live -->

> ℹ️ You can still complete the challenge after this date, but points will only be awarded for submissions before the
> deadline.

## 💬 Join the discussion

<!-- Leave the link as it is for now. This will be added once the adventure is live -->
Share your solutions and questions in
the [challenge thread](TODO)
in the Open Ecosystem Community.

## ✅ How to Play

<!-- TODO: verify what's here add instructions where necessary -->

### 1. Start Your Challenge

> 📖 **First time?** Check out the [Getting Started Guide](../../start-a-challenge) for detailed instructions on
> forking, starting a Codespace, and waiting for infrastructure setup.

Quick start:

- Fork the [repo](https://github.com/dynatrace-oss/open-ecosystem-challenges/)
- Create a Codespace
- Select "$adventure_emoji Adventure 00 | $level_emoji $level_difficulty ($level_name)"
- Wait a couple of minutes for the environment to initialize (\`Cmd/Ctrl + Shift + P\` → \`View Creation Log\` to view progress)

<!-- TODO: Feel free to be more specific about how long the setup usually takes in the last step above -->

### 2. Access the UIs

- Open the **Ports** tab in the bottom panel to access the following UIs

#### Some UI you might use

<!-- TODO: Add a description about what this tool is used for -->

<!-- TODO: Add tool name & port number -->
- Find the tool row (port NN) and click the forwarded address

### 3. Implement the Objective

<!-- TODO: A very short description to remind the user about the task again -->

Review the [🎯 Objective](#objective) section to understand what a successful solution looks like.

#### Where to Look

<!-- TODO: Describe where to start investigating -->

#### How to Run

<!-- TODO: Describe how to run the service/app/whatever and e.g. generate load or whatever is necessary -->

#### Helpful Documentation

<!-- TODO: Add links to documentation that is helpful for solving this challenge -->

### 4. Verify Your Solution

Once you think you've solved the challenge, run the verification script:

${TICK}bash
./verify.sh
${TICK}

**If the verification fails:**

The script will tell you which checks failed. Fix the issues and run it again.

**If the verification passes:**

1. The script will check if your changes are committed and pushed.
2. Follow the on-screen instructions to commit your changes if needed.
3. Once everything is ready, the script will generate a **Certificate of Completion**.
<!-- Leave the link as it is for now. This will be added once the adventure is live -->
4. **Copy this certificate** and paste it into
   the [challenge thread](TODO)
   to claim your victory! 🏆
EOF

  echo "  - '$level_emoji $level_difficulty': $level_slug.md" >> "$ADVENTURE_DIR/mkdocs.yaml"

  cat >> "$ADVENTURE_DIR/docs/index.md" << EOF

### $level_emoji $level_difficulty: $level_name

- **Status:** 🚧 Coming Soon
- **Topics:** $adventure_technologies

$level_summary

[**Start the $level_difficulty Challenge**](./$level_slug.md){ .md-button .md-button--primary }
EOF

  echo "✅ Level doc created, added to mkdocs.yaml, and level card added to index.md."
else
  echo "ℹ️  Level doc already exists, skipping."
fi

# ─── Scaffold verify.sh ───────────────────────────────────────────────────────

VERIFY_SCRIPT="$ADVENTURE_DIR/$level_slug/verify.sh"

if [[ ! -f "$VERIFY_SCRIPT" ]]; then
  echo "Creating verification script at $level_slug/verify.sh ..."
  mkdir -p "$ADVENTURE_DIR/$level_slug"

  cat > "$VERIFY_SCRIPT" << EOF
#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "\$SCRIPT_DIR/../../../../lib/scripts/loader.sh"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/00-$selected_slug/$level_slug"

print_header \\
  'Challenge 00: $adventure_name' \\
  'Level $level_number: $level_name' \\
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites # TODO: list required tools (e.g. kubectl curl jq)

print_sub_header "Running verification checks..."

# TODO: add verification checks
# Examples:
#   check_jaeger_traces "service-name" "Traces present" "No traces found."
#   is_app_reachable "http://localhost:30100" "App is reachable" "App not reachable"
#   check_file_contains "file.py" "expected_string" "Check label" "Hint if it fails"

# =============================================================================
# Summary
# =============================================================================

failed_checks_json="[]"
if [[ -n "\${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=\$(printf '%s\n' "\${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ \$TESTS_FAILED -gt 0 ]]; then
  track_verification_completed "failed" "\$failed_checks_json"
  print_verification_summary "$selected_slug" "\$DOCS_URL"
  exit 1
fi

track_verification_completed "success" "\$failed_checks_json"

print_header "Test Results Summary"
print_success "✅ PASSED: All \$TESTS_PASSED verification checks passed!"
print_new_line

check_submission_readiness "00-$selected_slug" "$level_slug"
EOF

  chmod +x "$VERIFY_SCRIPT"
  echo "✅ Verification script created."
else
  echo "ℹ️  Verification script already exists, skipping."
fi

# ─── Scaffold devcontainer ────────────────────────────────────────────────────

DEVCONTAINER_NAME="00-${selected_slug}_${level_number}-${level_slug}"
DEVCONTAINER_DIR="$REPO_ROOT/.devcontainer/$DEVCONTAINER_NAME"

if [[ ! -d "$DEVCONTAINER_DIR" ]]; then
  echo "Creating devcontainer at .devcontainer/$DEVCONTAINER_NAME/ ..."
  mkdir -p "$DEVCONTAINER_DIR"

  cat > "$DEVCONTAINER_DIR/devcontainer.json" << EOF
{
  "name": "$adventure_emoji Adventure 00 | $level_emoji $level_difficulty ($level_name)",
  "image": "mcr.microsoft.com/devcontainers/base:bullseye",
  "workspaceFolder": "/workspaces/\${localWorkspaceFolderBasename}/adventures/planned/00-$selected_slug/$level_slug",
  "features": {
    // TODO: add required features (e.g. "ghcr.io/devcontainers/features/docker-in-docker:2": {})
  },
  "postCreateCommand": "bash /workspaces/\${localWorkspaceFolderBasename}/.devcontainer/$DEVCONTAINER_NAME/post-create.sh",
  "postStartCommand": "bash /workspaces/\${localWorkspaceFolderBasename}/.devcontainer/$DEVCONTAINER_NAME/post-start.sh",
  "customizations": {
    "codespaces": {
      "openFiles": [
        "adventures/planned/00-$selected_slug/README.md"
      ],
      "permissions": {
        "codespaces": "write"
      }
    }
  },
  "forwardPorts": [],
  "portsAttributes": {
    // TODO: add port labels (e.g. "30100": { "label": "ArgoCD", "onAutoForward": "notify" })
  },
  "otherPortsAttributes": {
    "onAutoForward": "ignore"
  }
}
EOF

  cat > "$DEVCONTAINER_DIR/post-create.sh" << EOF
#!/usr/bin/env bash
set -e

REPO_ROOT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "\$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "$selected_slug" "$level_slug"
track_codespace_created

"\$REPO_ROOT/lib/shared/init.sh"

# TODO: install & configure the tools you need by using the setup scripts located in `/lib` (e.g. "\$REPO_ROOT/lib/kubernetes/init.sh")
EOF

  cat > "$DEVCONTAINER_DIR/post-start.sh" << EOF
#!/usr/bin/env bash
set -e

REPO_ROOT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="\$REPO_ROOT/adventures/planned/00-$selected_slug/$level_slug"

echo "✨ Starting $adventure_name - $level_difficulty Level"

# TODO: start services & apply initial state

# shellcheck disable=SC1091
source "\$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "$selected_slug" "$level_slug"
track_codespace_initialized
EOF

  chmod +x "$DEVCONTAINER_DIR/post-create.sh" "$DEVCONTAINER_DIR/post-start.sh"
  echo "✅ Devcontainer created."
else
  echo "ℹ️  Devcontainer already exists, skipping."
fi

# ─── Done ─────────────────────────────────────────────────────────────────────

gum style \
  --border rounded --border-foreground 212 \
  --padding "1 2" --margin "1 0" \
  "$(gum style --foreground 212 --bold "🎉  $adventure_emoji  $adventure_name | $level_emoji  $level_difficulty is ready!")" \
  "" \
  "Search for TODO in the generated files and fill them in:" \
  "  adventures/planned/00-$selected_slug/" \
  "  .devcontainer/$DEVCONTAINER_NAME/" \
  "" \
  "$(gum style --foreground 245 "Need help? Check the contributing guide:")" \
  "$(gum style --foreground 245 "https://dynatrace-oss.github.io/open-ecosystem-challenges/contributing/adventures/")"

