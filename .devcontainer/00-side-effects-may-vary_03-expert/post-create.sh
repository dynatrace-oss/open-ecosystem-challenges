#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "side-effects-may-vary" "expert"
track_codespace_created

# gum is used by the verify.sh / output.sh helpers
"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0 # https://github.com/charmbracelet/gum/releases

CHALLENGE_DIR="$REPO_ROOT/adventures/planned/00-side-effects-may-vary/expert"

# Make the Maven wrapper executable so the participant can just `./mvnw ...`
if [[ -f "$CHALLENGE_DIR/mvnw" ]]; then
  chmod +x "$CHALLENGE_DIR/mvnw"
fi

echo "✨ Pre-warming the Maven dependency cache so the first ./mvnw is fast..."
( cd "$CHALLENGE_DIR" && ./mvnw -q -DskipTests dependency:go-offline ) || \
  echo "⚠️  Dependency pre-warm skipped (network or wrapper not ready yet)"

echo "✅ Phase 3 toolchain ready (gum + Java 21). flagd / lgtm / loadgen run as sibling devcontainer services."
