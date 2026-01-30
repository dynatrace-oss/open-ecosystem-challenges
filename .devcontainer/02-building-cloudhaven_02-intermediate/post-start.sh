#!/usr/bin/env bash
set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/02-building-cloudhaven/intermediate"
echo "✨ Starting level 2 - Intermediate (The Modular Metropolis)"
# Create state bucket
curl -X POST 'http://localhost:30104/storage/v1/b?project=the-modular-metropolis' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "cloudhaven-tfstate",
    "location": "EU",
    "storageClass": "STANDARD",
    "versioning": {
      "enabled": true
    }
  }'
# Initialize OpenTofu in the challenge directory
# Actually set in gcp-api-mock/init.sh, but that isn't applied in this context
export STORAGE_EMULATOR_HOST="http://localhost:30104"
cd "$CHALLENGE_DIR"
echo "📦 Initializing root module..."
tofu init
# Initialize the district module so users can run tests immediately
cd "$CHALLENGE_DIR/modules/district"
echo "📦 Initializing district module for testing..."
tofu init
cd "$CHALLENGE_DIR"
# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "02-building-cloudhaven" "intermediate"
track_codespace_initialized