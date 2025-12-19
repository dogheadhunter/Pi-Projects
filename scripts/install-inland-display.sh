#!/usr/bin/env bash
# Install script for Inland 3.5" TFT (ILI9486) using LCD-show or manual dtoverlay
# Usage: ./scripts/install-inland-display.sh <PI_HOST> [PI_USER] [--manual]
set -euo pipefail
PI_HOST=${1:-}
PI_USER=${2:-pi}
MANUAL=false
if [[ "${3:-}" == "--manual" ]]; then
  MANUAL=true
fi
if [[ -z "$PI_HOST" ]]; then
  echo "Usage: $0 <PI_HOST> [PI_USER] [--manual]"
  exit 2
fi
echo "About to install Inland Display drivers on ${PI_USER}@${PI_HOST}."
read -p "This may reboot the Pi and can affect HDMI output. Continue? [y/N] " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborting."
  exit 0
fi
REMOTE="$PI_USER@$PI_HOST"
ssh $REMOTE "echo Connected to \\$(hostname)"
if [ "$MANUAL" = true ]; then
  echo "Using manual dtoverlay method (safe fallback). Backing up /boot/firmware/config.txt and enabling SPI."
  ssh $REMOTE "sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.inlandbak || true"
  ssh $REMOTE "sudo sed -n '1,400p' /boot/firmware/config.txt | tail -n +1 | sudo tee /boot/firmware/config.txt >/dev/null"
  ssh $REMOTE "sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.inlandbak2 || true"
  ssh $REMOTE "sudo sh -c 'grep -q "^dtparam=spi=on" /boot/firmware/config.txt || echo \"dtparam=spi=on\" >> /boot/firmware/config.txt'"
  ssh $REMOTE "sudo sh -c 'grep -q "dtoverlay=piscreen" /boot/firmware/config.txt || echo \"dtoverlay=piscreen,speed=16000000,rotate=90\" >> /boot/firmware/config.txt'"
  echo "Manual overlay applied. Rebooting now..."
  ssh $REMOTE "sudo reboot"
  exit 0
fi
# Default: run LCD-show
echo "Cloning LCD-show and running LCD35-show (this is the recommended method on Legacy/Bullseye)."
ssh $REMOTE "rm -rf LCD-show || true && git clone https://github.com/goodtft/LCD-show.git"
ssh $REMOTE "sudo chmod -R 755 LCD-show || true"
ssh $REMOTE "cd LCD-show && sudo ./LCD35-show" || true
# Note: LCD35-show will reboot the Pi
echo "Installer invoked on the Pi. If the Pi didn't reboot automatically, you may need to reboot manually."