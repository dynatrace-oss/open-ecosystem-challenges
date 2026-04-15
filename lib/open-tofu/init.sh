#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    OpenTofu version to install (required)"
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

echo "✨ Installing Open Tofu"

curl -LO "https://github.com/opentofu/opentofu/releases/download/${version}/tofu_${version#v}_linux_amd64.zip"
unzip "tofu_${version#v}_linux_amd64.zip" tofu
chmod +x tofu
sudo mv tofu /usr/local/bin/tofu
rm -f "tofu_${version#v}_linux_amd64.zip"
tofu version

echo "✅ Open Tofu is ready"