#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "02-building-cloudhaven" "beginner"
track_codespace_created

"$REPO_ROOT/lib/shared/init.sh"

"$REPO_ROOT/lib/open-tofu/init.sh"
"$REPO_ROOT/lib/gcp-api-mock/init.sh"
