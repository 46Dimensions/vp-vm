$ErrorActionPreference = "Stop"

$cmd = $args[0]

switch ($cmd) {
    "update" { & "$env:INSTALL_DIR\update-versions.ps1" }
    "upgrade" { & "$env:INSTALL_DIR\upgrade.ps1" }
    "list-upgradable" { & "$env:INSTALL_DIR\list-upgradable.ps1" }
    "--version" { Write-Host "1.0.0" }
    "--help" {
        Write-Host "Vocabulary Plus Version Manager" -ForegroundColor Cyan
        Write-Host "   A tool to update Vocabulary Plus" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "   update            Update the version lists"
        Write-Host "   upgrade           Upgrade Vocabulary Plus and vp-vm to the latest version"
        Write-Host "   list-upgradable   Show upgradable packages"
        Write-Host "   --version         Show the installed version of Vocabulary Plus Version Manager"
        Write-Host "   --help            Show this help message and exit"
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