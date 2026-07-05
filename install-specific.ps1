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
}