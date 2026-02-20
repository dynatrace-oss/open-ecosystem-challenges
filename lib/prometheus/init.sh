#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help         Display this help message"
  echo " --operator     Install Prometheus Operator instead of standalone Prometheus"
}

# Parse flags
use_operator=false

for arg in "$@"; do
  case "$arg" in
    --help)
      help
      exit 0
      ;;
    --operator)
      use_operator=true
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

# Use a minimal Prometheus setup instead of kube-prometheus-stack to keep the Codespace lightweight and focused.

echo "✨ Adding prometheus-community Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

echo "✨ Creating prometheus namespace"
kubectl create namespace prometheus

if [ "$use_operator" = true ]; then
  echo "✨ Installing Prometheus Operator (kube-prometheus-stack)"
  helm install prometheus prometheus-community/kube-prometheus-stack \
    --version 82.1.1 \
    --namespace prometheus \
    --values "$SCRIPT_DIR/operator-values.yaml" \
    --wait \
    --timeout 5m

  echo "✅ Prometheus Operator is ready"
  echo "💡 Use PrometheusRule CRDs to define recording and alerting rules"
else
  echo "✨ Installing standalone Prometheus"
  helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --values "$SCRIPT_DIR/standalone-values.yaml" \
    --wait \
    --timeout 5m

  echo "✅ Prometheus is ready"
fi
