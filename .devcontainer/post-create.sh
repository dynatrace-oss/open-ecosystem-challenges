#!/usr/bin/env bash
set -euo pipefail

lib/shared/init.sh --version v0.17.0 # https://github.com/charmbracelet/gum/releases

echo "→ Installing mkdocs-material..."
pip install --quiet mkdocs-material mkdocs-monorepo-plugin

echo "✓ Done! Run 'mkdocs serve' to start the docs server."

