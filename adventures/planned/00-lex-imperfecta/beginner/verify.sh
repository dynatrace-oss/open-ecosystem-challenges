#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should have:

- All workloads missing the 'republic.rome/gens' label blocked at admission with a clear policy violation message
- All workloads running as privileged containers blocked at admission with a clear policy violation message
- Confirmed that all other workloads deploy and run successfully in the cluster"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/00-lex-imperfecta/beginner"

print_header \
  'Challenge 00: Lex Imperfecta' \
  'Level 01: The Twelve Tables' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites kubectl

print_sub_header "Running verification checks..."

# =============================================================================
# Objective 1: Workloads missing republic.rome/gens label are blocked
# =============================================================================
print_new_line
print_sub_header "1. Checking that unlabelled workloads are blocked..."

check_admission_blocked \
  "Pod without republic.rome/gens label" \
  "Check the 'require-labels' policy — what happens when a violation is detected?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-no-label
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Pod with republic.rome/gens label" \
  "Check the 'require-labels' policy — is the label pattern correct?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-with-label
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF



# =============================================================================
# Objective 2: Workloads running as privileged containers are blocked
# =============================================================================
print_new_line
print_sub_header "2. Checking that privileged workloads are blocked..."

check_admission_blocked \
  "Pod with privileged container" \
  "Check the 'no-privileged-containers' policy — does the deny condition cover regular containers?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged
  labels:
    republic.rome/gens: castra-praetoria
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: true
EOF

check_admission_blocked \
  "Pod with privileged init container" \
  "Check the 'no-privileged-containers' policy — does the deny condition cover init containers?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-privileged-init
  labels:
    republic.rome/gens: castra-praetoria
spec:
  initContainers:
    - name: init
      image: busybox:stable
      command: ["sh", "-c", "exit 0"]
      securityContext:
        privileged: true
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

check_admission_allowed \
  "Pod with non-privileged container" \
  "Check the 'no-privileged-containers' policy — is the deny condition correct?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-non-privileged
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF



# =============================================================================
# Objective 3: Compliant workloads deploy and run successfully
# =============================================================================
print_new_line
print_sub_header "3. Checking that compliant workloads are admitted..."

check_admission_allowed \
  "Fully compliant pod (label + non-privileged)" \
  "Check both policies — does the pod carry the required label and run without elevated privileges?" <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: verify-compliant
  labels:
    republic.rome/gens: forum-romanum
spec:
  containers:
    - name: app
      image: busybox:stable
      command: ["sleep", "1"]
      securityContext:
        privileged: false
EOF

# =============================================================================
# Summary & Next Steps
# =============================================================================
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  # Track failure
  track_verification_completed "failed" "$failed_checks_json"

  print_verification_summary "lex-imperfecta" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

# Track success
track_verification_completed "success" "$failed_checks_json"

# Success!
print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

# Run submission readiness checks
check_submission_readiness "00-lex-imperfecta" "beginner"
