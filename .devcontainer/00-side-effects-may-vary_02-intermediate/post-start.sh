#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/intermediate"

cat <<EOF

✨ Level 2 - 🟡 Intermediate (Dose by cohort)

📂 Challenge directory:
   $CHALLENGE_DIR

🧪 Sibling services already running (managed by devcontainer compose):
   - flagd  → reachable at flagd:8013 (RPC) / flagd:8014 (HTTP eval)
              Also forwarded to localhost on the same ports.

▶  Run the lab — three named launch configs ship in .vscode/launch.json:
     🇩🇪  Run the Lab — Germany (COUNTRY=de)
     🇦🇹  Run the Lab — Austria (COUNTRY=at)
     🌍  Run the Lab — No country
   Open the Run and Debug view (Ctrl/Cmd + Shift + D) and pick one.

   Or from the terminal:
     ./run-germany.sh   # COUNTRY=de + tee app.log
     ./run-austria.sh   # COUNTRY=at + tee app.log

👉 In another terminal, exercise the cohorts:
     curl 'http://localhost:8080/?race=zyklop'   # per-subject targeting
     curl 'http://localhost:8080/'               # falls through to country branch

✅ Run the verification when you're ready:
     ./verify.sh
   or use the 🧪 Verify Solution task: Tasks → Run Test Task.

EOF

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "intermediate"
track_codespace_initialized

# Open the relevant files in the connected editor. customizations.codespaces.openFiles
# is unreliable for dockerComposeFile-based devcontainers (the orchestrator merges
# devcontainer.json and the field is sometimes dropped). `code` is the same CLI the
# editor uses internally and works against either the web or desktop client.
if command -v code >/dev/null 2>&1; then
  code "$REPO_ROOT/adventures/planned/00-side-effects-may-vary/docs/intermediate.md" \
       "$CHALLENGE_DIR/src/main/java/dev/openfeature/demo/java/demo/OpenFeatureConfig.java" \
       "$CHALLENGE_DIR/flags.json" \
       2>/dev/null || true
fi
