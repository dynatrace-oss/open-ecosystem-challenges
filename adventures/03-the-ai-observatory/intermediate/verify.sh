#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should:

- Instrument the full RAG pipeline with OpenLLMetry to visualize the retrieval process in Jaeger
- Implement a custom OpenTelemetry metric to track how often ART retrieves 'entertainment' vs 'navigation' data
- Create a Prometheus recording rule to calculate ART's 'Distraction Level'
- Restore the navigation system so ART successfully calculates the jump coordinates to RaviHyral"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/03-the-ai-observatory/intermediate"

print_header \
  'Challenge 03: The AI Observatory' \
  'Level 2: The Distracted Pilot' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites python3 curl jq

print_sub_header "Running verification checks..."

# 1) Static Code Check (Instrumentation)
print_sub_header "1. Checking Code Instrumentation..."

# Check Traceloop
check_file_contains "art.py" "Traceloop.init" "OpenLLMetry instrumentation" \
  "Did you uncomment Traceloop.init() in art.py?"
print_new_line

# Check Metrics
check_file_contains "art.py" "meter.create_counter" "Custom metric counter" \
  "Did you create the 'art.rag.retrieval.count' metric in art.py?"
print_new_line

# Check Filter
check_file_contains "art.py" "similarity_search.*filter=" "Qdrant filter argument" \
  "Did you pass a 'filter' argument to similarity_search in art.py?"
print_new_line

check_file_contains "art.py" "models.Filter" "Qdrant filter object" \
  "Did you create a 'models.Filter' object to filter for navigation data?"
print_new_line

# 2) Runtime Verification (Jaeger Traces)
print_sub_header "2. Checking Jaeger Traces..."
check_jaeger_traces "art" "ART traces are present" \
  "No traces found. Did you run the app and chat with it? (make art)"

check_jaeger_span_attribute "art" "rag.context_assembly" "context.categories" \
  "RAG Context Assembly Span" \
  "Could not find span 'rag.context_assembly' with attribute 'context.categories'. Did you instrument the RAG pipeline correctly?"
print_new_line

# 3) Runtime Verification (Prometheus Metrics)
print_sub_header "3. Checking Prometheus Metrics..."

check_prometheus_metrics "ART Metrics" "prometheus" "prometheus-server" "80" \
  "art_rag_retrieval_count_total:Custom metric 'art_rag_retrieval_count_total' missing. Did you add a custom metric in art.py?"

check_prometheus_rule "art:distraction_ratio" "prometheus" "prometheus-server" "80" \
  "Recording rule 'art:distraction_ratio' missing. Did you create it in manifests/prometheus-rule.yaml?"

print_new_line

# =============================================================================
# Summary & Next Steps
# =============================================================================

# Build failed checks JSON array
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  # Track failure
  track_verification_completed "failed" "$failed_checks_json"

  print_verification_summary "the ai observatory" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

# Track success
track_verification_completed "success" "$failed_checks_json"

# Success!
print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

# Run submission readiness checks
check_submission_readiness "03-the-ai-observatory" "intermediate"
