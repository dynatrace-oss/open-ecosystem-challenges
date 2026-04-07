#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --operator         Install Prometheus Operator instead of standalone Prometheus"
  echo " --version <ver>    Helm chart version to install (operator default: 82.1.1; standalone: latest)"
}

# Parse flags
use_operator=false
version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
      ;;
    --operator)
      use_operator=true
      shift
      ;;
    --version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --version requires a value" >&2
        exit 1
      fi
      version="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Use a minimal Prometheus setup instead of kube-prometheus-stack to keep the Codespace lightweight and focused.

# Apply mode-specific version defaults
if [[ "$use_operator" = true && -z "$version" ]]; then
  version="82.1.1"
fi

echo "✨ Adding prometheus-community Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

echo "✨ Creating prometheus namespace"
kubectl create namespace prometheus

if [ "$use_operator" = true ]; then
  echo "✨ Installing Prometheus Operator (kube-prometheus-stack)"
  helm install prometheus prometheus-community/kube-prometheus-stack \
    --version "$version" \
    --namespace prometheus \
    --values "$SCRIPT_DIR/operator-values.yaml" \
    --wait \
    --timeout 5m

  echo "✅ Prometheus Operator is ready"
  echo "💡 Use PrometheusRule CRDs to define recording and alerting rules"
else
  helm_args=(prometheus prometheus-community/prometheus
    --namespace prometheus
    --values "$SCRIPT_DIR/standalone-values.yaml"
    --wait
    --timeout 5m)
  [[ -n "$version" ]] && helm_args+=(--version "$version")

  echo "✨ Installing standalone Prometheus"
  helm install "${helm_args[@]}"

  echo "✅ Prometheus is ready"
fi
