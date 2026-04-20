#!/usr/bin/env bash
# Source this file to get ARCH set to "amd64" or "arm64".
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac
export ARCH
