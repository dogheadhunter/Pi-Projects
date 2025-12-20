<#
.SYNOPSIS
    Plays a video on the Raspberry Pi using VLC and FBCP (Smoother method).
.DESCRIPTION
    Copies video to Pi and plays it using cvlc (Console VLC) to the main framebuffer.
    Relies on 'fbcp' running in the background to mirror the video to the TFT screen.
.PARAMETER FilePath
    Path to the video file.
.PARAMETER HostName
    IP address or hostname of the Pi.
.PARAMETER UserName
    SSH username.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [string]$HostName = "192.168.1.74",

    [string]$UserName = "tonicdub"
)

# 1. Check for VLC on Pi
Write-Host "Checking for VLC on $HostName..." -ForegroundColor Cyan
$vlcCheck = ssh "$UserName@$HostName" "which cvlc"
if (-not $vlcCheck) {
    Write-Error "VLC is not installed on the Pi. Please run: sudo apt-get install vlc"
    exit 1
}

# 2. Prepare Display
Write-Host "Preparing display..." -ForegroundColor Cyan
# We don't need FBCP running yet, we will manage it in the playback section.

# 3. Copy Video (Optimized)
$remoteVideoPath = "/tmp/video_vlc.mp4"
$localSize = (Get-Item $FilePath).Length

# Check remote file size
$remoteSizeStr = ssh "$UserName@$HostName" "stat -c %s $remoteVideoPath 2>/dev/null"
if ($remoteSizeStr -match "^\d+$" -and [int64]$remoteSizeStr -eq $localSize) {
    Write-Host "Video file already exists on Pi. Skipping copy." -ForegroundColor Green
} else {
    Write-Host "Copying video to $HostName..." -ForegroundColor Cyan
    scp "$FilePath" "$UserName@$HostName`:$remoteVideoPath"
}

# 3.5 Optimize Video (Transcode if needed)
$optimizedPath = "/tmp/video_optimized.mp4"
Write-Host "Checking for optimized video..." -ForegroundColor Cyan

# Check if we need to transcode (if optimized file doesn't exist or is older than source)
$needsTranscode = ssh "$UserName@$HostName" "if [ ! -f $optimizedPath ] || [ $remoteVideoPath -nt $optimizedPath ]; then echo 'yes'; else echo 'no'; fi"

if ($needsTranscode.Trim() -eq 'yes') {
    Write-Host "Transcoding video to 480x320 @ 12fps for smooth playback..." -ForegroundColor Yellow
    # -preset ultrafast for speed, -crf 23 for decent quality, -r 12 for 12fps
    ssh "$UserName@$HostName" "ffmpeg -i $remoteVideoPath -vf 'scale=480:320' -r 12 -c:v libx264 -preset ultrafast -crf 23 -c:a copy $optimizedPath -y -hide_banner -loglevel error"
} else {
    Write-Host "Using existing optimized video." -ForegroundColor Green
}

# 4. Play Video (FFmpeg to fb0 + FBCP)
Write-Host "Playing video to Main Display (fb0)..." -ForegroundColor Green
Write-Host "Using FBCP for VSYNC to fix tearing/rolling bars."
Write-Host "Press Ctrl+C to stop."

# We revert to writing to /dev/fb0 (HDMI).
# Why? Because writing directly to fb1 (SPI) causes the "rolling bar" (tearing)
# because ffmpeg writes faster than the screen can draw.
# fbcp acts as a "VSYNC" buffer - it reads the smooth HDMI frame and copies it 
# to the SPI screen at the correct timing.
# NOTE: We use the optimized (pre-scaled) file to reduce CPU load during playback.
$remoteCommand = "sudo nice -n -10 ffmpeg -re -i $optimizedPath -pix_fmt bgra -f fbdev /dev/fb0 -hide_banner -loglevel error"

try {
    Write-Host "Optimizing performance..." -ForegroundColor Cyan
    
    # Ensure fbcp is RUNNING (we need it now)
    ssh "$UserName@$HostName" "sudo systemctl start fbcp-restore" 2>$null
    
    # Give fbcp high priority so it can keep up with the copy
    ssh "$UserName@$HostName" "sudo renice -n -10 -p `$(pgrep -x fbcp) 2>/dev/null"

    # NOTE: We no longer need to hide cursor/unbind console if disable-console.ps1 was run.
    # But we keep this here as a fallback just in case.
    ssh "$UserName@$HostName" "echo 0 | sudo tee /sys/class/graphics/fbcon/cursor_blink > /dev/null"

    ssh -t "$UserName@$HostName" $remoteCommand
}
finally {
    Write-Host "`nClearing screen..." -ForegroundColor Yellow
    # Clear the framebuffer (fill with black)
    ssh "$UserName@$HostName" "dd if=/dev/zero of=/dev/fb0 2>/dev/null"
    
    # Restart fbcp (Optional: If you want the desktop back when done)
    # If you want it purely headless forever, you can comment this out.
    ssh "$UserName@$HostName" "sudo systemctl start fbcp-restore" 2>$null
}
# End of script
