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
    Write-Host "Vocabulary Plus (" -NoNewline
    Write-Host "$vpCurrent" -NoNewline -ForegroundColor Red
    Write-Host  " -> " -NoNewline
    Write-Host "$vpLatest" -NoNewline -ForegroundColor Green
    Write-Host ")"
}

if ($vmUpdate) {
    Write-Host "Vocabulary Plus Version Manager (" -NoNewline
    Write-Host "$vpVmCurrent" -NoNewline -ForegroundColor Red
    Write-Host  " -> " -NoNewline
    Write-Host "$vpVmLatest" -NoNewline -ForegroundColor Green
    Write-Host ")"
}

if ($vpUpdate -or $vmUpdate) {
    Write-Host "Run 'vp-vm upgrade' to upgrade all packages." -ForegroundColor Magenta
}