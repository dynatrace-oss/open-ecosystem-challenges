#!/usr/bin/env bash

# filesystem.sh - Helper functions for file system checks
# These functions verify file contents and existence

# -----------------------------------------------------------------------------
# Check if a file contains a specific pattern
# Usage: check_file_contains "file-path" "pattern" "Display Name" "Hint message" [ignore_case]
# -----------------------------------------------------------------------------
check_file_contains() {
  local file_path=$1
  local pattern=$2
  local display_name=$3
  local hint=$4
  local ignore_case=${5:-false}

  local grep_opts="-q"
  if [[ "$ignore_case" == "true" ]]; then
    grep_opts="-iq"
  fi

  print_test_section "Checking $display_name..."

  if grep $grep_opts "$pattern" "$file_path" 2>/dev/null; then
    print_success_indent "$display_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name - not found"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_file_contains:$pattern")
  fi
}

# -----------------------------------------------------------------------------
# Check if a file contains a specific pattern at least N times
# Usage: check_file_contains_count "file-path" "pattern" "min-count" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_file_contains_count() {
  local file_path=$1
  local pattern=$2
  local min_count=$3
  local display_name=$4
  local hint=$5

  print_test_section "Checking $display_name..."

  local count
  count=$(grep -c "$pattern" "$file_path" 2>/dev/null || echo "0")

  if [[ "$count" -ge "$min_count" ]]; then
    print_success_indent "$display_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name - not found"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_file_contains_count:$pattern")
  fi
}

