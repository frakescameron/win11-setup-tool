# Load apps from JSON
$apps = Get-Content ".\config\apps.json" | ConvertFrom-Json

Clear-Host
Write-Host "================================="
Write-Host "          App Installer"
Write-Host "================================="
Write-Host ""

for ($i = 0; $i -lt $apps.Count; $i++) {
    Write-Host "$($i + 1). $($apps[$i].name)"
}

Write-Host ""
Write-Host "Type the numbers of the apps you want to install."
Write-Host "Example: 1,3,5,8"
Write-Host ""

$selection = Read-Host "Apps to install"

$selectedNumbers = $selection -split "," | ForEach-Object {
    $_.Trim()
}

foreach ($number in $selectedNumbers) {
    if ($number -match '^\d+$') {
        $index = [int]$number - 1

        if ($index -ge 0 -and $index -lt $apps.Count) {
            $app = $apps[$index]

            Write-Host ""
            Write-Host "Installing $($app.name)..."

            winget install `
                --id $app.id `
                -e `
                --accept-source-agreements `
                --accept-package-agreements
        }
        else {
            Write-Host "Invalid number: $number"
        }
    }
    else {
        Write-Host "Invalid input: $number"
    }
}

Write-Host ""
Write-Host "Selected app installation finished."