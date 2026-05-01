# ==============================
# Windows App Remover
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
$configPath = Join-Path $projectRoot "config\removals.json"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: removals.json not found." -ForegroundColor Red
    return
}

$removalData = Get-Content $configPath | ConvertFrom-Json
$apps = $removalData.apps

$appList = $apps | ForEach-Object {
    [PSCustomObject]@{
        Display        = "$($_.name) [$($_.recommendation)] - $($_.description)"
        Name           = $_.name
        Recommendation = $_.recommendation
        Description    = $_.description
        PackageID      = $_.id
    }
}

Clear-Host
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "       Windows App Remover" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening app selector..." -ForegroundColor Yellow
Write-Host "Click an app to check/uncheck it. No Ctrl needed."
Write-Host ""

$selectedApps = Show-CheckboxPicker -Items $appList -Title "Select Windows apps to remove"

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