<#
.SYNOPSIS
    Boosts the SPI bus speed for the TFT display to 60MHz.
.DESCRIPTION
    Modifies /boot/config.txt (or /boot/firmware/config.txt) to increase the SPI speed.
    This significantly improves frame rate smoothness on SPI displays.
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

Write-Host "Checking for config files on $HostName..." -ForegroundColor Cyan

# Define the command to boost speed
# We look for 'speed=...' inside the dtoverlay line for the display and change it to 60000000
# Or if it's a separate parameter.
# Usually it looks like: dtoverlay=tft35a:rotate=90,speed=32000000
# We will use sed to replace any speed=NUMBER with speed=60000000

$boostCommand = "
    for config in /boot/config.txt /boot/firmware/config.txt; do
        if [ -f `$config ]; then
            echo 'Updating ' `$config '...'
            # Backup first
            sudo cp `$config `$config.bak
            # Replace speed
            sudo sed -i 's/speed=[0-9]*/speed=60000000/g' `$config
            echo 'Done.'
        fi
    done
"

ssh "$UserName@$HostName" $boostCommand

Write-Host "SPI Speed updated." -ForegroundColor Green
Write-Host "You must REBOOT the Pi for this to take effect." -ForegroundColor Yellow
Write-Host "Run: ssh $UserName@$HostName 'sudo reboot'" -ForegroundColor Gray
