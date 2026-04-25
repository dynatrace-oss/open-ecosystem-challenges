#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/expert"

echo "✨ Starting Phase 3 — read the chart"
echo ""
echo "🧪 Sibling services already running (managed by devcontainer compose):"
echo "   - flagd   → flagd:8013 (RPC) / flagd:8014 (HTTP eval)"
echo "   - lgtm    → lgtm:4317 (OTLP) / Grafana on :3000 (admin / admin)"
echo "   - loadgen → idles until loadgen_active flag flips to \"on\""
echo ""
echo "   All ports are forwarded to localhost on the host, so curl and"
echo "   verify.sh can keep using localhost:NNNN."

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "expert"
track_codespace_initialized

cat <<EOF

🧪 Phase 3 environment is up.

Next steps:
  cd $CHALLENGE_DIR
  ./mvnw spring-boot:run

Then open http://localhost:3000 (admin/admin) for Grafana, or follow the docs:
  adventures/planned/00-side-effects-may-vary/docs/expert.md

EOF
