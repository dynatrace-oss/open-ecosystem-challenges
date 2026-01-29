#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, your workflows should:

- Detect infrastructure drift (run tofu plan, create PR when drift found)
- Validate pull requests (run plan, tests, security scans, comment on PR)
- Apply infrastructure automatically when PR is merged"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/02-building-cloudhaven/expert"

print_header \
  'Challenge 02: Building CloudHaven' \
  '🔴 Expert: The Guardian Protocols' \
  'Smoke Test Verification'

check_prerequisites curl jq gh

print_sub_header "Running smoke tests..."

# Track test results across all checks
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

# =============================================================================
# Check 1: Drift Detection Workflow
# Workflow: adventure02-expert-detect-drift.yaml
# =============================================================================

print_sub_header "Workflow: Detect Infrastructure Drift"

DRIFT_WORKFLOW="adventure02-expert-detect-drift.yaml"
WORKFLOW_DIR="$SCRIPT_DIR/../../../.github/workflows"

# 1.1: Check if workflow ran & succeeded
check_workflow_succeeded "$DRIFT_WORKFLOW" "Drift detection" \
  "Run the 'Detect Infrastructure Drift' workflow from GitHub Actions (Actions tab → select workflow → Run workflow). Check workflow run logs if it fails."
print_new_line

# 1.2: Check if PR was created with drift label
check_pr_exists_with_label "drift" "Drift" \
  "The drift detection workflow should create a PR when drift is detected. Check if the plan step is correctly detecting changes."
print_new_line

# 1.3: Check if plan step actually runs tofu plan (not hardcoded)
check_workflow_step_contains "$WORKFLOW_DIR/$DRIFT_WORKFLOW" "Run OpenTofu Plan" "tofu plan" "Plan step runs 'tofu plan'" \
  "The '📝 Run OpenTofu Plan' step should actually run tofu plan to detect drift"
print_new_line

# =============================================================================
# Check 2: Validate Changes Workflow
# Workflow: adventure02-expert-validate-changes.yaml
# =============================================================================

print_sub_header "Workflow: Validate Infrastructure Changes"

VALIDATE_WORKFLOW="adventure02-expert-validate-changes.yaml"

# 2.1: Check if validate workflow ran & succeeded
check_workflow_succeeded "$VALIDATE_WORKFLOW" "Validate changes" \
  "Mark the drift PR as 'Ready for Review' to trigger the validation workflow. Check workflow run logs if it fails."
print_new_line

# 2.2: Check if PR has plan comment (from TF-via-PR)
check_pr_has_comment "$PR_NUMBER" "OpenTofu" "plan comment" \
  "The validation workflow should comment the plan results on the PR"
print_new_line

# 2.3: Check if PR has security scan comment
check_pr_has_comment "$PR_NUMBER" "Security Scan" "security scan comment" \
  "Fix the Trivy scan configuration to output results and comment on the PR"
print_new_line

# 2.4: Check if Trivy is properly configured (outputs to json file)
check_workflow_step_contains "$WORKFLOW_DIR/$VALIDATE_WORKFLOW" "Scan for Vulnerabilities" "output:" "Trivy step has output configured" \
  "Configure the Trivy action to output scan results to a file"
print_new_line

# 2.5: Check if fail step actually exits (not just echo)
check_file_contains "$WORKFLOW_DIR/$VALIDATE_WORKFLOW" "exit 1" "Fail step can block PRs" \
  "The '🚫 Fail on Blocking Vulnerabilities' step should exit 1 when critical or high vulnerabilities are found"
print_new_line

# 2.6: Check if service container has ports configured
check_file_contains "$WORKFLOW_DIR/$VALIDATE_WORKFLOW" "ports:" "Service container has ports configured" \
  "The GCP mock service container needs port mapping to be accessible from test steps"
print_new_line

# =============================================================================
# Check 3: Apply Infrastructure Workflow
# Workflow: adventure02-expert-apply-infrastructure.yaml
# =============================================================================

print_sub_header "Workflow: Apply Infrastructure"

APPLY_WORKFLOW="adventure02-expert-apply-infrastructure.yaml"

# 3.1: Check if apply workflow ran & succeeded
check_workflow_succeeded "$APPLY_WORKFLOW" "Apply infrastructure" \
  "Merge the drift PR to trigger the apply workflow. Check workflow run logs if it fails."
print_new_line

# 3.2: Check if infrastructure was actually applied (resource exists in mock)
check_gcp_bucket_exists "cloudhaven-north-market-vault" "North Market vault" \
  "The apply workflow should create resources in the GCP mock. Check if the workflow completed successfully."
print_new_line

# =============================================================================
# Print summary
# =============================================================================

print_test_summary "the guardian protocols" "$DOCS_URL" "$OBJECTIVE"
