#!/usr/bin/env bash

# prometheus.sh - Shared library for Prometheus metric checks
# This library provides functions to check Prometheus metrics

# Get Prometheus service cluster IP
# Usage: get_prometheus_service "namespace" "service-name"
# Returns: Cluster IP or empty string
get_prometheus_service() {
  local ns=${1:-"prometheus"}
  local svc=${2:-"prometheus-server"}

  kubectl get svc -n "$ns" "$svc" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo ""
}

# Check if a Prometheus metric exists
# Usage: prometheus_metric_exists "metric-query" "prometheus-service-ip" "port"
# Returns: 0 if metric exists, 1 if not
prometheus_metric_exists() {
  local query=$1
  local prom_service=$2
  local port=${3:-80}

  local result
  result=$(kubectl run prometheus-query-test-$RANDOM --rm -i --restart=Never --image=curlimages/curl:8.11.1 -- \
    curl -s "http://$prom_service:$port/api/v1/query?query=$query" 2>/dev/null | grep -o '"status":"success"' || echo "")

  if [ -n "$result" ]; then
    return 0
  else
    return 1
  fi
}

# Check multiple Prometheus metrics
# Usage: check_prometheus_metrics "label" "prometheus-namespace" "prometheus-service" "port" "metric1:hint1" "metric2:hint2" ...
# Args: label, prom_namespace, prom_service, port, then pairs of "metric:hint"
# Example: check_prometheus_metrics "Application Metrics" "prometheus" "prometheus-server" "80" \
#            "hotrod_requests_total:Check if HotROD is exposing metrics" \
#            "up:Check if Prometheus is scraping targets"
check_prometheus_metrics() {
  local label=$1
  local prom_ns=$2
  local prom_svc=$3
  local port=$4
  shift 4

  local metrics=("$@")

  print_test_section "Checking $label"

  # Get Prometheus service endpoint
  local prom_service
  prom_service=$(get_prometheus_service "$prom_ns" "$prom_svc")

  if [ -z "$prom_service" ]; then
    print_error_indent "Prometheus service '$prom_svc' not found in namespace '$prom_ns'"
    print_hint "Ensure Prometheus is running: kubectl get pods -n $prom_ns"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  fi

  local metrics_found=0
  local total_metrics=${#metrics[@]}

  for metric_hint in "${metrics[@]}"; do
    # Split metric and hint by colon
    local metric="${metric_hint%%:*}"
    local hint="${metric_hint#*:}"

    if prometheus_metric_exists "$metric" "$prom_service" "$port"; then
      print_info_indent "✓ $metric metric found in Prometheus"
      metrics_found=$((metrics_found + 1))
    else
      print_error_indent "$metric metric not found"
      print_hint "$hint"
    fi
  done

  if [ "$metrics_found" -eq "$total_metrics" ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    print_new_line
    print_success "✅ $label are healthy!"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Check if a Prometheus recording rule exists
# Usage: check_prometheus_rule "rule-name" "prometheus-namespace" "prometheus-service" "port" "Hint message"
# Returns: 0 if rule exists, 1 if not
check_prometheus_rule() {
  local rule_name=$1
  local prom_ns=$2
  local prom_svc=$3
  local port=$4
  local hint=$5

  print_test_section "Checking Prometheus Rule '$rule_name'..."

  # Get Prometheus service endpoint
  local prom_service
  prom_service=$(get_prometheus_service "$prom_ns" "$prom_svc")

  if [ -z "$prom_service" ]; then
    print_error_indent "Prometheus service '$prom_svc' not found in namespace '$prom_ns'"
    print_hint "Ensure Prometheus is running: kubectl get pods -n $prom_ns"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  fi

  # Query Prometheus Rules API
  local result
  result=$(kubectl run prometheus-rule-test-$RANDOM --rm -i --restart=Never --image=curlimages/curl:8.11.1 -- \
    curl -s "http://$prom_service:$port/api/v1/rules" 2>/dev/null | grep -o "\"name\":\"$rule_name\"" || echo "")

  if [ -n "$result" ]; then
    print_success_indent "Found recording rule '$rule_name'"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    print_error_indent "Recording rule '$rule_name' not found"
    print_hint "$hint"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_CHECKS+=("check_prometheus_rule:$rule_name")
  fi
}
