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
    }
    else {
        (Join-Path $DSTROOT $Path)
    }
    Write-Output $dst.ToString()

    if (Test-Path $dst) {
        Remove-Item -Path $dst -Force
    }
    New-Item -Type SymbolicLink -Path $dst -Target $src -Force | Out-Null
}

function New-SymbolicLink {
    $files = @(
        ".curlrc",
        ".editorconfig",
        ".inputrc",
        ".wgetrc",
        ".config/git/config",
        ".config/git/.gitignore"
        ".config/git/.gitattributes",
        "windows/git/config.win.conf",
        ".config/vim/.vimrc",
        ".config/starship/starship.toml"
    )
    foreach ($file in $files) {
        Set-SymbolicLink -Target $file
    }
}

New-SymbolicLink

<#

# Set-SymbolicLink -Target ".config/.cargo/config"
# Set-SymbolicLink -Target ".config/git/config"
# Set-SymbolicLink -Target ".config/git/ignore"

# Set-SymbolicLink -Target ".config/starship.toml"
# Set-SymbolicLink -Target ".config/.gnupg/gpg-agent.conf"
# Set-SymbolicLink -Target ".config/.gnupg/gpg.conf"
# Set-SymbolicLink -Target "/workspace/dotfiles/.inputrc"
# Set-SymbolicLink -Target "/workspace/dotfiles/.config/vim/.vimrc"
# Set-SymbolicLink -Target "/workspace/dotfiles/.wgetrc"


# Set-SymbolicLink -Target "git/config.win.conf"   -Path ".config/git/config.local"
# PowerShell
# Set-SymbolicLink -Targe "powershell/profile.ps0"  -Path $PROFILE.CurrentUserAllHosts
# Set-SymbolicLink -Target "pshazz/config.json"
# Set-SymbolicLink -Target "scoop/config.json"
# pip
# Set-SymbolicLink -Target ".config/pip/pip.ini" ` -Path "pip/pip.ini"

# Windows Terminal
# Set-SymbolicLink -Target "scoop/persist/windows-terminal/settings.json"  -Path "$env:LOCALAPPDATA/Microsoft/Windows Terminal/settings.json"
# WSL
# Set-SymbolicLink -Target "wsl/.wslconfig" -Path ".wslconfig"

#>

# Runtime generated dotfiles
& {
    # .npmrc
    if (!(Test-Path "$DSTROOT/.npmrc")) {
        Write-Output "loglevel=http" | Out-File "$DSTROOT/.npmrc" -Force
    }
}

