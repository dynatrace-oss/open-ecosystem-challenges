#!/usr/bin/env bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# shellcheck disable=SC1091
source "$REPO_ROOT/lib/scripts/tracker.sh"
set_tracking_context "lex-imperfecta" "beginner"
track_codespace_created

"$REPO_ROOT/lib/shared/init.sh" --version v0.17.0
"$REPO_ROOT/lib/kubernetes/init.sh" \
  --kind-version v0.31.0 \
  --kubectl-version v1.35.0 \
  --kubens-version v0.11.0 \
  --k9s-version v0.50.18 \
  --helm-version v4.1.4
"$REPO_ROOT/lib/kyverno/init.sh" --version 3.7.1 --cli-version v1.17.1
