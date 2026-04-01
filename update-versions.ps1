$ErrorActionPreference = "Stop"

$dir = $env:INSTALL_DIR

Write-Host "Updating versions..." -ForegroundColor Cyan

$vpUrl = "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/main/VERSION.txt"
$vmUrl = "https://raw.githubusercontent.com/46Dimensions/vp-vm/main/VERSION.txt"

Invoke-WebRequest $vpUrl -OutFile "$dir\versions\vp\latest.txt"
Invoke-WebRequest $vmUrl -OutFile "$dir\versions\vp-vm\latest.txt"

$vpLatest = (Get-Content "$dir\versions\vp\latest.txt").Trim()
$vpCurrent = (Get-Content "$dir\versions\vp\current.txt").Trim()

$vmLatest = (Get-Content "$dir\versions\vp-vm\latest.txt").Trim()
$vmCurrent = (Get-Content "$dir\versions\vp-vm\current.txt").Trim()

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