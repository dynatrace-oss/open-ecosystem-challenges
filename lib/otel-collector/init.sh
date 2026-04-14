#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    otel/opentelemetry-collector-contrib image tag (required)"
}

version=""

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

echo "✨ Creating otel namespace"
kubectl create namespace otel || true

echo "✨ Deploying OTEL Collector manifests (version ${version})"
kubectl apply -n otel -f "$SCRIPT_DIR/manifests/config.yaml"
kubectl apply -n otel -f "$SCRIPT_DIR/manifests/service.yaml"
sed "s|otel/opentelemetry-collector-contrib:.*|otel/opentelemetry-collector-contrib:${version}|" \
  "$SCRIPT_DIR/manifests/deployment.yaml" | kubectl apply -n otel -f -

echo "✨ Waiting for OTEL Collector to be ready"
kubectl rollout status deployment/collector -n otel --timeout=120s

echo "✅ OTEL Collector is ready"
