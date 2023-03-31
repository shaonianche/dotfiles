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
        ".config/vim/.vimrc",
        ".config/starship/starship.toml",
        ".config/.gnupg/gpg-agent.conf",
        ".config/.gnupg/gpg.conf",
        ".config/.cargo/config"
    )
    foreach ($file in $files) {
        Set-SymbolicLink -Target $file
    }
}
New-SymbolicLink

Set-SymbolicLink -Target "/windows/scoop/persist/windows-terminal/settings.json" -Path "$env:LOCALAPPDATA/Microsoft/Windows Terminal/settings.json"
Set-SymbolicLink -Target "/windows/git/config.win.conf"  -Path ".config/git/config.local"
Set-SymbolicLink -Target "/windows/pshazz/config.json" -Path "$HOME/pshazz/config.json"
Set-SymbolicLink -Target "/windows/scoop/config.json" -Path "$HOME/scoop/config.json"
Set-SymbolicLink -Targe "/windows/powershell/profile.ps1"  -Path $PROFILE.CurrentUserAllHosts


# Runtime generated dotfiles
& {
    # .npmrc
    if (!(Test-Path "$DSTROOT/.npmrc")) {
        Write-Output "loglevel=http" | Out-File "$DSTROOT/.npmrc" -Force
    }
}

