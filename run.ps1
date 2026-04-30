# Allow script execution for this session
Set-ExecutionPolicy Bypass -Scope Process -Force

# Get script root so paths always work correctly
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptRoot

# Run main menu
.\ui\menu.ps1