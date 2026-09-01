param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# --- Colours ---
function Write-Colour {
    param(
        [string]$Text,
        [System.ConsoleColor]$Colour
    )

    if (-not $Silent) {
        Write-Host $text -ForegroundColor $colour
    }
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
    Write-Host "Version Manager: Windows Installation (2.0.0)"
    Write-Host ""
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

# Set global variables
$BASE_URL = "https://raw.githubusercontent.com/46Dimensions/vp-vm/2.0.0"
$VM_DIR = Join-Path $HOME ".vp-vm"
$INSTALL_DIR = Join-Path $VM_DIR "scripts"
$BIN_DIR = Join-Path $env:USERPROFILE "AppData" "Local" "Programs" "VocabularyPlus"

# Create directories
New-Item -ItemType Directory -Path "$VM_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$INSTALL_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$BIN_DIR" -Force | Out-Null

# Add bin directory to user's PATH
Add-ToUserPath -NewPath "$BIN_DIR"

function Get-File {
    param(
        [string]$RemotePath
    )
    Write-Colour "- Downloading $RemotePath..." Cyan

    $Url = "$BASE_URL/$RemotePath"
    $OutPath = "$INSTALL_DIR/$RemotePath"

    Invoke-WebRequest -Uri $Url -OutFile $OutPath || { Write-Error "Unable to download $RemotePath"; exit 1; }
}

Write-Colour "Downloading files..." Cyan
Get-File -RemotePath "vp-vm.ps1"
Get-File -RemotePath "LICENSE"
Get-File -RemotePath "README.md"
Write-Colour "Downloaded files successfully." Green

Write-Colour "Setting up launchers..." Cyan

Write-Colour "- VP VM launcher" Cyan
$vm_launcher_path = "$BIN_DIR\vp-vm.ps1"
@"
& "$INSTALL_DIR\vp-vm.ps1 @args
exit `$LASTEXITCODE
"@ | Set-Content $vm_launcher_path

Write-Colour "- Vocabulary Plus launcher" Cyan
$vocabularyplus_launcher_path = "$BIN_DIR\vocabularyplus.ps1"
@"
& "$VM_DIR\versions\`$(Get-Content "$VM_DIR\current.txt")"
exit `$LASTEXITCODE
"@ | Set-Content $vocabularyplus_launcher_path

Write-Colour "- Vocabulary Plus launcher alias" Cyan
$vp_launcher_path = "$BIN_DIR\vp.ps1"
Copy-File $vocabularyplus_launcher_path $vp_launcher_path

Write-Colour "Launchers set up." Green

Write-Colour "Creating required files..." Cyan
Set-Content -Path "$VM_DIR\version.txt" -Value "2.0.0"

Write-Colour "Successfully installed Vocabulary Plus Version Manager 2.0.0"
Write-Host ""
Write-Colour "Instructions and Help:" Blue
Write-Colour "$BIN_DIR/vp-vm --help" Blue
Write-Colour "$INSTALL_DIR/README.md" Blue
Write-Colour "https://github.com/46Dimensions/vp-vm/blob/2.0.0/README.md" Blue