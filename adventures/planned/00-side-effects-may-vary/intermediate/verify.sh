#!/usr/bin/env bash
set -euo pipefail

# Load shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../../../../lib/scripts/loader.sh"

OBJECTIVE="By the end of this level, you should have:

- A LanguageInterceptor that captures ?language= into the OpenFeature transaction context
- A global evaluation context carrying springVersion
- A CustomHook that logs every flag evaluation
- curl /?language=de returns the German variant ('Hallo Welt!')
- curl / never returns the literal fallback 'No World'
- The application log contains audit lines emitted by CustomHook"

DOCS_URL="https://dynatrace-oss.github.io/open-ecosystem-challenges/00-side-effects-may-vary/intermediate"

print_header \
  'Challenge 00: Side Effects May Vary' \
  '🟡 Intermediate: Dose by cohort' \
  'Verification'

# Init test counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_CHECKS=()

check_prerequisites curl jq

# -----------------------------------------------------------------------------
# Locate the application log. The participant is instructed (in intermediate.md)
# to start the app with `./mvnw spring-boot:run | tee app.log` so the log lives
# next to this script. Fall back to a couple of other reasonable spots.
# -----------------------------------------------------------------------------
APP_LOG=""
for candidate in \
  "$SCRIPT_DIR/app.log" \
  "$SCRIPT_DIR/../app.log" \
  "$PWD/app.log"; do
  if [[ -f "$candidate" ]]; then
    APP_LOG="$candidate"
    break
  fi
done

print_sub_header "Running verification checks..."

# -----------------------------------------------------------------------------
# 1. App reachable on :8080
# -----------------------------------------------------------------------------
print_test_section "Checking the lab is reachable on :8080..."
if curl -s --max-time 5 "http://localhost:8080/" >/dev/null 2>&1; then
  print_success_indent "App is reachable at http://localhost:8080/"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "App not reachable at http://localhost:8080/"
  print_hint "Start the lab with: ./mvnw spring-boot:run | tee app.log"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("app_reachable")
fi
print_new_line

# -----------------------------------------------------------------------------
# 2. German cohort: ?language=de must return "sharp"
# -----------------------------------------------------------------------------
print_test_section "Checking the German cohort gets 'Hallo Welt!'..."
DE_VALUE="$(curl -s --max-time 5 'http://localhost:8080/?language=de' 2>/dev/null \
  | jq -r '.value // empty' 2>/dev/null || echo "")"

if [[ "$DE_VALUE" == "sharp" ]]; then
  print_success_indent "GET /?language=de returned 'Hallo Welt!'"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "GET /?language=de returned: '$DE_VALUE' (expected 'Hallo Welt!')"
  print_hint "Did you wire LanguageInterceptor and register a ThreadLocalTransactionContextPropagator?"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("language_targeting")
fi
print_new_line

# -----------------------------------------------------------------------------
# 3. Default cohort: GET / must NOT return the literal fallback "untreated".
#    Either "enhanced" (sem_ver branch fires on Spring 3.x+) or
#    "blurry" (default variant on older Spring) is acceptable.
# -----------------------------------------------------------------------------
print_test_section "Checking the default cohort doesn't fall back to 'No World'..."
DEFAULT_VALUE="$(curl -s --max-time 5 'http://localhost:8080/' 2>/dev/null \
  | jq -r '.value // empty' 2>/dev/null || echo "")"

if [[ -n "$DEFAULT_VALUE" && "$DEFAULT_VALUE" != "untreated" ]]; then
  print_success_indent "GET / returned a real variant: '$DEFAULT_VALUE'"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "GET / returned: '$DEFAULT_VALUE' (expected anything except 'No World')"
  print_hint "If you see 'No World' the provider isn't resolving — check OpenFeatureConfig."
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("default_resolves")
fi
print_new_line

# -----------------------------------------------------------------------------
# 4. CustomHook audit lines must appear in the application log.
# -----------------------------------------------------------------------------
print_test_section "Checking CustomHook audit lines in application log..."
if [[ -z "$APP_LOG" ]]; then
  print_error_indent "Couldn't find app.log next to verify.sh"
  print_hint "Start the lab with: ./mvnw spring-boot:run | tee app.log"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("app_log_missing")
elif grep -Eq "Before hook|After hook" "$APP_LOG"; then
  print_success_indent "Found CustomHook audit lines in $APP_LOG"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  print_error_indent "No 'Before hook'/'After hook' lines found in $APP_LOG"
  print_hint "Did you implement CustomHook and register it via api.addHooks(...)?"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILED_CHECKS+=("custom_hook_log")
fi
print_new_line

# =============================================================================
# Summary
# =============================================================================
failed_checks_json="[]"
if [[ -n "${FAILED_CHECKS[*]:-}" ]]; then
  failed_checks_json=$(printf '%s\n' "${FAILED_CHECKS[@]}" | jq -R . | jq -s .)
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
  track_verification_completed "failed" "$failed_checks_json"
  print_verification_summary "side effects may vary" "$DOCS_URL" "$OBJECTIVE"
  exit 1
fi

track_verification_completed "success" "$failed_checks_json"

print_header "Test Results Summary"
print_success "✅ PASSED: All $TESTS_PASSED verification checks passed!"
print_new_line

# Run submission readiness checks (best-effort: the function exists in lib)
if command -v check_submission_readiness >/dev/null 2>&1; then
  check_submission_readiness "00-side-effects-may-vary" "intermediate"
fi
