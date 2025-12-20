<#
.SYNOPSIS
    Restores the blinking cursor on the Raspberry Pi console.
.DESCRIPTION
    Re-enables the kernel cursor blinking and sends the VT100 escape code to show the cursor on tty1.
    Useful after running play-video-vlc.ps1 which hides it.
.PARAMETER HostName
    IP address or hostname of the Pi.
.PARAMETER UserName
    SSH username.
#>
param(
    [string]$HostName = "192.168.1.74",
    [string]$UserName = "tonicdub"
)

Write-Host "Restoring cursor on $HostName..." -ForegroundColor Cyan

# 1. Re-enable cursor blinking via kernel interface
# 2. Show cursor via escape code (\033[?25h) on tty1
$command = "echo 1 | sudo tee /sys/class/graphics/fbcon/cursor_blink > /dev/null; printf '\033[?25h' | sudo tee /dev/tty1 > /dev/null"

ssh "$UserName@$HostName" $command

if ($LASTEXITCODE -eq 0) {
    Write-Host "Cursor restored successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to restore cursor." -ForegroundColor Red
}
