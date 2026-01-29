#!/usr/bin/env bash

# filesystem.sh - Helper functions for file system checks
# These functions verify file contents and existence

# -----------------------------------------------------------------------------
# Check if a file contains a specific pattern
# Usage: check_file_contains "file-path" "pattern" "Display Name" "Hint message"
# -----------------------------------------------------------------------------
check_file_contains() {
  local file_path=$1
  local pattern=$2
  local display_name=$3
  local hint=$4

  print_test_section "Checking $display_name..."

  if grep -q "$pattern" "$file_path" 2>/dev/null; then
    print_success_indent "$display_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "$display_name - not found"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_file_contains:$pattern")
  fi
}


