#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --version <ver>    GCP API Mock version to install (required)"
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

echo "✨ Starting the GCP API Mock"
docker run -d -p 30104:8080 "ghcr.io/katharinasick/gcp-api-mock:${version}"

# Set environment variable to redirect GCS backend requests to the mock
echo 'export STORAGE_EMULATOR_HOST="http://localhost:30104"' >> ~/.bashrc
echo 'export STORAGE_EMULATOR_HOST="http://localhost:30104"' >> ~/.zshrc
export STORAGE_EMULATOR_HOST="http://localhost:30104"

echo "✅ GCP API Mock is ready"