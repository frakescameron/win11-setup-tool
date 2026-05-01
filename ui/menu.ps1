do {
    Clear-Host

    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "     Windows 11 Setup Tool" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Install Apps"
    Write-Host "2. Remove Windows Apps"
    Write-Host "3. Exit"
    Write-Host ""

    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "Starting app installer..." -ForegroundColor Cyan
            Write-Host ""

            & "$PSScriptRoot\..\scripts\install-apps.ps1"

            Write-Host ""
            Write-Host "App installer finished." -ForegroundColor Green
            Write-Host "Press Enter to return to the main menu..."
            Read-Host
        }

        "2" {
            Clear-Host
            Write-Host "Starting app remover..." -ForegroundColor Cyan
            Write-Host ""

            & "$PSScriptRoot\..\scripts\remove-apps.ps1"

            Write-Host ""
            Write-Host "App remover finished." -ForegroundColor Green
            Write-Host "Press Enter to return to the main menu..."
            Read-Host
        }

        "3" {
            Clear-Host
            Write-Host "Exiting Windows 11 Setup Tool..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }

        default {
            Write-Host ""
            Write-Host "Invalid option. Please choose 1, 2, or 3." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }

} while ($choice -ne "3")