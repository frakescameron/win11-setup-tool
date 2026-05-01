# ==============================
# Windows 11 Setup Tool Launcher
# ==============================

# Force PowerShell 5+ compatibility
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell 5 or newer is required." -ForegroundColor Red
    pause
    exit
}

# Relaunch as admin if needed
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    exit
}

# Allow script execution for this PowerShell session only
Set-ExecutionPolicy Bypass -Scope Process -Force

# Set project root
# Set project root
if ($PSScriptRoot) {
    $scriptRoot = $PSScriptRoot
}
elseif ($PSCommandPath) {
    $scriptRoot = Split-Path -Parent $PSCommandPath
}
else {
    $scriptRoot = [System.AppDomain]::CurrentDomain.BaseDirectory
}

Set-Location $scriptRoot


# Create logs folder if missing
$logsPath = Join-Path $scriptRoot "logs"
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath | Out-Null
}

# Start transcript log
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = Join-Path $logsPath "run_$timestamp.log"

Start-Transcript -Path $logFile -Append | Out-Null

try {
    Clear-Host
    Write-Host "Starting Windows 11 Setup Tool..." -ForegroundColor Cyan

    $menuPath = Join-Path $scriptRoot "ui\menu.ps1"

    if (-not (Test-Path $menuPath)) {
        Write-Host "ERROR: Could not find ui\menu.ps1" -ForegroundColor Red
        pause
        exit
    }

    & $menuPath
}
catch {
    Write-Host ""
    Write-Host "An error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    pause
}
finally {
    Stop-Transcript | Out-Null
}