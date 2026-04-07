#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    Argo Rollouts version to install (default: v1.8.3)"
}

# Parse flags
version="v1.8.3"

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

echo "✨ Installing Argo Rollouts"
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f "https://github.com/argoproj/argo-rollouts/releases/download/${version}/install.yaml"

echo "✨ Waiting for Argo Rollouts controller to be ready"
kubectl rollout status deployment/argo-rollouts -n argo-rollouts --timeout=300s

echo "✨ Installing Argo Rollouts Kubectl plugin"
curl -LO "https://github.com/argoproj/argo-rollouts/releases/download/${version}/kubectl-argo-rollouts-linux-amd64"
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

echo "✅ Argo Rollouts is ready"