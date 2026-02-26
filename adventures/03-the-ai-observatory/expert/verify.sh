#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should:

- Fix ART's chat span to follow OpenTelemetry GenAI semantic conventions — including token usage
- Configure tail sampling in the OpenTelemetry Collector to only keep traces that contain errors or take longer than 5 seconds"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/03-the-ai-observatory/expert"

print_header \
  'Challenge 03: The AI Observatory' \
  'Level 3: The Noise Filter' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites python3 curl jq

print_sub_header "Running verification checks..."

# =============================================================================
# Task 1: OTel GenAI Semantic Conventions
# =============================================================================
print_sub_header "1. Checking GenAI Semantic Conventions..."

check_jaeger_span_attribute "art" "chat qwen2.5:0.5b" "gen_ai.provider.name" \
  "chat span — gen_ai.provider.name" \
  "Could not find the expected attribute on the chat span in Jaeger. Did you restart art.py after making changes?"
print_new_line

check_jaeger_span_attribute "art" "chat qwen2.5:0.5b" "gen_ai.request.model" \
  "chat span — gen_ai.request.model" \
  "Could not find the expected attribute on the chat span in Jaeger. Did you restart art.py after making changes?"
print_new_line

check_jaeger_span_attribute "art" "chat qwen2.5:0.5b" "gen_ai.usage.input_tokens" \
  "chat span — gen_ai.usage.input_tokens" \
  "Could not find token usage on the chat span. Check the Ollama response object for token counts."
print_new_line

check_jaeger_span_attribute "art" "chat qwen2.5:0.5b" "gen_ai.usage.output_tokens" \
  "chat span — gen_ai.usage.output_tokens" \
  "Could not find token usage on the chat span. Check the Ollama response object for token counts."
print_new_line

# =============================================================================
# Task 2: Tail Sampling
# =============================================================================
print_sub_header "2. Checking Tail Sampling Configuration..."

check_file_contains_count "manifests/otel-collector-config.yaml" "tail_sampling" "2" "tail_sampling referenced in pipeline" \
  "Did you add a 'tail_sampling' processor and reference it in the pipeline? See: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor"
print_new_line

check_file_contains "manifests/otel-collector-config.yaml" "ERROR" "error sampling policy with status_codes: [ERROR]" \
  "Did you add a policy to keep traces with errors? See: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor"
print_new_line

check_file_contains "manifests/otel-collector-config.yaml" "threshold_ms: 5000" "latency sampling policy with threshold_ms: 5000" \
  "Did you add a latency policy with a threshold of 5000ms? See: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor"
print_new_line

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
check_submission_readiness "03-the-ai-observatory" "expert"
