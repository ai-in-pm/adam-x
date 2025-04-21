# Run script for Adam-x

Write-Host "Running Adam-x..." -ForegroundColor Green

# Import the Adam-x script
. .\Adam-x.ps1

# Call the main function directly
Write-Host "Calling Start-AdamX..." -ForegroundColor Yellow
Start-AdamX

Write-Host "Run completed." -ForegroundColor Green
