#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-lex-imperfecta/beginner"

echo "✨ Starting Lex Imperfecta - Beginner Level"

echo "⚖️  Applying policies..."
kubectl apply -f "$CHALLENGE_DIR/manifests/policies/"

echo "🏛️  Deploying pods..."
# Some pods may be blocked by the misconfigured policies — this is intentional.
# Run 'kubectl get pods' to see the current state and start investigating.
kubectl apply -f "$CHALLENGE_DIR/manifests/pods/" 2>&1 || true

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "lex-imperfecta" "beginner"
track_codespace_initialized
