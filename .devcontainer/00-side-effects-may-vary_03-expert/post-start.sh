#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/expert"

echo "✨ Starting Phase 3 — read the chart"

# 1. flagd container with the broken-state flags.json mounted in
echo "🚩 Bringing up flagd..."
docker compose -f "$CHALLENGE_DIR/docker-compose.yaml" \
  --project-directory "$CHALLENGE_DIR" \
  up -d

# 2. Grafana LGTM stack + k6 loadgen (loadgen idles until the
#    loadgen_active flag is flipped to "on")
echo "📊 Bringing up Grafana LGTM + k6 loadgen..."
docker compose -f "$CHALLENGE_DIR/docker-compose.observability.yaml" \
  --project-directory "$CHALLENGE_DIR" \
  up -d

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "expert"
track_codespace_initialized

cat <<'EOF'

🧪 Phase 3 environment is up.

Next steps:
  cd adventures/planned/00-side-effects-may-vary/expert
  ./mvnw spring-boot:run

Then open http://localhost:3000 (admin/admin) for Grafana,
or follow the docs:
  adventures/planned/00-side-effects-may-vary/docs/expert.md

EOF
