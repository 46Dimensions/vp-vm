param(
    [switch]$Silent
)

$dir = $env:INSTALL_DIR

if (-not $dir) {
    Write-Host "ERROR: INSTALL_DIR not set." -ForegroundColor Red
    exit 1
}

function Log($msg, $color = "White") {
    if (-not $Silent) {
        Write-Host $msg -ForegroundColor $color
    }
}

Log "Removing vm directory..." Yellow

if ((Get-Location).Path -eq $dir) {
    Set-Location ..
}

Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue

Log "Directory removed" Green

Log "Removing control script..." Yellow
Remove-Item "$env:USERPROFILE\bin\vp-vm.ps1" -Force -ErrorAction SilentlyContinue

Log "Control script removed." Green

Log "Uninstallation complete." Green