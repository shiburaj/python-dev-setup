$ErrorActionPreference = "Stop"

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallerDir = Join-Path $BaseDir "installers"
$LogFile = Join-Path $BaseDir "install.log"

Start-Transcript -Path $LogFile -Append
Write-Host "Starting Offline Lab Installation..." -ForegroundColor Cyan

# ----------------------------
# Helper: Check installation
# ----------------------------
function Is-Installed {
    param ([string]$Name)
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
        -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$Name*" }
}

# ----------------------------
# Install Python
# ----------------------------
if (-not (Is-Installed "Python")) {
    Write-Host "Installing Python..." -ForegroundColor Yellow
    Start-Process `
        "$InstallerDir\python-3.12.1-amd64.exe" `
        -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" `
        -Wait
} else {
    Write-Host "Python already installed. Skipping." -ForegroundColor Green
}

# ----------------------------
# Install Git
# ----------------------------
if (-not (Is-Installed "Git")) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    Start-Process `
        "$InstallerDir\Git-2.44.0-64-bit.exe" `
        -ArgumentList "/VERYSILENT /NORESTART" `
        -Wait
} else {
    Write-Host "Git already installed. Skipping." -ForegroundColor Green
}

# ----------------------------
# Install VS Code
# ----------------------------
if (-not (Is-Installed "Microsoft Visual Studio Code")) {
    Write-Host "Installing VS Code..." -ForegroundColor Yellow
    Start-Process `
        "$InstallerDir\VSCodeSetup-x64.exe" `
        -ArgumentList "/verysilent /mergetasks=!runcode" `
        -Wait
} else {
    Write-Host "VS Code already installed. Skipping." -ForegroundColor Green
}

# ----------------------------
# Post-install checks
# ----------------------------
Write-Host "Verifying installations..." -ForegroundColor Cyan
python --version
git --version
code --version

Write-Host "Installation completed successfully." -ForegroundColor Green
Stop-Transcript
