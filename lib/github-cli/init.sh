#!/usr/bin/env bash
set -e

help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo " --help   Display this help message"
  echo " --act    Installs the nektos/act extension"
}

# Parse flags
act=false

for arg in "$@"; do
  case "$arg" in
    --help)
      help
      exit 0
      ;;
    --act)
      act=true
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

echo "✨ Installing the GitHub CLI"
curl -sS https://webi.sh/gh@v2.86.0 | sh

if [ "$act" = true ]; then
  echo "✨ Installin nektos/act extension"
  gh extension install https://github.com/nektos/gh-act

fi

echo "✅ GitHub CLI is ready"
