#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

echo "✨ Adding Qdrant Helm repo"
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo update

echo "✨ Creating qdrant namespace"
kubectl create namespace qdrant || true

echo "✨ Installing Qdrant via Helm"
helm install qdrant qdrant/qdrant \
  --version 1.16.3 \
  --namespace qdrant \
  --values "$SCRIPT_DIR/values.yaml" \
  --wait \
  --timeout 5m

echo "✨ Waiting for Qdrant to be ready"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=qdrant -n qdrant --timeout=300s

echo "✅ Qdrant is ready"

