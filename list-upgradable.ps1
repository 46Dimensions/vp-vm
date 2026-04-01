$ErrorActionPreference = "Stop"

$dir = $env:INSTALL_DIR

function Read-Version($path) {
    if (Test-Path $path) {
        return (Get-Content $path -Raw).Trim()
    }
    return $null
}

Write-Host "Listing..." -ForegroundColor Cyan

$vpLatest = Read-Version "$dir\versions\vp\latest.txt"
$vpVmLatest = Read-Version "$dir\versions\vp-vm\latest.txt"

$vpCurrent = Read-Version "$dir\versions\vp\current.txt"
$vpVmCurrent = Read-Version "$dir\versions\vp-vm\current.txt"

$vpUpdate = $vpLatest -ne $vpCurrent
$vmUpdate = $vpVmLatest -ne $vpVmCurrent

if ($vpUpdate) {
    Write-Host "Vocabulary Plus ($vpCurrent -> $vpLatest)" -ForegroundColor Blue
}

if ($vmUpdate) {
    Write-Host "Vocabulary Plus Version Manager ($vpVmCurrent -> $vpVmLatest)" -ForegroundColor Blue
}

if ($vpUpdate -or $vmUpdate) {
    Write-Host "Run 'vp-vm upgrade' to upgrade all packages." -ForegroundColor Magenta
}