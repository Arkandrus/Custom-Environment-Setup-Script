<#
.SYNOPSIS
    Ensures Git, PowerToys, and VS Code are installed; installs a fixed set of
    VS Code extensions; deploys settings.json and keybindings.json from a URL.

    Works on Windows 10/11 (uses winget when available) and Windows Server
    2022 (falls back to direct downloads).


.PARAMETER BackupExisting
    Back up existing settings.json and keybindings.json before overwriting.

.PARAMETER SystemInstall
    Use system-wide VS Code installer (requires admin). Default is per-user.

.PARAMETER NoUpgrade
    If Git or PowerToys are already installed, skip them entirely instead of
    running winget upgrade.
#>
[CmdletBinding()]
param(
    [switch]$BackupExisting,
    [switch]$SystemInstall,
    [switch]$NoUpgrade,
    [switch]$SkipPowerToys  # useful on headless servers
)

$ErrorActionPreference = 'Stop'

# --- Configuration ---------------------------------------------------------

$SettingsUrl    = 'https://home.zcu.cz/~kudlacm/settings.json'
$KeybindingsUrl = 'https://home.zcu.cz/~kudlacm/keybindings.json'

$Extensions = @(
    'ms-dotnettools.vscode-dotnet-runtime',
    'formulahendry.code-runner',
    'streetsidesoftware.code-spell-checker',
    'eamodio.gitlens',
    'ms-vscode.live-server',
    'wayou.vscode-todo-highlight',
    'vscodevim.vim',
    'tobias-z.vscode-harpoon'
)

$UserInstallPath   = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'
$SystemInstallPath = Join-Path $env:ProgramFiles 'Microsoft VS Code'

# --- Logging helpers -------------------------------------------------------

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Err2($msg) { Write-Host "    $msg" -ForegroundColor Red }

# --- Detection helpers -----------------------------------------------------

