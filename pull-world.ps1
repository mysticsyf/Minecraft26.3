$destination = "$env:USERPROFILE\Documents\Minecraft26.3"
$github = "https://github.com/mysticsyf/Minecraft26.3.git"

# Check destination exists
if (!(Test-Path "$destination\.git")) {
    Write-Host "Repository not found. Cloning from GitHub..."

    git clone $github $destination

    if ($LASTEXITCODE -ne 0) {
        throw "Git clone failed."
    }
}
else {
    Write-Host "Pulling latest changes from GitHub..."

    Set-Location $destination
    git pull --ff-only

    if ($LASTEXITCODE -ne 0) {
        throw "Git pull failed. Check for local changes or conflicts."
    }
}

Write-Host "World repository updated successfully!"
Pause