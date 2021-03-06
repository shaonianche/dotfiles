#!/usr/bin/env pwsh
# Requires -Version 5
# https://github.com/chawyehsu/dotfiles/blob/main/install.ps1

Write-Host "This will overwrite all local dotfiles. Make sure backup your changes." -f Red
Read-Host "Please enter to continue or Ctrl+C to cancel"

$SRCROOT = (Resolve-Path "$PSScriptRoot/")
$DSTROOT = (Resolve-Path (($env:HOME, $env:USERPROFILE |
    Where-Object { -not [String]::IsNullOrEmpty($_) } |
    Select-Object -First 1).ToString().TrimEnd('/') + '/'))

function Set-SymbolicLink([String]$Target, [String]$Path) {
    if (!$Path) { $Path = $Target }
    $src = (Join-Path $SRCROOT $Target)
    $dst = if ([System.IO.Path]::IsPathRooted($Path)) {
        (Resolve-Path $Path)
    } else {
        (Join-Path $DSTROOT $Path)
    }
    Write-Output $dst.ToString()

    if (Test-Path $dst) {
        Remove-Item -Path $dst -Force
    }
    New-Item -Type SymbolicLink -Path $dst -Target $src -Force | Out-Null
}

# Common dotfiles
Set-SymbolicLink -Target ".config/bash/.bash_logout"
Set-SymbolicLink -Target ".config/bash/.bash_profile"
Set-SymbolicLink -Target ".config/bash/.bashrc"
Set-SymbolicLink -Target ".config/.cargo/config"
Set-SymbolicLink -Target ".config/gh/config.yml"
Set-SymbolicLink -Target ".config/git/config"
Set-SymbolicLink -Target ".config/git/ignore"
Set-SymbolicLink -Target ".config/starship.toml"
Set-SymbolicLink -Target ".dir_colors"
Set-SymbolicLink -Target ".gemrc"
Set-SymbolicLink -Target ".config/.gnupg/gpg-agent.conf"
Set-SymbolicLink -Target ".config/.gnupg/gpg.conf"
Set-SymbolicLink -Target ".gvimrc"
Set-SymbolicLink -Target ".inputrc"
Set-SymbolicLink -Target ".nanorc"
Set-SymbolicLink -Target ".vimrc"
Set-SymbolicLink -Target ".wgetrc"

# Runtime generated dotfiles
& {
    # .npmrc
    if (!(Test-Path "$DSTROOT/.npmrc")) {
        Write-Output "loglevel=http" | Out-File "$DSTROOT/.npmrc" -Force
    }
}

# OS-specific dotfiles
if ($env:OS -eq "Windows_NT" -or $IsWindows) { # Windows
    # MinTTY
    Set-SymbolicLink -Target ".minttyrc"
    Set-SymbolicLink -Target ".config/git/config.win.conf" `
        -Path ".config/git/config.local"
    # PowerShell
    Set-SymbolicLink -Targe ".config/powershell/profile.ps1" `
        -Path $PROFILE.CurrentUserAllHosts
    Set-SymbolicLink -Target ".config/pshazz/config.json"
    Set-SymbolicLink -Target ".config/scoop/config.json"
    # pip
    Set-SymbolicLink -Target ".config/pip/pip.ini" ` -Path "pip/pip.ini"
    # Windows Terminal
    Set-SymbolicLink -Target "scoop/persist/windows-terminal/settings.json" `
        -Path "$env:LOCALAPPDATA/Microsoft/Windows Terminal/settings.json"
    # WSL
    Set-SymbolicLink -Target ".config/wsl/.wslconfig" -Path ".wslconfig"
}
