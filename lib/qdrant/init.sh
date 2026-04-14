#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Qdrant Helm chart version to install (required)"
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

echo "✨ Adding Qdrant Helm repo"
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo update

echo "✨ Creating qdrant namespace"
kubectl create namespace qdrant || true

echo "✨ Installing Qdrant via Helm"
helm install qdrant qdrant/qdrant \
  --version "$version" \
  --namespace qdrant \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 5m

echo "✨ Waiting for Qdrant to be ready"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=qdrant -n qdrant --timeout=300s

echo "✅ Qdrant is ready"

