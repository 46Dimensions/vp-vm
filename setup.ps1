# Setup script: configures 

param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# --- Colours ---
function Write-Colour($text, $colour) {
    if ($Silent) { return }
    Write-Host $text -ForegroundColor $colour
}

function Write-Logo {
    $esc = [char]27
    Write-Host "$esc[38;5;99m🭖█🭀  🭋█🭡   $esc[38;5;171m██████🭏"
    Write-Host "$esc[38;5;105m🭦█🭐  🭅█🭛   $esc[38;5;177m██   🭨█"
    Write-Host "$esc[38;5;141m 🭖█🭀🭋█🭡    $esc[38;5;183m██████🭠"
    Write-Host "$esc[38;5;177m 🭦█🭐🭅█🭛    $esc[38;5;209m██"
    Write-Host "$esc[38;5;209m  🭖██🭡     $esc[38;5;220m██$esc[0m"
    Write-Host "VOCABULARY PLUS"
    Write-Host "Version Manager: Windows Setup (2.0.0)"
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

    # Update current session
    if ($env:PATH -notlike "*$NewPath*") {
        $env:PATH += ";$NewPath"
    }

    Write-Colour "Added to PATH: $NewPath" Green
}

$VM_DIR = $PSScriptRoot
$BIN = "$env:USERPROFILE\AppData\Local\Programs\VocabularyPlus"

Write-Colour "Setting up Vocabulary Plus Version Manager..." Cyan

Write-Colour "Modifying PATH..." Cyan
# Add $BIN to PATH
Add-ToUserPath $BIN

# Create launcher
Write-Colour "Creating launcher..." Cyan

New-Item -ItemType Directory -Force -Path $BIN | Out-Null
$launcher = Join-Path $BIN "vp-vm.ps1"

@"
`$env:INSTALL_DIR = "$VM_DIR"
& "$VM_DIR\vp-vm.ps1" `$args
"@ | Set-Content $launcher

Write-Colour "Setup complete." Green
Write-Colour "For instructions on how to use the Version Manager, please see https://github.com/46Dimensions/vp-vm"
exit 0