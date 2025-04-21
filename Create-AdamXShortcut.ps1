<#
.SYNOPSIS
    Creates a desktop shortcut for Adam-x AI Coding Assistant
.DESCRIPTION
    This script creates a shortcut on the desktop that launches Adam-x directly
.NOTES
    Version:        1.0
    Author:         AI Assistant
    Creation Date:  $(Get-Date -Format "yyyy-MM-dd")
#>

# Get the current directory where Adam-x is installed
$adamXDirectory = $PSScriptRoot
$adamXPath = Join-Path $adamXDirectory "Adam-x.ps1"
$launcherPath = Join-Path $adamXDirectory "Launch-AdamX.ps1"

# Check if Adam-x.ps1 exists
if (-not (Test-Path $adamXPath)) {
    Write-Host "Error: Adam-x.ps1 not found in the current directory." -ForegroundColor Red
    exit 1
}

# Define the shortcut path
$shortcutPath = "C:\Users\djjme\OneDrive\Desktop\AI-Shortcuts\adam-x-shortcut.lnk"

# Create the directory if it doesn't exist
$shortcutDir = Split-Path -Parent $shortcutPath
if (-not (Test-Path $shortcutDir)) {
    New-Item -ItemType Directory -Path $shortcutDir -Force | Out-Null
    Write-Host "Created directory: $shortcutDir" -ForegroundColor Green
}

# Create the shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"

# Use the launcher script to start Adam-x
$Shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$launcherPath`""
$Shortcut.WorkingDirectory = $adamXDirectory
$Shortcut.Description = "Adam-x AI Coding Assistant"
$Shortcut.IconLocation = "powershell.exe,0"
$Shortcut.Save()

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

Shortcut Created!

A shortcut to Adam-x has been created at:
$shortcutPath

You can now launch Adam-x directly from this shortcut.

"@ -ForegroundColor Cyan
