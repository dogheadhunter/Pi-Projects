param(
    [Parameter(Mandatory=$true)][string]$PiHost,
    [string]$User = 'pi',
    [switch]$Manual
)
if (-not $PiHost) { Write-Error "PiHost is required"; exit 2 }
$remote = "$User@$PiHost"
Write-Host "About to install Inland Display drivers on $remote"
$confirm = Read-Host "This may reboot the Pi and can affect HDMI output. Proceed? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') { Write-Host "Aborting"; exit 0 }
ssh "$remote" "echo Connected to $(hostname)"
if ($Manual) {
    Write-Host "Applying manual dtoverlay: enabling SPI and adding dtoverlay=piscreen"
    ssh "$remote" "sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.inlandbak || true"
    ssh "$remote" "sudo sh -c 'grep -q "^dtparam=spi=on" /boot/firmware/config.txt || echo \"dtparam=spi=on\" >> /boot/firmware/config.txt'"
    ssh "$remote" "sudo sh -c 'grep -q "dtoverlay=piscreen" /boot/firmware/config.txt || echo \"dtoverlay=piscreen,speed=16000000,rotate=90\" >> /boot/firmware/config.txt'"
    Write-Host "Rebooting..."
    ssh "$remote" "sudo reboot"
    exit 0
}
Write-Host "Cloning LCD-show and running LCD35-show (recommended on Legacy/Bullseye)"
ssh "$remote" "rm -rf LCD-show || true && git clone https://github.com/goodtft/LCD-show.git"
ssh "$remote" "sudo chmod -R 755 LCD-show || true"
# Invoke LCD35-show; check exit code because '||' is not valid in PowerShell
ssh "$remote" "cd LCD-show && sudo ./LCD35-show"
if ($LASTEXITCODE -ne 0) { Write-Warning "LCD35-show exited or failed (exit code $LASTEXITCODE)" }
Write-Host "Installer invoked on the Pi. If the Pi didn't reboot automatically, you may need to reboot manually."