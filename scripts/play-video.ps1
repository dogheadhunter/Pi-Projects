<#
.SYNOPSIS
    Plays a video on the Raspberry Pi via direct framebuffer streaming.
.DESCRIPTION
    Transcodes a local video file to 480x320 RGB565 and streams it to the Pi's framebuffer.
    Requires ffmpeg and ssh.
.PARAMETER FilePath
    Path to the video file.
.PARAMETER HostName
    IP address or hostname of the Pi.
.PARAMETER UserName
    SSH username (default: pi).
.PARAMETER Fps
    Frames per second (default: 12).
.PARAMETER Duration
    Duration to play in seconds (optional).
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [string]$HostName = "192.168.1.74",

    [string]$UserName = "tonicdub",

    [int]$Fps,

    [string]$Duration
)

# 0. Interactive Prompts
if (-not $PSBoundParameters.ContainsKey('Fps')) {
    Write-Host "Enter FPS (Frames Per Second)" -ForegroundColor Yellow -NoNewline
    $inputFps = Read-Host " [Default: 15]"
    if ([string]::IsNullOrWhiteSpace($inputFps)) { 
        $Fps = 15 
    } else { 
        $Fps = [int]$inputFps 
    }
}

if (-not $PSBoundParameters.ContainsKey('Duration')) {
    Write-Host "Enter Duration in seconds" -ForegroundColor Yellow -NoNewline
    $inputDur = Read-Host " [Default: Play full video]"
    if (-not [string]::IsNullOrWhiteSpace($inputDur)) { 
        $Duration = $inputDur 
    }
}

# 1. Locate FFmpeg
$ffmpegPath = "ffmpeg.exe"
if (-not (Get-Command "ffmpeg" -ErrorAction SilentlyContinue)) {
    Write-Host "FFmpeg not found in PATH. Searching known locations..." -ForegroundColor Yellow
    
    $searchPaths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\ffmpeg"),
        (Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Definition)) "tools")
    )

    $found = $false
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $bin = Get-ChildItem $path -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
            if ($bin) {
                $ffmpegPath = $bin.FullName
                Write-Host "Found FFmpeg at: $ffmpegPath" -ForegroundColor Green
                $found = $true
                break
            }
        }
    }

    if (-not $found) {
        Write-Error "FFmpeg not found. Please install FFmpeg."
        exit 1
    }
}

# 2. Validate Input
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

# 3. Prepare Commands
$remoteFb = "/dev/fb1"
$resolution = "480x320"

# Construct FFmpeg arguments
# -re (read input at native frame rate) - optional, but good for streaming if we don't want to flood
# -i input
# -vf scale=480:320,fps=$Fps
# -pix_fmt rgb565le
# -f rawvideo
# -
$ffmpegArgs = @("-nostdin", "-re", "-i", "`"$FilePath`"", "-vf", "scale=480:320,fps=$Fps", "-pix_fmt", "rgb565le", "-f", "rawvideo", "-")
if (-not [string]::IsNullOrEmpty($Duration)) {
    $ffmpegArgs += ("-t", $Duration)
}

# 3. Pre-process Video (Resize to 480x320)
$processedVideoPath = Join-Path $env:TEMP "video_480p.mp4"
Write-Host "Pre-processing video to 480x320 to improve playback smoothness..." -ForegroundColor Cyan

# Check if we need to re-encode (if source changed or temp missing)
if (-not (Test-Path $processedVideoPath)) {
    $encodeArgs = @("-i", "`"$FilePath`"", "-vf", "scale=480:320", "-c:v", "libx264", "-profile:v", "baseline", "-level", "3.0", "-preset", "fast", "-crf", "23", "-an", "-y", "`"$processedVideoPath`"")
    $process = Start-Process -FilePath $ffmpegPath -ArgumentList $encodeArgs -Wait -NoNewWindow -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to pre-process video."
        exit 1
    }
}

# 4. Copy Files to Pi
$remoteVideoPath = "/tmp/video_480p.mp4"
$localSize = (Get-Item $processedVideoPath).Length

# Check remote file size
$remoteSizeStr = ssh "$UserName@$HostName" "stat -c %s $remoteVideoPath 2>/dev/null"
if ($remoteSizeStr -match "^\d+$" -and [int64]$remoteSizeStr -eq $localSize) {
    Write-Host "Optimized video file already exists on Pi. Skipping copy." -ForegroundColor Green
} else {
    Write-Host "Copying optimized video to $HostName..." -ForegroundColor Cyan
    scp "$processedVideoPath" "$UserName@$HostName`:$remoteVideoPath"
}

$localStreamScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "stream_to_fb.py"
$remoteStreamScript = "/tmp/stream_to_fb.py"
Write-Host "Copying streaming helper to $HostName..." -ForegroundColor Cyan
scp "$localStreamScript" "$UserName@$HostName`:$remoteStreamScript"

# 5. Stop FBCP
Write-Host "Stopping fbcp on $HostName..." -ForegroundColor Cyan
ssh "$UserName@$HostName" "sudo killall fbcp" 2>$null

# 6. Play Video Locally on Pi
Write-Host "Playing video on $HostName ($resolution @ $Fps fps)..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop."

# Run ffmpeg ON THE PI, piping to the python script ON THE PI.
# We use the optimized 480p file now.
$remoteCommand = "ffmpeg -re -i $remoteVideoPath -pix_fmt rgb565le -f rawvideo -loglevel error - | python3 $remoteStreamScript"

if (-not [string]::IsNullOrEmpty($Duration)) {
    # Apply duration to the ffmpeg command on the Pi
    $remoteCommand = "ffmpeg -re -t $Duration -i $remoteVideoPath -pix_fmt rgb565le -f rawvideo -loglevel error - | python3 $remoteStreamScript"
}

ssh -t "$UserName@$HostName" $remoteCommand

# 7. Restore FBCP
Write-Host "`nRestoring fbcp..." -ForegroundColor Cyan
ssh "$UserName@$HostName" "sudo systemd-run --unit=fbcp-restore --uid=root --gid=root /usr/local/bin/fbcp"

Write-Host "Done." -ForegroundColor Green
