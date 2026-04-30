Clear-Host

Write-Host "================================="
Write-Host "     Windows 11 Setup Tool"
Write-Host "================================="
Write-Host ""
Write-Host "1. Install Apps"
Write-Host "2. Remove Windows Apps"
Write-Host "3. Exit"
Write-Host ""

$choice = Read-Host "Choose an option"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Starting app installer..."
        .\scripts\install-apps.ps1
    }

    "2" {
        Write-Host ""
        Write-Host "Starting app remover..."
        .\scripts\remove-apps.ps1
    }

    "3" {
        Write-Host "Exiting..."
        exit
    }

    default {
        Write-Host "Invalid option. Please run the tool again."
    }
}