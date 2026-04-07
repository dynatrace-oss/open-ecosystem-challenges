#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Ollama Helm chart version to install (default: 1.40.0)"
}

# Parse flags
version="1.40.0"

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

# Deploy Ollama to Kubernetes with TinyLlama model pre-loaded

echo "✨ Adding Ollama Helm repo"
helm repo add otwld https://helm.otwld.com/
helm repo update

echo "✨ Installing Ollama via Helm"
helm install ollama otwld/ollama \
  --version "$version" \
  --namespace ollama --create-namespace \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 10m

echo "✨ Waiting for Ollama to be ready"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=ollama -n ollama --timeout=300s

echo "✅ Ollama is ready with TinyLlama model"
