<#
.SYNOPSIS
    Disables the login prompt (getty) on tty1.
.DESCRIPTION
    Even if kernel console messages are disabled, systemd still spawns a login prompt
    on tty1 by default. This script disables that service.
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

Write-Host "Disabling login prompt on tty1..." -ForegroundColor Cyan

# Mask the service so it cannot be started
ssh "$UserName@$HostName" "sudo systemctl mask getty@tty1.service"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Login prompt disabled." -ForegroundColor Green
    Write-Host "You must REBOOT the Pi for this to take effect." -ForegroundColor Yellow
    Write-Host "Run: ssh $UserName@$HostName 'sudo reboot'" -ForegroundColor Gray
} else {
    Write-Host "Failed to disable service." -ForegroundColor Red
}