function Test-WingetAvailable {
    [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Test-GitInstalled {
    if (Get-Command git -ErrorAction SilentlyContinue) { return $true }
    $paths = @(
        "$env:ProgramFiles\Git\cmd\git.exe",
        "${env:ProgramFiles(x86)}\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    )
    foreach ($p in $paths) { if (Test-Path $p) { return $true } }
    return $false
}

function Test-PowerToysInstalled {
    $paths = @(
        "$env:ProgramFiles\PowerToys\PowerToys.exe",
        "$env:LOCALAPPDATA\PowerToys\PowerToys.exe"
    )
    foreach ($p in $paths) { if (Test-Path $p) { return $true } }
    return $false
}

# --- Generic download with retry ------------------------------------------

function Invoke-Download {
    param([string]$Url, [string]$OutFile)
    # Force TLS 1.2 for older PowerShell on Server 2022 default config.
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
}

# --- Direct download installers -------------------------------------------

function Install-GitDirect {
    Write-Step "Resolving latest Git for Windows release..."
    # GitHub API gives us the asset URL for the 64-bit installer.
    $api = 'https://api.github.com/repos/git-for-windows/git/releases/latest'
    $headers = @{ 'User-Agent' = 'PowerShell-Setup-Script' }
    $rel = Invoke-RestMethod -Uri $api -Headers $headers -UseBasicParsing
    $asset = $rel.assets | Where-Object {
        $_.name -match '^Git-.*-64-bit\.exe$'
    } | Select-Object -First 1
    if (-not $asset) { throw "Could not find Git 64-bit installer asset." }

    $installer = Join-Path $env:TEMP $asset.name
    Write-Step "Downloading $($asset.name)..."
    Invoke-Download -Url $asset.browser_download_url -OutFile $installer

    Write-Step "Installing Git silently..."
    # Git uses Inno Setup. /VERYSILENT for no UI, /NORESTART, sensible defaults.
    $args = @('/VERYSILENT', '/NORESTART', '/SUPPRESSMSGBOXES', '/SP-',
              '/COMPONENTS=icons,ext\reg\shellhere,assoc,assoc_sh')
    $p = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
    Remove-Item $installer -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0) { throw "Git installer exit code $($p.ExitCode)." }
    Write-Ok "Git installed."
}

function Install-PowerToysDirect {
    Write-Step "Resolving latest PowerToys release..."
    $api = 'https://api.github.com/repos/microsoft/PowerToys/releases/latest'
    $headers = @{ 'User-Agent' = 'PowerShell-Setup-Script' }
    $rel = Invoke-RestMethod -Uri $api -Headers $headers -UseBasicParsing

    $arch = if ([Environment]::Is64BitOperatingSystem) {
        if ((Get-CimInstance Win32_Processor).Architecture -eq 12) { 'arm64' }
        else { 'x64' }
    } else { 'x86' }

    # Prefer per-machine MSI for unattended/server installs.
    $asset = $rel.assets | Where-Object {
        $_.name -match "PowerToysSetup.*$arch\.exe$"
    } | Select-Object -First 1
    if (-not $asset) { throw "Could not find PowerToys $arch installer." }

    $installer = Join-Path $env:TEMP $asset.name
    Write-Step "Downloading $($asset.name)..."
    Invoke-Download -Url $asset.browser_download_url -OutFile $installer

    Write-Step "Installing PowerToys silently..."
    # PowerToys installer accepts /silent and /norestart.
    $args = @('/silent', '/norestart')
    $p = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
    Remove-Item $installer -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) {
        # 3010 = success, reboot required.
        throw "PowerToys installer exit code $($p.ExitCode)."
    }
    Write-Ok "PowerToys installed."
}

# --- winget path (when available) -----------------------------------------

function Ensure-WingetPackage {
    param([string]$Name, [string]$Id, [switch]$SkipUpgrade)

    Write-Step "Checking $Name ($Id) via winget..."
    $list = winget list --id $Id --exact --accept-source-agreements 2>&1
    $installed = ($LASTEXITCODE -eq 0) -and ($list -match [regex]::Escape($Id))

    if ($installed) {
        if ($SkipUpgrade) {
            Write-Ok "$Name already installed; skipping."
            return
        }
        Write-Ok "$Name already installed. Checking for upgrade..."
        $out = winget upgrade --id $Id --exact --silent `
            --accept-source-agreements --accept-package-agreements 2>&1
        if ($out -match 'No applicable upgrade|up to date|No installed package') {
            Write-Ok "$Name is up to date."
        } else {
            Write-Ok "$Name upgraded."
        }
    } else {
        Write-Step "Installing $Name..."
        $out = winget install --id $Id --exact --silent `
            --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "winget install failed for $Name. Output: $out"
        }
        Write-Ok "$Name installed."
    }
}

# --- Dispatcher: pick winget or direct download per package ---------------

function Ensure-Git {
    param([switch]$SkipUpgrade)
    if (Test-GitInstalled) {
        Write-Ok "Git already installed."
        if (-not $SkipUpgrade -and (Test-WingetAvailable)) {
            # If winget is around, let it handle upgrades.
            try { Ensure-WingetPackage -Name 'Git' -Id 'Git.Git' } catch {
                Write-Warn2 "winget upgrade of Git failed; leaving existing install alone."
            }
        }
        return
    }
    if (Test-WingetAvailable) {
        Ensure-WingetPackage -Name 'Git' -Id 'Git.Git' -SkipUpgrade:$SkipUpgrade
    } else {
        Write-Warn2 "winget unavailable; using direct download for Git."
        Install-GitDirect
    }
}

function Ensure-PowerToys {
    param([switch]$SkipUpgrade)
    if (Test-PowerToysInstalled) {
        Write-Ok "PowerToys already installed."
        if (-not $SkipUpgrade -and (Test-WingetAvailable)) {
            try { Ensure-WingetPackage -Name 'PowerToys' -Id 'Microsoft.PowerToys' } catch {
                Write-Warn2 "winget upgrade of PowerToys failed; leaving existing install alone."
            }
        }
        return
    }
    if (Test-WingetAvailable) {
        Ensure-WingetPackage -Name 'PowerToys' -Id 'Microsoft.PowerToys' -SkipUpgrade:$SkipUpgrade
    } else {
        Write-Warn2 "winget unavailable; using direct download for PowerToys."
        Install-PowerToysDirect
    }
}

