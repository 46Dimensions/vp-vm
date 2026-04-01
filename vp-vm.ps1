$ErrorActionPreference = "Stop"

$cmd = $args[0]

switch ($cmd) {
    "update" { & "$env:INSTALL_DIR\update-versions.ps1" }
    "upgrade" { & "$env:INSTALL_DIR\upgrade.ps1" }
    "list-upgradable" { & "$env:INSTALL_DIR\list-upgradable.ps1" }
    "--version" { Write-Host "1.0.0" }
    "--help" {
        Write-Host "Vocabulary Plus Version Manager"
        Write-Host "   A tool to update Vocabulary Plus"
        Write-Host ""
        Write-Host "Usage: vp-vm <command>"
        Write-Host "Commands:"
        Write-Host "  update"
        Write-Host "  upgrade"
        Write-Host "  list-upgradable"
        Write-Host "  --version"
        Write-Host "  --help"
    }
    default {
        if (-not $cmd) {
            Write-Host "Error: No command specified." -ForegroundColor Red
            Write-Host "See 'vp-vm --help' for more information."
        }
        else {
            Write-Host "Unknown command $cmd." -ForegroundColor Red
        }
    }
}