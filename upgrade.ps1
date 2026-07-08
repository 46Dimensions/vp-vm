$ErrorActionPreference = "Stop"

$dir = $env:INSTALL_DIR

function Read($p) { (Get-Content $p).Trim() }

$vpCur = Read "$dir\versions\vp\current.txt"
$vpLat = Read "$dir\versions\vp\latest.txt"

$vmCur = Read "$dir\versions\vp-vm\current.txt"
$vmLat = Read "$dir\versions\vp-vm\latest.txt"

$upgradeVP = $vpCur -ne $vpLat
$upgradeVM = $vmCur -ne $vmLat

if ($upgradeVP) {
    Write-Host "Upgrading Vocabulary Plus..." -ForegroundColor Yellow

    $temp = "$env:TEMP\vp_backup"
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $temp | Out-Null

    Move-Item "$PWD\VocabularyPlus\JSON" $temp -ErrorAction SilentlyContinue
    Move-Item "$PWD\VocabularyPlus\vm" $temp -ErrorAction SilentlyContinue

    vocabularyplus uninstall -Silent true

    Invoke-WebRequest "https://raw.githubusercontent.com/46Dimensions/VocabularyPlus/main/install.ps1" -OutFile install.ps1
    powershell -ExecutionPolicy Bypass -File install.ps1
    Remove-Item install.ps1

    Remove-Item "$PWD\VocabularyPlus\JSON" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$PWD\VocabularyPlus\vm" -Recurse -Force -ErrorAction SilentlyContinue

    Move-Item "$temp\*" "$PWD\VocabularyPlus\" -Force
    Remove-Item $temp -Recurse

    $vpLat | Set-Content "$dir\versions\vp\current.txt"
}

if ($upgradeVM) {
    Write-Host "Upgrading VP VM..." -ForegroundColor Yellow

    & "$dir\uninstall.ps1" -Silent true

    Invoke-WebRequest "https://raw.githubusercontent.com/46Dimensions/vp-vm/1.2.2/install-vm.ps1" -OutFile install-vm.ps1
    powershell -ExecutionPolicy Bypass -File install-vm.ps1 $dir -Silent
    Remove-Item install-vm.ps1

    $vmLat | Set-Content "$dir\versions\vp-vm\current.txt"
}

Write-Host "Upgrade complete." -ForegroundColor Green