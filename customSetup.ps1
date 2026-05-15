<#
.SYNOPSIS
    Ensures Git, PowerToys, and VS Code are installed; installs a fixed set of
    VS Code extensions; deploys settings.json and keybindings.json from a URL.

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
    [switch]$NoUpgrade
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

# winget package IDs.
$WingetPackages = @(
    @{ Name = 'Git';        Id = 'Git.Git' },
    @{ Name = 'PowerToys';  Id = 'Microsoft.PowerToys' }
)

$UserInstallPath   = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code'
$SystemInstallPath = Join-Path $env:ProgramFiles 'Microsoft VS Code'

# --- Helpers ---------------------------------------------------------------

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Err2($msg) { Write-Host "    $msg" -ForegroundColor Red }

function Test-WingetAvailable {
    $cmd = Get-Command winget -ErrorAction SilentlyContinue
    return [bool]$cmd
}

function Test-WingetPackageInstalled {
    param([string]$Id)
    # winget list returns 0 if installed, non-zero otherwise. We also parse the
    # output because some configurations return 0 with "no installed package
    # found" text.
    $out = winget list --id $Id --exact --accept-source-agreements 2>&1
    if ($LASTEXITCODE -ne 0) { return $false }
    # If the ID appears in output as its own token, treat as installed.
    return ($out -match [regex]::Escape($Id))
}

function Ensure-WingetPackage {
    param(
        [string]$Name,
        [string]$Id,
        [switch]$SkipUpgrade
    )

    Write-Step "Checking $Name ($Id)..."
    if (Test-WingetPackageInstalled -Id $Id) {
        if ($SkipUpgrade) {
            Write-Ok "$Name already installed; skipping (per -NoUpgrade)."
            return
        }
        Write-Ok "$Name already installed. Checking for upgrade..."
        $out = winget upgrade --id $Id --exact --silent `
            --accept-source-agreements --accept-package-agreements 2>&1
        # Exit codes: 0 = upgraded, 0x8A150006 / specific text = nothing to do.
        if ($LASTEXITCODE -eq 0) {
            if ($out -match 'No applicable upgrade|No installed package found matching') {
                Write-Ok "$Name is up to date."
            } else {
                Write-Ok "$Name upgraded."
            }
        } else {
            # Treat "nothing to upgrade" non-zero codes as success.
            if ($out -match 'No applicable upgrade|up to date') {
                Write-Ok "$Name is up to date."
            } else {
                Write-Warn2 "winget upgrade returned $LASTEXITCODE for $Name."
                Write-Warn2 ($out -join "`n")
            }
        }
    } else {
        Write-Step "Installing $Name..."
        $out = winget install --id $Id --exact --silent `
            --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Err2 "winget install failed for $Name (exit $LASTEXITCODE)."
            Write-Err2 ($out -join "`n")
            throw "Failed to install $Name."
        }
        Write-Ok "$Name installed."
    }
}

function Get-VSCodePaths {
    foreach ($base in @($UserInstallPath, $SystemInstallPath)) {
        $codeCmd = Join-Path $base 'bin\code.cmd'
        if (Test-Path $codeCmd) {
            return [pscustomobject]@{
                InstallDir = $base
                CodeCmd    = $codeCmd
            }
        }
    }
    return $null
}

function Install-VSCode {
    param([switch]$System)

    $arch = if ([Environment]::Is64BitOperatingSystem) { 'x64' } else { '' }
    if ($System) {
        $url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-$arch"
    } else {
        $url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-$arch-user"
    }

    $installer = Join-Path $env:TEMP "vscode-installer-$([guid]::NewGuid()).exe"
    Write-Step "Downloading VS Code installer..."
    Write-Host "    URL: $url"
    Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing
    Write-Ok "Saved to $installer"

    Write-Step "Running VS Code installer silently..."
    $args = @(
        '/VERYSILENT', '/NORESTART', '/SP-',
        '/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,addtopath'
    )
    $proc = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "VS Code installer exited with code $($proc.ExitCode)."
    }
    Remove-Item $installer -Force -ErrorAction SilentlyContinue
    Write-Ok "VS Code installed."
}

function Ensure-Extensions {
    param([string]$CodeCmd, [string[]]$Wanted)

    Write-Step "Querying installed VS Code extensions..."
    $installedRaw = & $CodeCmd --list-extensions 2>$null
    $installed = @($installedRaw | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
    Write-Host "    Currently installed: $($installed.Count)"

    foreach ($ext in $Wanted) {
        $key = $ext.ToLowerInvariant()
        if ($installed -contains $key) {
            Write-Ok "Already installed: $ext"
        } else {
            Write-Step "Installing extension: $ext"
            $out = & $CodeCmd --install-extension $ext --force 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Err2 "Failed to install $ext"
                Write-Err2 ($out -join "`n")
            } else {
                Write-Ok "Installed $ext"
            }
        }
    }
}

function Deploy-ConfigFile {
    param(
        [string]$Url,
        [string]$DestPath,
        [switch]$Backup
    )

    $destDir = Split-Path $DestPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if ((Test-Path $DestPath) -and $Backup) {
        $stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$DestPath.$stamp.bak"
        Copy-Item $DestPath $backup -Force
        Write-Ok "Backed up existing file to $backup"
    }

    Write-Step "Downloading $Url"
    $tmp = "$DestPath.download"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
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

# Step 1: Git and PowerToys via winget
Write-Step "Checking winget availability..."
if (Test-WingetAvailable) {
    Write-Ok "winget found."
    foreach ($pkg in $WingetPackages) {
        Ensure-WingetPackage -Name $pkg.Name -Id $pkg.Id -SkipUpgrade:$NoUpgrade
    }
} else {
    Write-Warn2 "winget not available. Install App Installer from the Microsoft Store,"
    Write-Warn2 "or install Git and PowerToys manually:"
    Write-Warn2 "  Git:        https://git-scm.com/download/win"
    Write-Warn2 "  PowerToys:  https://github.com/microsoft/PowerToys/releases"
    Write-Warn2 "Continuing with VS Code setup..."
}

# Step 2: VS Code
Write-Step "Checking for Visual Studio Code..."
$vscode = Get-VSCodePaths
if (-not $vscode) {
    Write-Warn2 "VS Code not found in standard locations."
    Install-VSCode -System:$SystemInstall
    $vscode = Get-VSCodePaths
    if (-not $vscode) {
        throw "Installation finished but VS Code was not detected at expected paths."
    }
} else {
    Write-Ok "Found VS Code at $($vscode.InstallDir)"
}

# Step 3: Extensions
Ensure-Extensions -CodeCmd $vscode.CodeCmd -Wanted $Extensions

# Step 4: Settings files
$userDir       = Join-Path $env:APPDATA 'Code\User'
$settingsPath  = Join-Path $userDir 'settings.json'
$keybindsPath  = Join-Path $userDir 'keybindings.json'

Deploy-ConfigFile -Url $SettingsUrl    -DestPath $settingsPath -Backup:$BackupExisting
Deploy-ConfigFile -Url $KeybindingsUrl -DestPath $keybindsPath -Backup:$BackupExisting

Write-Host ""
Write-Step "Done."