#!/usr/bin/env bash
set -e

echo "✨ Installing gum"
case "$(uname -m)" in
    aarch64|arm64)     ARCH="arm64" ;;
    *)                 ARCH="amd64" ;;
esac

curl -LO "https://github.com/charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_${ARCH}.deb"
sudo apt install ./gum_0.17.0_${ARCH}.deb
rm gum_0.17.0_${ARCH}.deb
