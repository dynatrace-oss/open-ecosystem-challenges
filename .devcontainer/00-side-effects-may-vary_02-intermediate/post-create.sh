#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "intermediate"
track_codespace_created

"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0 # https://github.com/charmbracelet/gum/releases

CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/intermediate"

# Make the Maven wrapper executable so the participant can just `./mvnw ...`
if [[ -f "$CHALLENGE_DIR/mvnw" ]]; then
  chmod +x "$CHALLENGE_DIR/mvnw"
fi

echo "✨ Pre-warming the Maven dependency cache so the first ./mvnw is fast..."
( cd "$CHALLENGE_DIR" && ./mvnw -q -DskipTests dependency:go-offline ) || \
  echo "⚠️  Dependency pre-warm skipped (network or wrapper not ready yet)"

# --- Codespaces-only launch configs ---
# The repo root .gitignore excludes .vscode/, so we materialize the launch
# and task configs at codespace boot. Three Run-the-Lab configs let the
# participant try the country-targeting branch from Germany, Austria, or
# without a country at all — without leaving the IDE.
VSCODE_DIR="$CHALLENGE_DIR/.vscode"
mkdir -p "$VSCODE_DIR"

if [[ ! -f "$VSCODE_DIR/launch.json" ]]; then
  cat > "$VSCODE_DIR/launch.json" <<'JSON'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "🇩🇪 Run the Lab — Germany (COUNTRY=de)",
      "request": "launch",
      "mainClass": "dev.openfeature.demo.java.demo.Laboratory",
      "projectName": "demo",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}",
      "env": { "COUNTRY": "de" }
    },
    {
      "type": "java",
      "name": "🇦🇹 Run the Lab — Austria (COUNTRY=at)",
      "request": "launch",
      "mainClass": "dev.openfeature.demo.java.demo.Laboratory",
      "projectName": "demo",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}",
      "env": { "COUNTRY": "at" }
    },
    {
      "type": "java",
      "name": "🌍 Run the Lab — No country",
      "request": "launch",
      "mainClass": "dev.openfeature.demo.java.demo.Laboratory",
      "projectName": "demo",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}",
      "env": { "COUNTRY": "" }
    }
  ]
}
JSON
fi

if [[ ! -f "$VSCODE_DIR/tasks.json" ]]; then
  cat > "$VSCODE_DIR/tasks.json" <<'JSON'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "🧪 Verify Solution",
      "type": "shell",
      "command": "./verify.sh",
      "options": { "cwd": "${workspaceFolder}" },
      "problemMatcher": [],
      "presentation": { "reveal": "always", "panel": "dedicated" },
      "group": { "kind": "test", "isDefault": true }
    },
    {
      "label": "🇩🇪 Run the Lab — Germany",
      "type": "shell",
      "command": "./run-germany.sh",
      "options": { "cwd": "${workspaceFolder}" },
      "isBackground": true,
      "problemMatcher": [],
      "presentation": { "reveal": "always", "panel": "dedicated" }
    },
    {
      "label": "🇦🇹 Run the Lab — Austria",
      "type": "shell",
      "command": "./run-austria.sh",
      "options": { "cwd": "${workspaceFolder}" },
      "isBackground": true,
      "problemMatcher": [],
      "presentation": { "reveal": "always", "panel": "dedicated" }
    }
  ]
}
JSON
fi

echo "✅ Post-create complete."
