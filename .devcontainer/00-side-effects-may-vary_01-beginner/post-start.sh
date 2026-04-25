#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/beginner"

echo "✨ Starting Adventure 00 — Level 1 (Beginner): Stand up the dispenser"
echo ""
echo "The Spring Boot dispenser lives in:"
echo "  $CHALLENGE_DIR"
echo ""
echo "Start it with:"
echo "  cd $CHALLENGE_DIR && ./mvnw spring-boot:run"
echo ""
echo "Then in another terminal, hit it:"
echo "  curl -s http://localhost:8080/ | jq"
echo ""
echo "When you think you have it solved, run:"
echo "  $CHALLENGE_DIR/verify.sh"
echo ""

# Track that the environment is ready.
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
track_codespace_initialized
