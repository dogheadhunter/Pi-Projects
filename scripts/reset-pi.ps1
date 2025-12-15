param(
    [string]$PiHost = $env:PI_HOST,
    [string]$User = $env:PI_USER
)

if (-not $User) { $User = 'pi' }

if (-not $PiHost) {
    Write-Error "Set PI_HOST env var or pass -PiHost"
    exit 2
}

Write-Host "Cleaning up project files on ${User}@${PiHost}..."

# Remove the projects directory where we deploy code
Write-Host "Removing ~/projects..."
ssh "${User}@${PiHost}" "rm -rf ~/projects"

# Remove the test file created during the session
Write-Host "Removing ~/pi-test.txt..."
ssh "${User}@${PiHost}" "rm -f ~/pi-test.txt"

Write-Host "Cleanup complete. (Note: ~/pi-workspace was not touched)"
