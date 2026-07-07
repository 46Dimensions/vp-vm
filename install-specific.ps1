param(
    [string]$Version
)

$InstallDir = "$PSScriptRoot" # ...\VocabularyPlus\vm
$BinDir = Get-Content "$InstallDir\..\bin_dir.txt" # ...\VocabularyPlus\bin_dir.txt

function Write-Colour($text, $color) {
    Write-Host $text -ForegroundColor $color
}

if (-not $Version) {
    Write-Colour "ERROR: No version specified. Please specify a version to install." Red
    exit 1
}

if ($Version -eq "latest") {
    Write-Colour "Reading package lists..." Yellow
    $VpLatestVersion = (Get-Content "$InstallDir\versions\vp\latest.txt") || Write-Colour "Unable to get latest version. Run 'vp-vm update' to load latest version." Yellow
    $Version = $VPLatestVersion
}

if ($Version.StartsWith("v")) {
    $Version = $Version.TrimStart("v")
}

if ($Version -eq "1.1.0") {
    $Version = "1.1"
}

$invalidVersions = @("1.0.0", "1.0.1", "1.1", "1.2.0", "1.2.1", "1.3.0-beta", "1.3.0", "1.3.1", "1.4.0")

if ($invalidVersions -contains $Version) {
    Write-Colour "Version $Version cannot be installed on Windows. Please choose release 1.5.0 or later."
    exit 1
}

if (Test-Path "$InstallDir") {
    Write-Colour "Backing up vocabulary files..." Yellow
    Set-Location "$InstallDir" # Move into VocabularyPlus\vm
    Set-Location .. cd .. # Move into VocabularyPlus directory
    Set-Location .. # Move into VocabularyPlus's parent directory
    New-Item -ItemType Directory -Force -Path "VocabularyPlusTemp"
    Move-Item -Path "VocabularyPlus\JSON" -Destination "VocabularyPlusTemp\JSON"
    Move-Item -Path "$InstallDir" -Destination "VocabularyPlusTemp\vm"
    Write-Colour "Backup complete." Green
    
    Start-Sleep -Seconds 1

    Write-Host ""
    Write-Colour "Uninstalling current Vocabulary Plus version..." Yellow
    # Run the VocabularyPlus uninstaller
    vocabularyplus uninstall -Silent || { Write-Colour "Attempting manual uninstall..." Yellow; Remove-Item -Recurse -Force "VocabularyPlus"; Remove-Item -Force $BinDir\vocabularyplus.ps1'; Remove-Item -Force $BinDir\vp.ps1'; }
    Write-Colour "Current Vocabulary Plus version uninstalled." Green
    Start-Sleep -Seconds 1
}

Write-Host ""

Write-Colour "Installing Vocabulary Plus version $Version..." Yellow
# Download the installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v${VERSION}/install.ps1" -OutFile install.ps1

# Run the script
& .\install.ps1 -Silent
# Abort if the installation fails
if ($LASTEXITCODE -ne 0) {
    Write-Colour "Installation failed." Red
    Remove-Item install.ps1 -ErrorAction SilentlyContinue
    exit 1
}
# Remove the install script after installation
Remove-Item install.ps1

Start-Sleep -Seconds 1

if (Test-Path "VocabularyPlusTemp") {
    if (Test-Path "VocabularyPlus") {
        $VocabularyPlusPath = "VocabularyPlus"
    }
    elseif (Test-Path "${HOME}\VocabularyPlus") {
        $VocabularyPlusPath = "${HOME}\VocabularyPlus"
    }
    else {
        Write-Colour "Unable to find VocabularyPlus directory for restoring backup." Red
        $VocabularyPlusPath = "UNKNOWN"
    }
    
    Write-Colour "Restoring vocabulary files..." Yellow

    # Remove newly installed JSON and vm directories if they and the backups exist
    if (Test-Path "${VocabularyPlusPath}\JSON" -and Test-Path "VocabularyPlusTemp\JSON") {
        Remove-Item -Recurse -Force "${VocabularyPlusPath}\JSON"
    }

    if (Test-Path "${VocabularyPlusPath}\vm" -and Test-Path "VocabularyPlusTemp\vm") {
        Remove-Item -Recurse -Force "${VocabularyPlusPath}\vm"
    }

    Move-Item -Path "VocabularyPlusTemp\JSON" - Destination "${VocabularyPlusPath}\JSON" || Write-Colour "WARNING: ${PWD.Path}\VocabularyPlusTemp\JSON not found so not backed up." Yellow
    Move-Item -Path "VocabularyPlusTemp\vm" -Destination "${VocabularyPlusPath}\vm" || { Write-Colour "ERROR: ${PWD.Path}\VocabularyPlusTemp\vm not found so not backed up." Red; exit 1; }
    Remove-Item -Recurse -Force "VocabularyPlusTemp"
}

Write-Colour "Vocabulary Plus version ${VERSION} installed successfully." Green