#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Jaeger Helm chart version to install (required)"
}

# Parse flags
version=""

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

if [[ -z "$version" ]]; then
  echo "Error: --version is required" >&2
  exit 1
fi

# Use a minimal Jaeger setup instead of deploying it via the operator to keep the Codespace lightweight and focused.

echo "✨ Adding Jaeger Helm repo"
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

echo "✨ Creating jaeger namespace"
kubectl create namespace jaeger

echo "✨ Installing Jaeger via Helm"
helm install jaeger jaegertracing/jaeger \
  --version "$version" \
  --namespace jaeger \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 5m

echo "✨ Deploy service"
kubectl -n jaeger apply -f "$SCRIPT_DIR/manifests/service.yaml"

echo "✅ Jaeger is ready"