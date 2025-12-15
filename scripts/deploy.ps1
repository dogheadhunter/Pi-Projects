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

$target = "${User}@${PiHost}:~/projects/$(Split-Path -Leaf $Path)"
Write-Host "Deploying $Path -> $target"
scp -r $Path $target
ssh "${User}@${PiHost}" "echo 'Deployed to' ~/projects/$(Split-Path -Leaf $Path)"
Write-Host "Done"