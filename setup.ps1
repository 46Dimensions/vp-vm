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
    $purple = "$esc[38;5;93m"
    $orange = "$esc[38;5;208m"

    Write-Host "${purple}🭖█🭀  🭋█🭡   ${orange}██████🭏"
    Write-Host "${purple}🭦█🭐  🭅█🭛   ${orange}██   🭨█"
    Write-Host "${purple} 🭖█🭀🭋█🭡    ${orange}██████🭠"
    Write-Host "${purple} 🭦█🭐🭅█🭛    ${orange}██"
    Write-Host "${purple}  🭖██🭡     ${orange}██${reset}"
    Write-Host "VOCABULARY PLUS"
    Write-Host "Version Manager: Windows (2.0.0)"
    Write-Host ""
}

if (-not $Silent) {
    Write-Logo
}

# Check if running on Windows
if (-not $env:OS -eq 'Windows_NT') {
    Write-Colour "Not running on Windows." Red
    exit 1
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
Write-Colour "For instructions on how to use the Version Manager, please see https://github.com/46Dimensions/vp-vm" White
exit 0