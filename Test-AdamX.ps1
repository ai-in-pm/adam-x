# Test script for Adam-x

Write-Host "Testing Adam-x..." -ForegroundColor Green

# Import the Adam-x script
. .\Adam-x.ps1

# Call the setup function directly
Write-Host "Calling Initialize-AdamXSetup..." -ForegroundColor Yellow
Initialize-AdamXSetup

Write-Host "Test completed." -ForegroundColor Green
