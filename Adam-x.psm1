# Adam-x PowerShell Module
# This file imports the Adam-x.ps1 script as a module

# Get the directory where this module is located
$moduleDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$adamXPath = Join-Path $moduleDirectory "Adam-x.ps1"

# Import the Adam-x script
. $adamXPath

# Export the functions
Export-ModuleMember -Function Start-AdamX, Invoke-AdamXCommand, Invoke-AdamXCodeAnalysis, New-AdamXDocumentation,
    New-AdamXExplanation, New-AdamXImprovement, New-AdamXCode, New-AdamXDebug, Get-OllamaModels,
    Invoke-OllamaModelPull, Remove-OllamaModel, Set-AdamXModel
