<#
.SYNOPSIS
    Disables the boot logo (Raspberries) and the blinking cursor globally.
.DESCRIPTION
    Modifies /boot/firmware/cmdline.txt to add:
    - logo.nologo: Hides the raspberries at the top.
    - vt.global_cursor_default=0: Hides the blinking cursor everywhere, forever.
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

Write-Host "Disabling boot logo and global cursor on $HostName..." -ForegroundColor Cyan

$configFile = "/boot/firmware/cmdline.txt"

# 1. Backup
ssh "$UserName@$HostName" "sudo cp $configFile $configFile.bak"

# 2. Append parameters to the end of the line
# We use sed to append to the end of the line ($)
ssh "$UserName@$HostName" "sudo sed -i 's/$/ logo.nologo vt.global_cursor_default=0/' $configFile"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Boot config updated." -ForegroundColor Green
    Write-Host "You must REBOOT the Pi for this to take effect." -ForegroundColor Yellow
    Write-Host "Run: ssh $UserName@$HostName 'sudo reboot'" -ForegroundColor Gray
} else {
    Write-Host "Failed to update config." -ForegroundColor Red
}
