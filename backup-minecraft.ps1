$source = "$env:APPDATA\.minecraft\saves\MSC26_3"
$destination = "$env:USERPROFILE\Documents\Minecraft26.3"

# Check whether the source exists
if (!(Test-Path $source)) {
    Write-Host "Minecraft world not found!" -ForegroundColor Red
    exit
}

# Create destination if it doesn't exist
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination
}

# Synchronize world files
robocopy $source $destination /E

Write-Host "Minecraft backup completed!" -ForegroundColor Green
