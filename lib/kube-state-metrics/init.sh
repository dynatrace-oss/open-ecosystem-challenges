#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    kube-state-metrics Helm chart version to install (default: 7.0.0)"
}

# Parse flags
version="7.0.0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
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

echo "✨ Adding prometheus-community Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "✨ Creating kube-state-metrics namespace"
kubectl create namespace kube-state-metrics

echo "✨ Installing kube-state-metrics via Helm"
helm install kube-state-metrics prometheus-community/kube-state-metrics \
  --version "$version" \
  --namespace kube-state-metrics \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 5m

echo "✅ kube-state-metrics is ready"