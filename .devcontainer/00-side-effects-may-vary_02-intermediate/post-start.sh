#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/intermediate"

echo "✨ Starting level 2 - 🟡 Intermediate (Dose by cohort)"
echo ""
echo "📂 Challenge directory: $CHALLENGE_DIR"
echo ""
echo "🧪 Sibling services already running (managed by devcontainer compose):"
echo "    - flagd  → reachable at flagd:8013 (RPC) / flagd:8014 (HTTP eval)"
echo "             Forwarded to localhost on the same ports."
echo ""
echo "👉 To start the lab and capture audit logs for verify.sh:"
echo ""
echo "    cd $CHALLENGE_DIR"
echo "    ./mvnw spring-boot:run | tee app.log"
echo ""
echo "👉 In another terminal, exercise the cohorts:"
echo ""
echo "    curl 'http://localhost:8080/?language=de'"
echo "    curl 'http://localhost:8080/'"
echo ""
echo "👉 Run the verification when you're ready:"
echo ""
echo "    $CHALLENGE_DIR/verify.sh"
echo ""

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "intermediate"
track_codespace_initialized
