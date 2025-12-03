#Requires -Version 5.1

$Script:UNI_HOME = $env:USERPROFILE

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

Add-ToPath "$Script:UNI_HOME\.local\bin"
Add-ToPath "$Script:UNI_HOME\.cargo\bin"
Add-ToPath "$Script:UNI_HOME\.deno\bin"
Add-ToPath "$Script:UNI_HOME\.dotnet\tools"
$env:DOTNET_ROOT = "$env:LocalAppData\Microsoft\dotnet"
Add-ToPath $env:DOTNET_ROOT -AllowNotExist

Remove-Item 'alias:\ls' -ErrorAction SilentlyContinue
Remove-Item 'alias:\r' -ErrorAction SilentlyContinue

function Get-GitDiff { git diff }
function Get-GitStatus { git status }
Set-Alias gdf Get-GitDiff -Option AllScope
Set-Alias gst Get-GitStatus -Option AllScope
Set-Alias c cls -Option AllScope

function Get-WanIp { Invoke-RestMethod ip.sb }
Set-Alias getwanip Get-WanIp -Option AllScope

function Start-Serve { python -m http.server 8080 }
Set-Alias serve Start-Serve -Option AllScope

function Open-Here { explorer $(Get-Location) }
if (-not (Get-Command open -ErrorAction SilentlyContinue)) {
        Set-Alias open explorer -Option AllScope
}
Set-Alias here Open-Here -Option AllScope

Set-Alias neofetch fastfetch
Set-Alias vim nvim

if (Get-Command eza -ErrorAction SilentlyContinue) {
        function ls { eza -al @args }
        Set-Alias ll ls -Option AllScope
}

function Get-AllEnv { Get-ChildItem env: }
Set-Alias export Get-AllEnv -Option AllScope

if ($env:COMPUTERNAME -and $env:COMPUTERNAME.Length -gt 1) {
        $env:COMPUTERNAME = $env:COMPUTERNAME.Substring(0, 1).ToUpper() + $env:COMPUTERNAME.Substring(1).ToLower()
}

# ===== Completion Cache System =====
$Script:CompletionCacheDir = "$env:XDG_CACHE_HOME\powershell\completions"
if (-not (Test-Path $Script:CompletionCacheDir)) {
        New-Item -ItemType Directory -Path $Script:CompletionCacheDir -Force | Out-Null
}

function Get-CachedCompletion {
        param(
                [string]$Command,
                [string]$GenerateCommand,
                [string[]]$GenerateArgs
        )
        $cachePath = "$Script:CompletionCacheDir\$Command.ps1"
        $commandPath = Get-Command $Command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

        if ($commandPath) {
                $needsRefresh = $false
                if (-not (Test-Path $cachePath)) {
                        $needsRefresh = $true
                }
                else {
                        $cacheTime = (Get-Item $cachePath).LastWriteTime
                        $commandTime = (Get-Item $commandPath).LastWriteTime
                        if ($commandTime -gt $cacheTime) {
                                $needsRefresh = $true
                        }
                }

                if ($needsRefresh) {
                        & $GenerateCommand @GenerateArgs | Out-File -FilePath $cachePath -Encoding utf8 -Force
                }
                return $cachePath
        }
        return $null
}

# Winget completion (lazy-loaded, native completer is efficient)
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

# Starship prompt (cached)
$starshipCache = "$Script:CompletionCacheDir\starship-init.ps1"
if (Get-Command starship -ErrorAction SilentlyContinue) {
        $starshipPath = (Get-Command starship).Source
        if (-not (Test-Path $starshipCache) -or (Get-Item $starshipPath).LastWriteTime -gt (Get-Item $starshipCache).LastWriteTime) {
                & starship init powershell | Out-File -FilePath $starshipCache -Encoding utf8 -Force
        }
        . $starshipCache
}

# Zoxide (cached)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        $env:_ZO_FZF_OPTS = '--height 40% --reverse --preview "eza --tree --color=always --icons -L 2 {}"'

        $zoxideCache = "$Script:CompletionCacheDir\zoxide-init.ps1"
        $zoxidePath = (Get-Command zoxide).Source
        if (-not (Test-Path $zoxideCache) -or (Get-Item $zoxidePath).LastWriteTime -gt (Get-Item $zoxideCache).LastWriteTime) {
                & zoxide init --hook pwd powershell | Out-File -FilePath $zoxideCache -Encoding utf8 -Force
        }
        . $zoxideCache

        Set-Alias cd z -Option AllScope
        function zi { zoxide query -i @args }
}

# ===== Lazy-loaded Completions =====
$Script:LazyCompletions = @{
        'gh'     = @{ Args = @('completion', '-s', 'powershell'); Loaded = $false }
        'pixi'   = @{ Args = @('completion', '-s', 'powershell'); Loaded = $false }
        'rustup' = @{ Args = @('completions', 'power-shell'); Loaded = $false }
        'deno'   = @{ Args = @('completions', 'powershell'); Loaded = $false }
        'volta'  = @{ Args = @('completions', 'powershell'); Loaded = $false }
}

function Initialize-LazyCompletion {
        param([string]$Command)
        if ($Script:LazyCompletions.ContainsKey($Command) -and -not $Script:LazyCompletions[$Command].Loaded) {
                $cachePath = Get-CachedCompletion -Command $Command -GenerateCommand $Command -GenerateArgs $Script:LazyCompletions[$Command].Args
                if ($cachePath -and (Test-Path $cachePath)) {
                        . $cachePath
                        $Script:LazyCompletions[$Command].Loaded = $true
                }
        }
}

# Register lazy completers
$Script:LazyCompletions.Keys | ForEach-Object {
        $cmd = $_
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
                Register-ArgumentCompleter -Native -CommandName $cmd -ScriptBlock {
                        param($wordToComplete, $commandAst, $cursorPosition)
                        $cmdName = $commandAst.CommandElements[0].Value
                        Initialize-LazyCompletion -Command $cmdName
                        # Re-invoke tab completion after loading
                        [System.Management.Automation.CommandCompletion]::CompleteInput(
                                $commandAst.ToString(),
                                $cursorPosition,
                                $null
                        ).CompletionMatches
                }.GetNewClosure()
        }
}


Import-Module -Name Microsoft.WinGet.CommandNotFound -ErrorAction SilentlyContinue
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

if ((Get-Module -Name PSReadLine).Version -ge [System.Version]'2.1.0') {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle InlineView
}
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -Name 'PSFzf' -ListAvailable)) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}