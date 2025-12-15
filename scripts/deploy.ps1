param(
    [Parameter(Mandatory=$true)][string]$Path,
    [string]$Host = $env:PI_HOST,
    [string]$User = $env:PI_USER -or 'pi'
)

if (-not $Host) {
    Write-Error "Set PI_HOST env var or pass -Host"
    exit 2
}

$target = "$User@$Host:~/projects/$(Split-Path -Leaf $Path)"
Write-Host "Deploying $Path -> $target"
scp -r $Path $target
ssh "$User@$Host" "echo 'Deployed to' ~/projects/$(Split-Path -Leaf $Path)"
Write-Host "Done"