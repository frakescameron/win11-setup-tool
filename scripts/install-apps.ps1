# ==============================
# App Installer
# ==============================

function Show-CheckboxPicker {
    param (
        [array]$Items,
        [string]$Title = "Select Items"
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true

    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Location = New-Object System.Drawing.Point(10, 10)
    $checkedListBox.Size = New-Object System.Drawing.Size(660, 390)
    $checkedListBox.CheckOnClick = $true
    $checkedListBox.DisplayMember = "Display"

    foreach ($item in $Items) {
        [void]$checkedListBox.Items.Add($item)
    }

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(470, 415)
    $okButton.Size = New-Object System.Drawing.Size(90, 35)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(580, 415)
    $cancelButton.Size = New-Object System.Drawing.Size(90, 35)

    $okButton.Add_Click({
        $form.Tag = "OK"
        $form.Close()
    })

    $cancelButton.Add_Click({
        $form.Tag = "Cancel"
        $form.Close()
    })

    $form.Controls.Add($checkedListBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    [void]$form.ShowDialog()

    if ($form.Tag -ne "OK") {
        return @()
    }

    return @($checkedListBox.CheckedItems)
}

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$configPath = Join-Path $projectRoot "config\apps.json"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: apps.json not found." -ForegroundColor Red
    return
}

$apps = Get-Content $configPath | ConvertFrom-Json

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: winget is not installed or not available." -ForegroundColor Red
    Write-Host "Install/update App Installer from the Microsoft Store, then try again."
    return
}

$appList = $apps | ForEach-Object {
    [PSCustomObject]@{
        Display   = "$($_.name) - $($_.id)"
        Name      = $_.name
        PackageID = $_.id
    }
}

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "          App Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening app selector..." -ForegroundColor Yellow
Write-Host "Click an app to check/uncheck it. No Ctrl needed."
Write-Host ""

$selectedApps = Show-CheckboxPicker -Items $appList -Title "Select apps to install"

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

$total = $selectedApps.Count
$count = 1

foreach ($app in $selectedApps) {
    Clear-Host
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "        Installing Apps" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Progress: $count / $total" -ForegroundColor Yellow
    Write-Host "Installing: $($app.Name)" -ForegroundColor Cyan
    Write-Host ""

    try {
        winget install `
            --id $app.PackageID `
            -e `
            --accept-source-agreements `
            --accept-package-agreements `
            --silent `
            --disable-interactivity `
            *> $null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Finished: $($app.Name)" -ForegroundColor Green
        }
        else {
            Write-Host "Issue installing: $($app.Name)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed: $($app.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }

    Start-Sleep -Milliseconds 500
    $count++
}

Write-Host ""
Write-Host "Selected app installation finished." -ForegroundColor Green