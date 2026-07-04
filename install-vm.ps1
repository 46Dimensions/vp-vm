param(
    [string]$InstallDir,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

if (-not $InstallDir) {
    Write-Host "ERROR: Install directory not provided." -ForegroundColor Red
    exit 1
}

function Write-Logo {
    $esc = [char]27
    Write-Host "$esc[38;5;99m🭖█🭀  🭋█🭡   $esc[38;5;171m██████🭏"
    Write-Host "$esc[38;5;105m🭦█🭐  🭅█🭛   $esc[38;5;177m██   🭨█"
    Write-Host "$esc[38;5;141m 🭖█🭀🭋█🭡    $esc[38;5;183m██████🭠"
    Write-Host "$esc[38;5;177m 🭦█🭐🭅█🭛    $esc[38;5;209m██"
    Write-Host "$esc[38;5;209m  🭖██🭡     $esc[38;5;220m██$esc[0m"
    Write-Host "VOCABULARY PLUS"
    Write-Host "Version Manager: Windows Installer (1.1.0)"
    Write-Host ""
}

Write-Logo

$VM_DIR = Join-Path $InstallDir "vm"
$BIN = "$env:USERPROFILE\bin"
Add-ToUserPath $BIN

if (-not $Silent) {
    Write-Host "Installing Vocabulary Plus Version Manager..." -ForegroundColor Cyan
}

if (-not $Silent) {
    Write-Host "Creating directories..." -ForegroundColor Cyan
}
New-Item -ItemType Directory -Force -Path $VM_DIR | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp" | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp-vm" | Out-Null

# Download scripts
if (-not $silent) {
    Write-Host "Downloading files..." -ForegroundColor Cyan
}

$base = "https://raw.githubusercontent.com/46Dimensions/vp-vm/1.1.0"

$files = @(
    "vp-vm.ps1",
    "update-versions.ps1",
    "upgrade.ps1",
    "list-upgradable.ps1",
    "uninstall.ps1"
)

foreach ($f in $files) {
    if (-not $silent) {
        Write-Host "- Downloading $f..." -ForegroundColor Cyan
    }
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $VM_DIR $f)
}

# Create launcher
if (-not $silent) {
    Write-Host "Creating launcher..." -ForegroundColor Cyan
}

New-Item -ItemType Directory -Force -Path $BIN | Out-Null
$launcher = Join-Path $BIN "vp-vm.ps1"

@"
`$env:INSTALL_DIR = "$VM_DIR"
& "$VM_DIR\vp-vm.ps1" `$args
"@ | Set-Content $launcher

if (-not $silent) {
    Write-Host "Writing current version file..." -ForegroundColor Cyan
    Set-Content "$VM_DIR\versions\vp-vm\current.txt" "1.1.0"
}

if (-not $Silent) {
    Write-Host "Installation complete." -ForegroundColor Green
}

function Add-ToUserPath {
    param([string]$NewPath)

    $current = [Environment]::GetEnvironmentVariable("PATH", "User")

    if (-not $current) { $current = "" }

    $paths = $current -split ";" | Where-Object { $_ -ne "" }

    if ($paths -contains $NewPath) {
        Write-Host "PATH already contains: $NewPath" -ForegroundColor DarkGray
        return
    }

    $newPathValue = ($paths + $NewPath) -join ";"

    [Environment]::SetEnvironmentVariable("PATH", $newPathValue, "User")

    # Also update current session immediately
    $env:PATH = $newPathValue

    Write-Host "Added to PATH: $NewPath" -ForegroundColor Green
}