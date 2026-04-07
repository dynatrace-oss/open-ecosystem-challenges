#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    gum version to install (default: v0.17.0)"
}

# Parse flags
version="v0.17.0"

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

echo "✨ Installing gum"
case "$(uname -m)" in
    aarch64|arm64)     ARCH="arm64" ;;
    *)                 ARCH="amd64" ;;
esac

curl -LO "https://github.com/charmbracelet/gum/releases/download/${version}/gum_${version#v}_${ARCH}.deb"
sudo apt install "./gum_${version#v}_${ARCH}.deb"
rm "gum_${version#v}_${ARCH}.deb"
