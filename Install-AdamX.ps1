<#
.SYNOPSIS
    Installs Adam-x AI coding assistant for global access in PowerShell
.DESCRIPTION
    This script installs the Adam-x AI coding assistant by adding it to your PowerShell profile,
    making it accessible from any PowerShell terminal.
.NOTES
    Version:        1.0
    Author:         AI Assistant
    Creation Date:  $(Get-Date -Format "yyyy-MM-dd")
#>

# Get the current directory where Adam-x is installed
$adamXDirectory = $PSScriptRoot
$adamXPath = Join-Path $adamXDirectory "Adam-x.ps1"

# Check if Adam-x.ps1 exists
if (-not (Test-Path $adamXPath)) {
    Write-Host "Error: Adam-x.ps1 not found in the current directory." -ForegroundColor Red
    exit 1
}

# Create PowerShell profile directory if it doesn't exist
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Host "Created PowerShell profile directory: $profileDir" -ForegroundColor Green
}

# Check if profile exists, create if it doesn't
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Created PowerShell profile: $PROFILE" -ForegroundColor Green
}

# Add Adam-x to the profile
$adamXFunction = @"

# Adam-x AI Coding Assistant
function adam-x {
    & "$adamXPath" @args
}
"@

# Check if Adam-x is already in the profile
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent.Contains("Adam-x AI Coding Assistant")) {
    Write-Host "Adam-x is already installed in your PowerShell profile." -ForegroundColor Yellow
}
else {
    Add-Content -Path $PROFILE -Value $adamXFunction
    Write-Host "Adam-x has been added to your PowerShell profile." -ForegroundColor Green
}

Write-Host @"

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   █████╗ ██████╗  █████╗ ███╗   ███╗      ██╗  ██╗           ║
║  ██╔══██╗██╔══██╗██╔══██╗████╗ ████║      ╚██╗██╔╝           ║
║  ███████║██║  ██║███████║██╔████╔██║       ╚███╔╝            ║
║  ██╔══██║██║  ██║██╔══██║██║╚██╔╝██║       ██╔██╗            ║
║  ██║  ██║██████╔╝██║  ██║██║ ╚═╝ ██║██╗    ██╔╝ ██╗          ║
║  ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝    ╚═╝  ╚═╝          ║
║                                                               ║
║   PhD-Level AI Coding Assistant                               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Installation Complete!

To start using Adam-x, either:
1. Restart your PowerShell terminal, or
2. Run: . $PROFILE to reload your profile

Then you can use Adam-x by typing 'adam-x' in any PowerShell terminal.

"@ -ForegroundColor Cyan
