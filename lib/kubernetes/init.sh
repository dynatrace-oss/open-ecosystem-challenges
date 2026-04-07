#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help                    Display this help message"
  echo " --kind-version <ver>      kind version to install (default: v0.30.0)"
  echo " --kubectl-version <ver>   kubectl version to install (default: v1.34.1)"
  echo " --kubens-version <ver>    kubens version to install (default: v0.9.5)"
  echo " --k9s-version <ver>       k9s version to install (default: 0.50.16)"
  echo " --helm-version <ver>      Helm version to install (default: v4.0.1)"
}

# Parse flags
kind_version="v0.30.0"
kubectl_version="v1.34.1"
kubens_version="v0.9.5"
k9s_version="0.50.16"
helm_version="v4.0.1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
      ;;
    --kind-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --kind-version requires a value" >&2
        exit 1
      fi
      kind_version="$2"
      shift 2
      ;;
    --kubectl-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --kubectl-version requires a value" >&2
        exit 1
      fi
      kubectl_version="$2"
      shift 2
      ;;
    --kubens-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --kubens-version requires a value" >&2
        exit 1
      fi
      kubens_version="$2"
      shift 2
      ;;
    --k9s-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --k9s-version requires a value" >&2
        exit 1
      fi
      k9s_version="$2"
      shift 2
      ;;
    --helm-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --helm-version requires a value" >&2
        exit 1
      fi
      helm_version="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

echo "✨ Installing Kind"
curl -sS "https://webi.sh/kind@${kind_version}" | sh

echo "✨ Installing kubectl"
curl -LO "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "✨ Installing kubens"
curl -sS "https://webi.sh/kubens@${kubens_version}" | bash

echo "✨ Installing k9s"
curl -sS "https://webinstall.dev/k9s@${k9s_version}" | bash

echo "✨ Installing Helm"
curl -LO "https://get.helm.sh/helm-${helm_version}-linux-amd64.tar.gz"
tar -zxvf "helm-${helm_version}-linux-amd64.tar.gz"
chmod +x linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 "helm-${helm_version}-linux-amd64.tar.gz"

echo "✨ Starting Kind cluster"
kind create cluster --config "$SCRIPT_DIR/config.yaml" --wait 300s
kubectl cluster-info

echo "✅ Kubernetes cluster is ready"