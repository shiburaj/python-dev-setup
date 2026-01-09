Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Python Dev Environment Setup (Smart + Self-Install) " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# ----------------------------
# CONFIGURATION
# ----------------------------
$NEXUS_SOURCE_NAME = "nexus-choco"
$NEXUS_SOURCE_URL  = "http://nexus.rcoe.co.in/repository/choco/"

$COMMUNITY_SOURCE_NAME = "chocolatey"
$COMMUNITY_SOURCE_URL  = "https://community.chocolatey.org/api/v2/"

# ----------------------------
# Network Selection
# ----------------------------
Write-Host "`nSelect network location:" -ForegroundColor Yellow
Write-Host "1. Inside College Network (Use Nexus)"
Write-Host "2. Outside / Home Network (Use Public Chocolatey)"

$choice = Read-Host "Enter choice (1 or 2)"

switch ($choice) {
    "1" { $MODE = "COLLEGE" }
    "2" { $MODE = "HOME" }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

# ----------------------------
# Install Chocolatey if missing
# ----------------------------
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {

    Write-Host "`nChocolatey not found. Installing Chocolatey..." -ForegroundColor Yellow

    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    iex ((New-Object System.Net.WebClient).DownloadString(
        "https://community.chocolatey.org/install.ps1"
    ))

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey installation failed. Exiting." -ForegroundColor Red
        exit 1
    }
}

# ----------------------------
# Configure Chocolatey Sources
# ----------------------------
Write-Host "`nConfiguring Chocolatey sources for $MODE mode..." -ForegroundColor Cyan

if ($MODE -eq "COLLEGE") {

    choco source disable -n $COMMUNITY_SOURCE_NAME 2>$null

    if (choco source list | Select-String $NEXUS_SOURCE_NAME) {
        choco source remove -n $NEXUS_SOURCE_NAME
    }

    choco source add `
        -n $NEXUS_SOURCE_NAME `
        -s $NEXUS_SOURCE_URL `
        --priority 1 `
        --bypass-proxy `
        -y

    $CHOCOSOURCE = $NEXUS_SOURCE_NAME
}
else {

    if (-not (choco source list | Select-String $COMMUNITY_SOURCE_NAME)) {
        choco source add -n $COMMUNITY_SOURCE_NAME -s $COMMUNITY_SOURCE_URL -y
    }
    else {
        choco source enable -n $COMMUNITY_SOURCE_NAME
    }

    choco source remove -n $NEXUS_SOURCE_NAME 2>$null

    $CHOCOSOURCE = $COMMUNITY_SOURCE_NAME
}

choco source list

# ----------------------------
# Helper: Uninstall if installed
# ----------------------------
function Uninstall-IfInstalled {
    param ([string]$PackageName)

    if (choco list --local-only | Select-String "^$PackageName") {
        Write-Host "Uninstalling $PackageName..." -ForegroundColor Yellow
        choco uninstall $PackageName -y --remove-dependencies
    }
}

# ----------------------------
# Remove conflicting software
# ----------------------------
Write-Host "`nRemoving existing installations..." -ForegroundColor Cyan

Uninstall-IfInstalled "python"
Uninstall-IfInstalled "python3"
Uninstall-IfInstalled "vscode"
Uninstall-IfInstalled "vscode.install"
Uninstall-IfInstalled "visualstudiocode"
Uninstall-IfInstalled "git"

# ----------------------------
# Install Python
# ----------------------------
Write-Host "`nInstalling Python..." -ForegroundColor Cyan
choco install python --version=3.12.1 -y --source $CHOCOSOURCE

# Refresh PATH
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")

# ----------------------------
# Upgrade pip
# ----------------------------
Write-Host "`nUpgrading pip..." -ForegroundColor Cyan
python -m pip install --upgrade pip

# ----------------------------
# Install Python dev tools
# ----------------------------
Write-Host "`nInstalling Python developer tools..." -ForegroundColor Cyan
pip install virtualenv pipenv pytest black flake8 ipython

# ----------------------------
# Install Git
# ----------------------------
Write-Host "`nInstalling Git..." -ForegroundColor Cyan
choco install git -y --source $CHOCOSOURCE

# ----------------------------
# Install VS Code
# ----------------------------
Write-Host "`nInstalling VS Code..." -ForegroundColor Cyan
choco install vscode.install -y --source $CHOCOSOURCE

# ----------------------------
# Install VS Code Extensions
# ----------------------------
#Write-Host "`nInstalling VS Code extensions..." -ForegroundColor Cyan

#$codeCmd = "C:\Program Files\Microsoft VS Code\Code.exe"
# $extensions = @(
    # "ms-python.python",
    # "ms-python.vscode-pylance",
    # "ms-toolsai.jupyter",
    # "ms-vscode.vscode-git",
    # "ms-python.black-formatter",
    # "ms-python.flake8"
# )

# foreach ($ext in $extensions) {
    # & $codeCmd --install-extension $ext --force
# }

# ----------------------------
# Verification
# ----------------------------
Write-Host "`nVerification:" -ForegroundColor Green
python --version
pip --version
git --version
code --version

Write-Host "`nSUCCESS: Setup completed in $MODE mode." -ForegroundColor Green
Write-Host "Restart the system before lab use." -ForegroundColor Yellow

Write-Host "Open CMD and Run below commands to Install Extensions" -ForegroundColor Yellow

Write-Host "code --install-extension ms-python.python ^" -ForegroundColor Yellow
Write-Host "code --install-extension ms-python.vscode-pylance ^" -ForegroundColor Yellow
Write-Host "code --install-extension ms-toolsai.jupyter ^" -ForegroundColor Yellow
Write-Host "code --install-extension ms-python.black-formatter ^" -ForegroundColor Yellow
Write-Host "code --install-extension ms-python.flake8" -ForegroundColor Yellow
