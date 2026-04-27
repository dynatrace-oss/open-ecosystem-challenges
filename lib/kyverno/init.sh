#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help                 Display this help message"
  echo " --version <ver>        Kyverno Helm chart version to install (required)"
  echo " --cli-version <ver>    Kyverno CLI version to install (required)"
}

# Parse flags
version=""
cli_version=""

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
    --cli-version)
      if [[ -z "${2-}" ]]; then
        echo "Error: --cli-version requires a value" >&2
        exit 1
      fi
      cli_version="$2"
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

if [[ -z "$cli_version" ]]; then
  echo "Error: --cli-version is required" >&2
  exit 1
fi

echo "✨ Installing Kyverno"
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  --version "$version" \
  --set admissionController.replicas=1 \
  --set features.policyExceptions.enabled=true \
  --wait

echo "✨ Waiting for Kyverno admission controller to be ready"
kubectl rollout status deployment/kyverno-admission-controller -n kyverno --timeout=300s

echo "✨ Installing Kyverno CLI"
# shellcheck disable=SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../scripts/arch.sh"
# Kyverno CLI release assets use x86_64 instead of amd64
if [[ "$ARCH" == "amd64" ]]; then
  CLI_ARCH="x86_64"
else
  CLI_ARCH="$ARCH"
fi
TARBALL="kyverno-cli_${cli_version}_linux_${CLI_ARCH}.tar.gz"
curl -LO "https://github.com/kyverno/kyverno/releases/download/${cli_version}/${TARBALL}"
tar -xf "${TARBALL}" kyverno
chmod +x kyverno
sudo mv kyverno /usr/local/bin/kyverno
rm "${TARBALL}"

echo "✅ Kyverno is ready"