<#
.SYNOPSIS
    Transfers a local image to the Pi and displays it on the Inland TFT for a set duration.
.DESCRIPTION
    Uses scp to copy the file to /tmp on the Pi, then uses 'fbi' to display it on /dev/fb1.
    Automatically kills 'fbcp' if running to prevent overwriting.
.EXAMPLE
    .\display-image.ps1 -ImagePath "C:\Photos\cat.jpg" -Duration 10 -PiHost 192.168.1.74
#>
param(
    [Parameter(Mandatory=$true)][string]$ImagePath,
    [int]$Duration = 10,
    [string]$PiHost = $env:PI_HOST,
    [string]$User = $env:PI_USER
)

if (-not $User) { $User = 'pi' }
if (-not $PiHost) {
    Write-Error "PiHost is required. Set PI_HOST env var or pass -PiHost."
    exit 2
}

if (-not (Test-Path $ImagePath)) {
    Write-Error "File not found: $ImagePath"
    exit 1
}

$fileName = Split-Path $ImagePath -Leaf
$remotePath = "/tmp/$fileName"
$remote = "$User@$PiHost"

Write-Host "Sending $fileName to $remote..."
scp $ImagePath "$remote`:$remotePath"

Write-Host "Displaying on Pi for $Duration seconds..."
Write-Host "(You may be prompted for your password again)"

# Remote command sequence:
# 1. Install fbi if missing
# 2. Kill fbcp (interferes with display)
# 3. Kill old fbi instances
# 4. Run fbi in background (targeting /dev/fb1)
# 5. Sleep for duration
# 6. Kill fbi
# 7. Restart fbcp to restore desktop
$cmd = "which fbi >/dev/null || sudo apt-get install -y fbi; " +
       "sudo killall fbcp 2>/dev/null; " +
       "sudo killall fbi 2>/dev/null; " +
       "sudo fbi -T 1 -d /dev/fb1 -noverbose -a $remotePath >/dev/null 2>&1 & " +
       "sleep $Duration; " +
       "sudo killall fbi 2>/dev/null; " +
       "sudo killall fbcp 2>/dev/null; " +
       "sudo systemd-run --unit=fbcp-restore --service-type=simple fbcp >/dev/null 2>&1"

# Use -t to force pseudo-terminal allocation, which helps with password prompts and sudo interaction
ssh -t $remote $cmd
Write-Host "Done."
