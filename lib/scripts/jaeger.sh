#!/usr/bin/env bash

# jaeger.sh - Shared library for Jaeger trace checks
# This library provides functions to check for traces in Jaeger

JAEGER_API_URL="${JAEGER_API_URL:-http://localhost:30103/api}"

# -----------------------------------------------------------------------------
# Check if traces exist for a specific service
# Usage: check_jaeger_traces "service-name" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_jaeger_traces() {
  local service_name=$1
  local display_name=$2
  local hint=$3

  print_test_section "Checking traces for $display_name..."

  # Query Jaeger API for traces
  local response
  response=$(curl -s "${JAEGER_API_URL}/traces?service=${service_name}&limit=1" 2>/dev/null || echo "")

  # Check if we got a valid JSON response with data
  if [[ -z "$response" ]]; then
    print_error_indent "Could not connect to Jaeger API at $JAEGER_API_URL"
    print_hint "Ensure Jaeger is running and port 30103 is accessible"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_jaeger_traces:connection_failed")
  else
    # Check if data array is not empty using jq
    local trace_count
    trace_count=$(echo "$response" | jq '.data | length' 2>/dev/null || echo "0")

    if [[ "$trace_count" -gt 0 ]]; then
      print_success_indent "Found traces for $service_name"
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      print_error_indent "No traces found for $service_name"
      print_hint "$hint"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      FAILED_CHECKS+=("check_jaeger_traces:$service_name")
    fi
  fi
}

# -----------------------------------------------------------------------------
# Check if a specific span exists with a specific attribute
# Usage: check_jaeger_span_attribute "service-name" "span-name" "attribute-key" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_jaeger_span_attribute() {
  local service_name=$1
  local span_name=$2
  local attribute_key=$3
  local display_name=$4
  local hint=$5

  print_test_section "Checking span attribute for $display_name..."

  # Query Jaeger API for traces
  local response
  response=$(curl -s "${JAEGER_API_URL}/traces?service=${service_name}&limit=5" 2>/dev/null || echo "")

  if [[ -z "$response" ]]; then
    print_error_indent "Could not connect to Jaeger API"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_jaeger_span_attribute:connection_failed")
    return
  fi

  # Check if the span exists and has the attribute
  # We look through all traces, all spans, find the one with operationName == span_name
  # and check if it has a tag with key == attribute_key
  local has_attribute
  has_attribute=$(echo "$response" | jq -r --arg span "$span_name" --arg attr "$attribute_key" '
    .data[].spans[]
    | select(.operationName == $span)
    | .tags[]
    | select(.key == $attr)
    | .key
  ' | head -n 1)

  if [[ "$has_attribute" == "$attribute_key" ]]; then
    print_success_indent "Found span '$span_name' with attribute '$attribute_key'"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "Could not find span '$span_name' with attribute '$attribute_key'"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_jaeger_span_attribute:$span_name:$attribute_key")
  fi
}
