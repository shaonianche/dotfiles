#Requires -Version 5.1

# 统一 $HOME 变量
$Script:UNI_HOME = $env:USERPROFILE

# 工具函数
function Add-ToPath {
        param (
                [Parameter(Mandatory = $true)][string]$Path,
                [switch]$AllowNotExist
        )
        if ((Test-Path $Path) -or $AllowNotExist) {
                if (-not ($env:PATH -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ieq $Path })) {
                        $env:PATH = "$Path;$env:PATH"
                }
        }
}

# 环境变量
$env:LANG = 'en_US.UTF-8'
$env:TZ = 'UTC-8'
$env:EDITOR = 'vim'
$env:RUSTUP_DIST_SERVER = 'https://mirrors.ustc.edu.cn/rust-static'
$env:FORCE_COLOR = 'true'
$env:GIT_PS1_SHOWDIRTYSTATE = 1
$env:GH_CONFIG_DIR = "$Script:UNI_HOME\.config\gh"
$env:XDG_CONFIG_HOME = "$Script:UNI_HOME\.config"
$env:XDG_CACHE_HOME = "$Script:UNI_HOME\.cache"
$env:XDG_DATA_HOME = "$Script:UNI_HOME\.local\share"
$env:XDG_STATE_HOME = "$Script:UNI_HOME\.local\state"
$env:NPM_CONFIG_USERCONFIG = "$env:XDG_CONFIG_HOME\npm\npmrc"
$env:POWERSHELL_TELEMETRY_OPTOUT = 1
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1
$env:VCPKG_DISABLE_METRICS = 1

# 路径设置
Add-ToPath "$Script:UNI_HOME\.local\bin"
Add-ToPath "$Script:UNI_HOME\.cargo\bin"
Add-ToPath "$Script:UNI_HOME\.deno\bin"
Add-ToPath "$Script:UNI_HOME\.dotnet\tools"
$env:DOTNET_ROOT = "$env:LocalAppData\Microsoft\dotnet"
Add-ToPath $env:DOTNET_ROOT -AllowNotExist

# 先移除内置别名，避免冲突
Remove-Item 'alias:\ls' -ErrorAction SilentlyContinue
Remove-Item 'alias:\r' -ErrorAction SilentlyContinue

# 常用函数与别名
function Get-GitDiff { git diff }
function Get-GitStatus { git status }
Set-Alias gdf Get-GitDiff -Option AllScope
Set-Alias gst Get-GitStatus -Option AllScope
Set-Alias c cls -Option AllScope

function Get-WanIp { Invoke-RestMethod https://ipinfo.io }
Set-Alias getip Get-WanIp -Option AllScope

function Get-WanIp { Invoke-RestMethod ip.sb }
Set-Alias getgbip Get-WanIp -Option AllScope

function Start-Serve { python -m http.server 8080 }
Set-Alias serve Start-Serve -Option AllScope

function Open-Here { explorer $(Get-Location) }
if (-not (Get-Command open -ErrorAction SilentlyContinue)) {
        Set-Alias open explorer -Option AllScope
}
Set-Alias here Open-Here -Option AllScope

Set-Alias neofetch fastfetch
Set-Alias vim nvim

function ls { eza -al @args }
Set-Alias ll ls -Option AllScope
Set-Alias wget wget2

function Get-AllEnv { Get-ChildItem env: }
Set-Alias export Get-AllEnv -Option AllScope

# 仅 Windows 下主机名格式化
$env:COMPUTERNAME = $env:COMPUTERNAME.Substring(0, 1).ToUpper() + $env:COMPUTERNAME.Substring(1).ToLower()

# WinGet 补全
if (Get-Command winget -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
                $Local:word = $wordToComplete.Replace('"', '""')
                $Local:ast = $commandAst.ToString().Replace('"', '""')
                winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
        }
}

# starship (Windows Terminal only)
if (Get-Command starship.exe -ErrorAction SilentlyContinue) {
        (& starship.exe 'init' 'powershell') | Out-String | Invoke-Expression
}

# zoxide and fzf integration
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $env:_ZO_FZF_OPTS = '--height 40% --reverse --preview "eza --tree --color=always --icons -L 2 {}"'

    Invoke-Expression (& { (zoxide init --hook pwd powershell) -join "`n" })

    Set-Alias cd z -Option AllScope
    Set-Alias zi 'zoxide query -i' -Option AllScope
}

# CLI tools tab-completions
@('gh', 'pixi') | ForEach-Object {
        if (Get-Command $_ -ErrorAction SilentlyContinue) {
                (& $_ 'completion' '-s' 'powershell') | Out-String | Invoke-Expression
        }
}
@('rustup', 'deno', 'volta', 'starship') | ForEach-Object {
        if (Get-Command $_ -ErrorAction SilentlyContinue) {
                (& $_ 'completions' 'powershell') | Out-String | Invoke-Expression
        }
}

# 其他模块和工具初始化
Import-Module -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -Name 'PSFzf' -ListAvailable)) {
    Set-PSReadLineKeyHandler -Key 'Ctrl+spacebar' -ScriptBlock { Invoke-PSFzfCompleter }
    Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock { PSFzfHistoryFiles }
    Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock { PSFzfReverseHistorySearch }
}
if (Test-Path "$HOME/.venv/Scripts/Activate.ps1") {
        . $HOME/.venv/Scripts/Activate.ps1
}
