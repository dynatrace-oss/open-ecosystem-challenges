#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHALLENGE_DIR="$REPO_ROOT/adventures/02-building-cloudhaven/expert"

echo "✨ Starting Expert Level - CloudHaven Infrastructure"

# Build the Codespace forwarded URL for the GCS mock API
GCS_MOCK_URL="https://${CODESPACE_NAME}-30104.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"

# Replace placeholders in workflow files with the actual Codespace URL
echo "📝 Configuring workflow files..."
sed -i "s|__GCP_MOCK_ENDPOINT__|${GCS_MOCK_URL}|g" \
  "$REPO_ROOT/.github/workflows/adventure02-expert-detect-drift.yaml" \
  "$REPO_ROOT/.github/workflows/adventure02-expert-validate-changes.yaml" \
  "$REPO_ROOT/.github/workflows/adventure02-expert-apply-infrastructure.yaml"

# Replace GCP mock endpoint placeholders in Terraform files
echo "📝 Configuring Terraform files..."
sed -i "s|__GCP_MOCK_ENDPOINT__|${GCS_MOCK_URL}|g" \
  "$CHALLENGE_DIR/main.tf"

# Commit and push the configuration changes so they're available on GitHub
echo "🚀 Pushing configuration..."
git add .github/workflows/adventure02-expert-*.yaml
git add "$CHALLENGE_DIR/*.tf"
git commit -m "chore: configure workflows and Terraform for Codespace" --allow-empty
git push

# Expose GCP mock publicly
gh codespace ports visibility 30104:public -c $CODESPACE_NAME

# Create state bucket
curl -X POST 'http://localhost:30104/storage/v1/b?project=the-guardian-protocols' \
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
echo "📦 Initializing infrastructure..."
tofu init
tofu apply -auto-approve

# Simulate infrastructure drift by deleting a storage bucket outside of OpenTofu
# This allows testing of drift detection workflows
echo "🔧 Simulating drift: Deleting north-market vault bucket..."
curl -X DELETE 'http://localhost:30104/storage/v1/b/cloudhaven-north-market-vault'

# Initialize the district module so users can run tests immediately
cd "$CHALLENGE_DIR/modules/district"
echo "📦 Initializing district module for testing..."
tofu init

cd "$CHALLENGE_DIR"

# Track that the environment is ready
# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "02-building-cloudhaven" "expert"
track_codespace_initialized