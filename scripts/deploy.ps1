param(
    [Parameter(Mandatory=$true)][string]$Path,
    [string]$PiHost = $env:PI_HOST,
    [string]$User = $env:PI_USER
)

if (-not $User) { $User = 'pi' }

if (-not $PiHost) {
    Write-Error "Set PI_HOST env var or pass -PiHost"
    exit 2
}

$projectName = Split-Path -Leaf $Path
$remoteBase = "~/projects"
# Ensure the parent directory exists on the Pi
Write-Host "Ensuring remote directory exists: $remoteBase"
ssh "${User}@${PiHost}" "mkdir -p $remoteBase"

$target = "${User}@${PiHost}:$remoteBase"
Write-Host "Deploying $Path -> $target"
scp -r $Path $target
ssh "${User}@${PiHost}" "echo 'Deployed to' $remoteBase/$projectName"
Write-Host "Done"