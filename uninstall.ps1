param(
    [string]$InstallDir,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

if (-not $InstallDir) {
    Write-Host "ERROR: Install directory not provided." -ForegroundColor Red
    exit 1
}

$VM_DIR = Join-Path $InstallDir "vm"
$BIN = "$env:USERPROFILE\bin"

if (-not $Silent) {
    Write-Host "Installing Vocabulary Plus Version Manager..." -ForegroundColor Cyan
}

New-Item -ItemType Directory -Force -Path $VM_DIR | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp" | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp-vm" | Out-Null

# Download scripts
$base = "https://raw.githubusercontent.com/46Dimensions/vp-vm/main"

$files = @(
    "vp-vm.ps1",
    "update-versions.ps1",
    "upgrade.ps1",
    "list-upgradable.ps1",
    "uninstall.ps1"
)

foreach ($f in $files) {
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $VM_DIR $f)
}

# Create launcher
New-Item -ItemType Directory -Force -Path $BIN | Out-Null
$launcher = Join-Path $BIN "vp-vm.ps1"

@"
`$env:INSTALL_DIR = "$VM_DIR"
& "$VM_DIR\vp-vm.ps1" `$args
"@ | Set-Content $launcher

if (-not $Silent) {
    Write-Host "Installation complete." -ForegroundColor Green
}