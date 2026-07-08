param(
    [string]$InstallDir,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

function Write-Colour($text, $colour) {
    if ($Silent) { return }
    Write-Host $text -ForegroundColor $colour
}

if (-not $InstallDir) {
    Write-Colour "ERROR: Install directory not provided." Red
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
    Write-Host "Version Manager: Windows Installer (1.2.2)"
    Write-Host ""
}

if (-not $Silent) {
    Write-Logo
}

function Add-ToUserPath {
    param([string]$NewPath)

    $current = [Environment]::GetEnvironmentVariable("PATH", "User")

    if (-not $current) { $current = "" }

    $paths = $current -split ";" | Where-Object { $_ -ne "" }

    if ($paths -contains $NewPath) {
        Write-Colour "PATH already contains: $NewPath" DarkGray
        return
    }

    $newPathValue = ($paths + $NewPath) -join ";"

    [Environment]::SetEnvironmentVariable("PATH", $newPathValue, "User")

    # Also update current session immediately
    $env:PATH = $newPathValue

    Write-Colour "Added to PATH: $NewPath" Green
}

$VM_DIR = Join-Path $InstallDir "vm"
$BIN = "$env:USERPROFILE\bin"
Add-ToUserPath $BIN

Write-Colour "Installing Vocabulary Plus Version Manager..." Cyan

Write-Colour "Creating directories..." Cyan
New-Item -ItemType Directory -Force -Path $VM_DIR | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp" | Out-Null
New-Item -ItemType Directory -Force -Path "$VM_DIR\versions\vp-vm" | Out-Null

# Download scripts
Write-Colour "Downloading files..." Cyan

$base = "https://raw.githubusercontent.com/46Dimensions/vp-vm/v1.2.2"

$files = @(
    "vp-vm.ps1",
    "update-versions.ps1",
    "upgrade.ps1",
    "list-upgradable.ps1",
    "uninstall.ps1"
    "LICENSE"
)

foreach ($f in $files) {
    Write-Colour "- Downloading $f..." Cyan
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $VM_DIR $f)
}

# Create launcher
Write-Colour "Creating launcher..." Cyan

New-Item -ItemType Directory -Force -Path $BIN | Out-Null
$launcher = Join-Path $BIN "vp-vm.ps1"

@"
`$env:INSTALL_DIR = "$VM_DIR"
& "$VM_DIR\vp-vm.ps1" `$args
"@ | Set-Content $launcher

Write-Colour "Writing current version file..." Cyan
Set-Content "$VM_DIR\versions\vp-vm\current.txt" "1.2.2"

Write-Colour "Installation complete." Green
exit 0