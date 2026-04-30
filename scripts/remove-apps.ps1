# Load removable apps from JSON
$removalData = Get-Content ".\config\removals.json" | ConvertFrom-Json
$apps = $removalData.apps

Clear-Host
Write-Host "================================="
Write-Host "       Windows App Remover"
Write-Host "================================="
Write-Host ""

for ($i = 0; $i -lt $apps.Count; $i++) {
    Write-Host "$($i + 1). $($apps[$i].name) [$($apps[$i].recommendation)]"
    Write-Host "   $($apps[$i].description)"
}

Write-Host ""
Write-Host "Type the numbers of the apps you want to remove."
Write-Host "Example: 1,3,5,8"
Write-Host ""
Write-Host "Avoid removing apps marked [unsafe] unless you know why."
Write-Host ""

$selection = Read-Host "Apps to remove"

$selectedNumbers = $selection -split "," | ForEach-Object {
    $_.Trim()
}

foreach ($number in $selectedNumbers) {
    if ($number -match '^\d+$') {
        $index = [int]$number - 1

        if ($index -ge 0 -and $index -lt $apps.Count) {
            $app = $apps[$index]

            Write-Host ""
            Write-Host "Removing $($app.name)..."

            Get-AppxPackage -Name $app.id -AllUsers |
                Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

            Get-AppxProvisionedPackage -Online |
                Where-Object DisplayName -eq $app.id |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
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
Write-Host "Selected app removal finished."