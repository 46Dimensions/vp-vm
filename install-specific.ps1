param(
    [string]$Version
)

$INSTALL_DIR = "$PSScriptRoot"

function Write-Colour($text, $color) {
    Write-Host $text -ForegroundColor $color
}

if (-not $Version) {
    Write-Colour "ERROR: No version specified. Please specify a version to install." Red
    exit 1
}

if ($Version -eq "latest") {
    Write-Colour "Reading package lists..." Yellow
    $VpLatestVersion = (Get-Content "$INSTALL_DIR\versions\vp\latest.txt")
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

Write-Colour "Downloading Vocabulary Plus version ${Version}..." Yellow
$URL = "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/v${VERSION}/install.ps1"
Invoke-WebRequest -Uri $URL -OutFile ".\install.ps1" || { Write-Colour "Version ${Version} cannot be installed." Red; exit 1 }

Write-Colour "Installing Vocabulary Plus version ${Version}..." Yellow
& ".\install.ps1" || { Write-Colour "Failed to install VocabularyPlus." Red; exit 1 }

Write-Colour "Vocabulary Plus version ${Version} installed successfully." Green