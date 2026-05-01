# ==============================
# Windows App Remover
# ==============================

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$configPath = Join-Path $projectRoot "config\removals.json"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: removals.json not found." -ForegroundColor Red
    return
}

$removalData = Get-Content $configPath | ConvertFrom-Json
$apps = $removalData.apps

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "       Windows App Remover" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Opening app selector..." -ForegroundColor Yellow
Write-Host "Check/select the apps you want to remove, then click OK."
Write-Host ""

# Build UI-friendly list
$appList = $apps | ForEach-Object {
    [PSCustomObject]@{
        Name           = $_.name
        Recommendation = $_.recommendation
        Description    = $_.description
        PackageID      = $_.id
    }
}

# Try GUI selector first
try {
    $selectedApps = $appList | Out-GridView -Title "Select Windows apps to remove" -PassThru
}
catch {
    Write-Host "Out-GridView is not available on this system." -ForegroundColor Yellow
    Write-Host "Falling back to numbered selection."
    Write-Host ""

    for ($i = 0; $i -lt $appList.Count; $i++) {
        Write-Host "$($i + 1). $($appList[$i].Name) [$($appList[$i].Recommendation)]"
        Write-Host "   $($appList[$i].Description)"
    }

    Write-Host ""
    $selection = Read-Host "Type app numbers to remove. Example: 1,3,5"

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
    Write-Host "No apps selected. Nothing was removed." -ForegroundColor Yellow
    return
}

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "       Confirm Removal" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "The following apps will be removed:" -ForegroundColor Yellow
Write-Host ""

$selectedApps | ForEach-Object {
    Write-Host "- $($_.Name) [$($_.Recommendation)]"
}

Write-Host ""
Write-Host "Apps marked unsafe may break normal Windows features." -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Type YES to continue"

if ($confirm -ne "YES") {
    Write-Host ""
    Write-Host "Removal canceled." -ForegroundColor Yellow
    return
}

foreach ($app in $selectedApps) {
    Write-Host ""
    Write-Host "Removing $($app.Name)..." -ForegroundColor Cyan

    try {
        Get-AppxPackage -Name $app.PackageID -AllUsers |
            Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

        Get-AppxProvisionedPackage -Online |
            Where-Object DisplayName -eq $app.PackageID |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

        Write-Host "Finished: $($app.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to remove: $($app.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Selected app removal finished." -ForegroundColor Green