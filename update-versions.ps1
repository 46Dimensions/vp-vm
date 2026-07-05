$ErrorActionPreference = "Stop"

$dir = $env:INSTALL_DIR

Write-Host "Updating versions..." -ForegroundColor Cyan

$vpUrl = "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/main/VERSION.txt"
$vmUrl = "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/VERSION.txt"

Write-Host "GET: $vpUrl" -ForegroundColor Blue
Invoke-WebRequest $vpUrl -OutFile "$dir\versions\vp\latest.txt"
Write-Host "GET: $vmUrl" -ForegroundColor Blue
Invoke-WebRequest $vmUrl -OutFile "$dir\versions\vp-vm\latest.txt"

function Read-Version($path) {
    if (Test-Path $path) {
        Write-Host "READ: $path" -ForegroundColor Magenta
        return (Get-Content $path).Trim()
    }
    else {
        Write-Error "Version file $path not found."
        exit 1
    }
}

$vpLatest = (Read-Version "$dir\versions\vp\latest.txt").Trim()
$vpCurrent = (Read-Version "$dir\versions\vp\current.txt").Trim()

$vmLatest = (Read-Version "$dir\versions\vp-vm\latest.txt").Trim()
$vmCurrent = (Read-Version "$dir\versions\vp-vm\current.txt").Trim()

$updates = 0
if ($vpLatest -ne $vpCurrent) { $updates++ }
if ($vmLatest -ne $vmCurrent) { $updates++ }

if ($updates -eq 0) {
    Write-Host "All packages are up to date." -ForegroundColor Green
}
else {
    Write-Host "$updates package(s) can be updated." -ForegroundColor Blue
    Write-Host "Use 'vp-vm list-upgradable' to see them." -ForegroundColor Magenta
}