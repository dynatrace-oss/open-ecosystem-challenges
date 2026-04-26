#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/beginner"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "00-side-effects-may-vary" "beginner"
track_codespace_created

# Install gum (used by the verify.sh output helpers).
"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0 # https://github.com/charmbracelet/gum/releases

# jq is needed by verify.sh; the Java devcontainer image is debian-based.
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends jq
fi

# Java 21 is provided by the devcontainer image (mcr.microsoft.com/devcontainers/java:1-21-bullseye).
# Pre-fetch Maven dependencies so the IDE is responsive immediately.
echo "✨ Resolving Maven dependencies for the lab..."
cd "$CHALLENGE_DIR"
chmod +x ./mvnw
./mvnw -q -B -DskipTests dependency:go-offline || true

# --- Codespaces-only launch configs ---
# The repo root .gitignore excludes .vscode/, so we materialize the launch
# and task configs at codespace boot. They give participants F5 / "Run Task"
# buttons without us shipping a checked-in .vscode/ directory.
VSCODE_DIR="$CHALLENGE_DIR/.vscode"
mkdir -p "$VSCODE_DIR"

if [[ ! -f "$VSCODE_DIR/launch.json" ]]; then
  cat > "$VSCODE_DIR/launch.json" <<'JSON'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "🧪 Run the Lab",
      "request": "launch",
      "mainClass": "dev.openfeature.demo.java.demo.Laboratory",
      "projectName": "demo",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}"
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
    }
  ]
}
JSON
fi

echo "✅ Post-create complete."
