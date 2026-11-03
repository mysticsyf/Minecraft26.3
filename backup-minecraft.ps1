# ==========================================
# Minecraft Automatic GitHub Backup
# ==========================================

$source = "$env:APPDATA\.minecraft\saves\MSC26_3"
$destination = "$env:USERPROFILE\Documents\Minecraft26.3"

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "  MINECRAFT BACKUP SYSTEM" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# 1. Check source folder
if (!(Test-Path $source)) {
    Write-Host "ERROR: Minecraft world not found!" -ForegroundColor Red
    exit 1
}

# 2. Check Git repository
if (!(Test-Path "$destination\.git")) {
    Write-Host "ERROR: Git repository not found!" -ForegroundColor Red
    exit 1
}

# 3. Copy Minecraft world
Write-Host "[1/5] Copying Minecraft world..." -ForegroundColor Yellow

robocopy $source $destination /E /R:2 /W:2 /XF session.lock

# Robocopy codes below 8 indicate success
if ($LASTEXITCODE -ge 8) {
    Write-Host "ERROR: World copy failed!" -ForegroundColor Red
    exit 1
}

Write-Host "World copied successfully!" -ForegroundColor Green

# 4. Configure Git ignore
Write-Host "`n[2/5] Configuring Git..." -ForegroundColor Yellow

$gitignore = Join-Path $destination ".gitignore"

if (!(Test-Path $gitignore)) {
    New-Item -Path $gitignore -ItemType File | Out-Null
}

$ignoreContent = Get-Content $gitignore -ErrorAction SilentlyContinue

if ($ignoreContent -notcontains "session.lock") {
    Add-Content $gitignore "`nsession.lock"
}

# Remove session.lock from Git tracking if previously added
git rm --cached --ignore-unmatch session.lock

# 5. Stage all changes
Write-Host "`n[3/5] Checking for changes..." -ForegroundColor Yellow

Set-Location $destination

git add -A

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Git add failed!" -ForegroundColor Red
    exit 1
}

# 6. Commit changes if necessary
git diff --cached --quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes detected. Backup is already up to date." -ForegroundColor Green
}
elseif ($LASTEXITCODE -eq 1) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMessage = "Minecraft backup - $timestamp"

    Write-Host "`n[4/5] Creating Git commit..." -ForegroundColor Yellow

    git commit -m $commitMessage

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Git commit failed!" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "ERROR: Could not check Git changes!" -ForegroundColor Red
    exit 1
}

# 7. Push to GitHub
Write-Host "`n[5/5] Pushing to GitHub..." -ForegroundColor Yellow

git push origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: GitHub push failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n================================" -ForegroundColor Green
Write-Host "  BACKUP COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green
