<#
.SYNOPSIS
    Permanently disables the console text on the TFT screen.
.DESCRIPTION
    Modifies /boot/cmdline.txt (or /boot/firmware/cmdline.txt) to remove 'console=tty1'.
    This prevents the Linux text console from ever appearing on the screen, making it
    dedicated for video/images only.
    REQUIRES A REBOOT TO TAKE EFFECT.
.PARAMETER HostName
    IP address or hostname of the Pi.
.PARAMETER UserName
    SSH username.
#>
param(
    [string]$HostName = "192.168.1.74",
    [string]$UserName = "tonicdub"
)

Write-Host "Disabling console on $HostName..." -ForegroundColor Cyan

# We target /boot/firmware/cmdline.txt directly as it's the standard on Bookworm
$configFile = "/boot/firmware/cmdline.txt"

# 1. Backup
ssh "$UserName@$HostName" "sudo cp $configFile $configFile.bak"

# 2. Remove 'console=tty1' using sed
# This tells the kernel NOT to output text to the main terminal
ssh "$UserName@$HostName" "sudo sed -i 's/console=tty1//g' $configFile"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Console disabled." -ForegroundColor Green
    Write-Host "You must REBOOT the Pi for this to take effect." -ForegroundColor Yellow
    Write-Host "Run: ssh $UserName@$HostName 'sudo reboot'" -ForegroundColor Gray
} else {
    Write-Host "Failed to update config." -ForegroundColor Red
}
