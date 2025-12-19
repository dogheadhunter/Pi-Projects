#!/usr/bin/env bash
# Minimal remote checks for Inland Display
# Usage: ./scripts/check-display.sh <PI_HOST> [PI_USER]
set -euo pipefail
PI_HOST=${1:-}
PI_USER=${2:-pi}
if [[ -z "$PI_HOST" ]]; then
  echo "Usage: $0 <PI_HOST> [PI_USER]"
  exit 2
fi
REMOTE="$PI_USER@$PI_HOST"
echo "Checking /dev/fb* on $REMOTE"
ssh $REMOTE "ls -la /dev/fb* || true"
echo "Checking /boot/firmware/config.txt for SPI and overlays"
ssh $REMOTE "grep -E 'dtparam=spi|dtoverlay' /boot/firmware/config.txt || true"
echo "Checking loaded modules and dmesg for display driver hints"
ssh $REMOTE "lsmod | grep -E 'fbtft|fb_ili' || true; dmesg | grep -i 'ili\|fbtft\|piscreen' || true"
echo "If /dev/fb1 exists and overlay is present, the framebuffer device is available. If not, consider running the installer script or try the manual method."