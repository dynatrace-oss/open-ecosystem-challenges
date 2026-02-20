#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "03-the-ai-observatory" "intermediate"
track_codespace_created

"$REPO_ROOT/lib/shared/init.sh"
"$REPO_ROOT/lib/kubernetes/init.sh"
"$REPO_ROOT/lib/jaeger/init.sh"
"$REPO_ROOT/lib/otel-collector/init.sh"
"$REPO_ROOT/lib/prometheus/init.sh" --operator
"$REPO_ROOT/lib/ollama/init.sh"
"$REPO_ROOT/lib/qdrant/init.sh"

