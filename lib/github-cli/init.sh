#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help             Display this help message"
  echo " --act              Installs the nektos/act extension"
  echo " --version <ver>    GitHub CLI version to install (required)"
}

# Parse flags
act=false
version=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      help
      exit 0
      ;;
    --act)
      act=true
      shift
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

echo "✨ Installing the GitHub CLI"
curl -sS "https://webi.sh/gh@${version}" | sh

if [ "$act" = true ]; then
  echo "✨ Installin nektos/act extension"
  gh extension install https://github.com/nektos/gh-act

fi

echo "✅ GitHub CLI is ready"