# --- VS Code (unchanged from prior version) -------------------------------

function Get-VSCodePaths {
    foreach ($base in @($UserInstallPath, $SystemInstallPath)) {
        $codeCmd = Join-Path $base 'bin\code.cmd'
        if (Test-Path $codeCmd) {
            return [pscustomobject]@{ InstallDir = $base; CodeCmd = $codeCmd }
        }
    }
    return $null
}

function Install-VSCode {
    param([switch]$System)
    $arch = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { '' }
    $url = if ($System) {
        "https://code.visualstudio.com/sha/download?build=stable&os=win32-$arch"
    } else {
        "https://code.visualstudio.com/sha/download?build=stable&os=win32-$arch-user"
    }
    $installer = Join-Path $env:TEMP "vscode-installer-$([guid]::NewGuid()).exe"
    Write-Step "Downloading VS Code installer..."
    Invoke-Download -Url $url -OutFile $installer
    Write-Step "Running VS Code installer silently..."
    $args = @('/VERYSILENT','/NORESTART','/SP-',
              '/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,addtopath')
    $p = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
    Remove-Item $installer -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0) { throw "VS Code installer exit code $($p.ExitCode)." }
    Write-Ok "VS Code installed."
}

function Ensure-Extensions {
    param([string]$CodeCmd, [string[]]$Wanted)
    Write-Step "Querying installed VS Code extensions..."
    $installedRaw = & $CodeCmd --list-extensions 2>$null
    $installed = @($installedRaw | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
    foreach ($ext in $Wanted) {
        if ($installed -contains $ext.ToLowerInvariant()) {
            Write-Ok "Already installed: $ext"
        } else {
            Write-Step "Installing extension: $ext"
            $out = & $CodeCmd --install-extension $ext --force 2>&1
            if ($LASTEXITCODE -ne 0) { Write-Err2 "Failed: $ext`n$out" }
            else { Write-Ok "Installed $ext" }
        }
    }
}

function Deploy-ConfigFile {
    param([string]$Url, [string]$DestPath, [switch]$Backup)
    $destDir = Split-Path $DestPath -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    if ((Test-Path $DestPath) -and $Backup) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        Copy-Item $DestPath "$DestPath.$stamp.bak" -Force
        Write-Ok "Backed up to $DestPath.$stamp.bak"
    }
    Write-Step "Downloading $Url"
    $tmp = "$DestPath.download"
    try {
        Invoke-Download -Url $Url -OutFile $tmp
        $raw = Get-Content $tmp -Raw
        $stripped = [regex]::Replace($raw, '(?m)^\s*//.*$', '')
        $stripped = [regex]::Replace($stripped, ',\s*(\}|\])', '$1')
        try { $null = $stripped | ConvertFrom-Json } catch {
            throw "Downloaded file is not valid JSON: $Url"
        }
        Move-Item $tmp $DestPath -Force
        Write-Ok "Wrote $DestPath"
    } finally {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }
}

# --- Main ------------------------------------------------------------------

Ensure-Git -SkipUpgrade:$NoUpgrade

if ($SkipPowerToys) {
    Write-Warn2 "Skipping PowerToys (per -SkipPowerToys)."
} else {
    Ensure-PowerToys -SkipUpgrade:$NoUpgrade
}

Write-Step "Checking for Visual Studio Code..."
$vscode = Get-VSCodePaths
if (-not $vscode) {
    Install-VSCode -System:$SystemInstall
    $vscode = Get-VSCodePaths
    if (-not $vscode) { throw "VS Code not detected after install." }
} else {
    Write-Ok "Found VS Code at $($vscode.InstallDir)"
}

Ensure-Extensions -CodeCmd $vscode.CodeCmd -Wanted $Extensions

$userDir      = Join-Path $env:APPDATA 'Code\User'
$settingsPath = Join-Path $userDir 'settings.json'
$keybindsPath = Join-Path $userDir 'keybindings.json'
Deploy-ConfigFile -Url $SettingsUrl    -DestPath $settingsPath -Backup:$BackupExisting
Deploy-ConfigFile -Url $KeybindingsUrl -DestPath $keybindsPath -Backup:$BackupExisting

Write-Step "Done."