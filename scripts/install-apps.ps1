# ==============================
# App Installer
# ==============================

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$configPath = Join-Path $projectRoot "config\apps.json"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: apps.json not found." -ForegroundColor Red
    return
}

$apps = Get-Content $configPath | ConvertFrom-Json

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "          App Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: winget is not installed or not available." -ForegroundColor Red
    Write-Host "Install/update App Installer from the Microsoft Store, then try again."
    return
}

Write-Host "Opening app selector..." -ForegroundColor Yellow
Write-Host "Select the apps you want to install, then click OK."
Write-Host ""

$appList = $apps | ForEach-Object {
    [PSCustomObject]@{
        Name      = $_.name
        PackageID = $_.id
    }
}

try {
    $selectedApps = $appList | Out-GridView -Title "Select apps to install" -PassThru
}
catch {
    Write-Host "Out-GridView is not available. Falling back to numbered selection." -ForegroundColor Yellow
    Write-Host ""

    for ($i = 0; $i -lt $appList.Count; $i++) {
        Write-Host "$($i + 1). $($appList[$i].Name)"
    }

    Write-Host ""
    $selection = Read-Host "Type app numbers to install. Example: 1,3,5"

    $selectedApps = @()

    $selection -split "," | ForEach-Object {
        $number = $_.Trim()

        if ($number -match '^\d+$') {
            $index = [int]$number - 1

            if ($index -ge 0 -and $index -lt $appList.Count) {
                $selectedApps += $appList[$index]
            }
        }
    }
}

if (-not $selectedApps -or $selectedApps.Count -eq 0) {
    Write-Host ""
    Write-Host "No apps selected. Nothing was installed." -ForegroundColor Yellow
    return
}

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "       Confirm Installation" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "The following apps will be installed:" -ForegroundColor Yellow
Write-Host ""

$selectedApps | ForEach-Object {
    Write-Host "- $($_.Name)"
}

Write-Host ""
$confirm = Read-Host "Type YES to continue"

if ($confirm -ne "YES") {
    Write-Host ""
    Write-Host "Installation canceled." -ForegroundColor Yellow
    return
}

foreach ($app in $selectedApps) {
    Write-Host ""
    Write-Host "Installing $($app.Name)..." -ForegroundColor Cyan

    try {
        winget install `
            --id $app.PackageID `
            -e `
            --accept-source-agreements `
            --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Finished: $($app.Name)" -ForegroundColor Green
        }
        else {
            Write-Host "winget reported an issue installing: $($app.Name)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to install: $($app.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Selected app installation finished." -ForegroundColor Green