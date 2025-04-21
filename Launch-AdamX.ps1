<#
.SYNOPSIS
    Launches Adam-x AI Coding Assistant
.DESCRIPTION
    This script launches Adam-x directly without requiring module import
.NOTES
    Version:        1.0
    Author:         AI Assistant
    Creation Date:  $(Get-Date -Format "yyyy-MM-dd")
#>

# Get the directory where this script is located
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$adamXPath = Join-Path $scriptDirectory "Adam-x.ps1"

# Check if Adam-x.ps1 exists
if (-not (Test-Path $adamXPath)) {
    Write-Host "Error: Adam-x.ps1 not found in the current directory." -ForegroundColor Red
    exit 1
}

# Import the Adam-x script and start it
. $adamXPath
Start-AdamX
