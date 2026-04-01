#Requires -RunAsAdministrator
# Setup script for a new dev VM
# Run: powershell -ExecutionPolicy Bypass -File .\setup-dev-vm.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Install-WithWinget {
    param([string]$Id, [string]$Name)
    Write-Host "`n--- Installing $Name ---" -ForegroundColor Cyan
    winget install --id $Id --exact --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install $Name (exit code $LASTEXITCODE)"
    } else {
        Write-Host "$Name installed successfully." -ForegroundColor Green
    }
}

# Ensure winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not available. Please install App Installer from the Microsoft Store first."
    exit 1
}

Write-Host "=== Dev VM Setup ===" -ForegroundColor Yellow

Install-WithWinget -Id "Google.Chrome"             -Name "Google Chrome"
Install-WithWinget -Id "Microsoft.VisualStudioCode" -Name "VS Code"
Install-WithWinget -Id "Git.Git"                    -Name "Git"
Install-WithWinget -Id "Python.Python.3.12"         -Name "Python 3.12"

# Claude Code (requires Node.js + npm)
Write-Host "`n--- Installing Node.js (required for Claude Code) ---" -ForegroundColor Cyan
Install-WithWinget -Id "OpenJS.NodeJS.LTS" -Name "Node.js LTS"

# Refresh PATH so npm is available in this session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "`n--- Installing Claude Code ---" -ForegroundColor Cyan
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g @anthropic-ai/claude-code
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Claude Code installed successfully." -ForegroundColor Green
    } else {
        Write-Warning "Failed to install Claude Code via npm."
    }
} else {
    Write-Warning "npm not found after Node.js install. Restart your terminal and run: npm install -g @anthropic-ai/claude-code"
}

Write-Host "`n=== Setup complete! ===" -ForegroundColor Yellow
Write-Host "You may need to restart your terminal or PC for PATH changes to take effect."
