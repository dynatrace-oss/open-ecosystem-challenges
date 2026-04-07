#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Accepted for API consistency; the OTEL Collector version is defined in the manifests"
}

# Parse flags
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
      echo "Warning: --version is ignored for otel-collector; the version is defined in the manifests" >&2
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

echo "✨ Creating otel namespace"
kubectl create namespace otel || true

echo "✨ Deploying OTEL Collector manifests"
kubectl apply -n otel -f "$SCRIPT_DIR/manifests/"

echo "✨ Waiting for OTEL Collector to be ready"
kubectl rollout status deployment/collector -n otel --timeout=120s

echo "✅ OTEL Collector is ready"
