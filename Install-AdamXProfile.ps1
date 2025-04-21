<#
.SYNOPSIS
    Installs Adam-x to your PowerShell profile
.DESCRIPTION
    This script adds Adam-x to your PowerShell profile so you can use it from any PowerShell window
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

# Create the profile directory if it doesn't exist
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Host "Created profile directory: $profileDir" -ForegroundColor Green
}

# Check if the profile file exists, create it if it doesn't
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "Created PowerShell profile: $PROFILE" -ForegroundColor Green
}

# Check if Adam-x is already in the profile
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -match "Adam-x") {
    Write-Host "Adam-x is already in your PowerShell profile." -ForegroundColor Yellow
    exit 0
}

# Add Adam-x to the profile
$adamXProfileContent = @"

# Adam-x AI Coding Assistant
function adam-x {
    & "$adamXPath"
}

Write-Host "Adam-x is available. Type 'adam-x' to start." -ForegroundColor Cyan
"@

Add-Content -Path $PROFILE -Value $adamXProfileContent

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

Adam-x has been added to your PowerShell profile!

You can now use Adam-x from any PowerShell window by typing:
adam-x

To activate the changes in your current session, run:
. $PROFILE

"@ -ForegroundColor Cyan
