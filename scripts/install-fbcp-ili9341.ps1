<#
.SYNOPSIS
    Installs and configures fbcp-ili9341 for high-performance display.
.DESCRIPTION
    This script compiles the optimized fbcp-ili9341 driver for the Inland 3.5" (ILI9486) display.
    It disables the standard kernel driver (tft35a) to allow direct SPI access.
#>
param(
    [string]$HostName = "192.168.1.74",
    [string]$UserName = "tonicdub"
)

$RemoteScript = @"
set -e

echo "1. Installing dependencies..."
sudo apt-get update
sudo apt-get install -y cmake git

echo "2. Cloning fbcp-ili9341..."
cd /home/$UserName
if [ -d "fbcp-ili9341" ]; then
    rm -rf fbcp-ili9341
fi
git clone https://github.com/juj/fbcp-ili9341.git
cd fbcp-ili9341

echo "3. Configuring build for Inland 3.5 (ILI9486)..."
# Inland 3.5 is usually ILI9486.
# We use SPI_BUS_CLOCK_DIVISOR=12 (approx 33MHz) for stability.
# Previous attempt at 8 (50MHz) caused white screen.
mkdir build
cd build
cmake -DILI9486=ON -DGPIO_TFT_DATA_CONTROL=24 -DGPIO_TFT_RESET_PIN=25 -DSPI_BUS_CLOCK_DIVISOR=12 -DBACKLIGHT_CONTROL=ON -DSTATISTICS=0 ..

echo "4. Compiling..."
make -j

echo "5. Installing service..."
sudo cp fbcp-ili9341 /usr/local/bin/fbcp-ili9341

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/fbcp-ili9341.service
[Unit]
Description=fbcp-ili9341
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/fbcp-ili9341
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable fbcp-ili9341

echo "6. Disabling kernel driver in config.txt..."
# We need to disable dtoverlay=tft35a because fbcp-ili9341 needs exclusive SPI access.
sudo sed -i 's/^dtoverlay=tft35a/#dtoverlay=tft35a/' /boot/firmware/config.txt

echo "Done! Please reboot for changes to take effect."
"@

# Write script to file and execute
$LocalScriptPath = "scripts/install-fbcp-ili9341.sh"
$RemoteScript | Out-File -FilePath $LocalScriptPath -Encoding ascii
# Convert line endings just in case
(Get-Content $LocalScriptPath) -join "`n" | Set-Content -NoNewline $LocalScriptPath

Write-Host "Copying installer to Pi..."
scp $LocalScriptPath "$UserName@$HostName`:/tmp/install-fbcp.sh"

Write-Host "Running installer on Pi..."
ssh -t "$UserName@$HostName" "bash /tmp/install-fbcp.sh"
