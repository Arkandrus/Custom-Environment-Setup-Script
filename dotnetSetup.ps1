<#
.SYNOPSIS
    Install .NET 10 SDK and optionally register a private NuGet feed.

.DESCRIPTION
    Installs:
      - .NET 10 SDK (via winget)
      - Azure Artifacts Credential Provider (only if -FeedUrl is provided)
      - Registers the given feed as a user-scoped NuGet source

    Safe to re-run. Each step is idempotent.

    Usage:
      .\dotnet-setup.ps1
      .\dotnet-setup.ps1 -FeedName 'MyFeed' -FeedUrl 'https://example/index.json'

.PARAMETER SkipDotNet
    Skip the .NET 10 SDK install/upgrade.

.PARAMETER NoUpgrade
    Do not attempt to upgrade .NET 10 SDK if a 10.x is already installed.

.PARAMETER FeedName
    NuGet source name. Required together with -FeedUrl.

.PARAMETER FeedUrl
    NuGet source URL (v3 index.json). If omitted, no feed is configured
    and the credential provider is not installed.
#>
[CmdletBinding()]
param(
    [switch]$SkipDotNet,
    [switch]$NoUpgrade,

    [string]$FeedName,
    [string]$FeedUrl
)

$ErrorActionPreference = 'Stop'

# --- Helpers ---------------------------------------------------------------

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Err2($msg) { Write-Host "    $msg" -ForegroundColor Red }

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path','User')
}

function Test-Winget {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

# --- .NET 10 SDK -----------------------------------------------------------

function Ensure-DotNetSDK {
    param([switch]$SkipUpgrade)
    Write-Step "Checking for .NET 10 SDK..."

    $has10 = $false
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($dotnet) {
        $sdks = & dotnet --list-sdks 2>$null
        if ($sdks -match '^10\.') {
            Write-Ok "Found .NET 10 SDK."
            $has10 = $true
        } else {
            Write-Warn2 "dotnet CLI present but no 10.x SDK installed."
        }
    } else {
        Write-Warn2 "dotnet CLI not found."
    }

    if (-not $has10) {
        if (-not (Test-Winget)) {
            throw "winget not available. Install 'App Installer' from the Microsoft Store, or install the .NET 10 SDK manually from https://dot.net"
        }
        Write-Step "Installing .NET 10 SDK via winget..."
        $args = @('install','--id','Microsoft.DotNet.SDK.10',
                  '--exact','--silent',
                  '--accept-source-agreements','--accept-package-agreements')
        & winget @args
        # -1978335189 = already installed
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
            throw "winget failed for Microsoft.DotNet.SDK.10 (exit $LASTEXITCODE)"
        }
        Refresh-Path
        Write-Ok ".NET 10 SDK installed."
    } elseif (-not $SkipUpgrade) {
        Write-Step "Attempting .NET 10 SDK upgrade (silent)..."
        & winget upgrade --id Microsoft.DotNet.SDK.10 --silent `
            --accept-source-agreements --accept-package-agreements 2>$null | Out-Null
        Refresh-Path
    }

    # Final sanity print
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($dotnet) {
        $ver = & dotnet --version 2>$null
        Write-Ok "Active dotnet --version: $ver"
    } else {
        Write-Warn2 "dotnet still not on PATH in this session. Open a new shell."
    }
}

# --- Azure Artifacts Credential Provider -----------------------------------

function Ensure-AzureArtifactsCredProvider {
    Write-Step "Installing Azure Artifacts Credential Provider..."
    $providerDir = Join-Path $env:USERPROFILE '.nuget\plugins'
    if (Test-Path $providerDir) {
        $found = Get-ChildItem $providerDir -Recurse -Filter 'CredentialProvider.Microsoft.dll' `
                 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            Write-Ok "Credential provider already present: $($found.FullName)"
            return
        }
    }

    $script = 'https://aka.ms/install-artifacts-credprovider.ps1'
    try {
        Invoke-Expression "& { $(Invoke-RestMethod $script) }"
        Write-Ok "Credential provider installed."
    } catch {
        Write-Warn2 "Credential provider install failed: $($_.Exception.Message)"
        Write-Warn2 "Install manually later from $script"
    }
}

# --- NuGet source ----------------------------------------------------------

function Ensure-NuGetSource {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url
    )
    Write-Step "Configuring NuGet source '$Name'..."

    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        Write-Warn2 "dotnet CLI not on PATH; skipping NuGet source setup."
        Write-Warn2 "Re-run this script in a new shell after .NET install."
        return
    }

    $list = & dotnet nuget list source 2>$null | Out-String

    if ($list -match [regex]::Escape($Url)) {
        Write-Ok "Source already registered (URL match)."
        return
    }

    if ($list -match "(?m)^\s*\d+\.\s+$([regex]::Escape($Name))\s") {
        Write-Warn2 "A source named '$Name' exists with a different URL. Updating..."
        & dotnet nuget update source $Name --source $Url | Out-Null
    } else {
        & dotnet nuget add source $Url --name $Name | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Ok "NuGet source '$Name' configured."
        Write-Host ""
        Write-Host "    If this is an authenticated feed, the first 'dotnet restore'" -ForegroundColor DarkGray
        Write-Host "    may open a browser for sign-in. Token is then cached." -ForegroundColor DarkGray
    } else {
        Write-Warn2 "dotnet nuget exited with $LASTEXITCODE."
    }
}

# --- Main ------------------------------------------------------------------

if ($SkipDotNet) {
    Write-Warn2 "Skipping .NET SDK setup (per -SkipDotNet)."
} else {
    Ensure-DotNetSDK -SkipUpgrade:$NoUpgrade
}

# Validate feed parameter pairing
$hasName = -not [string]::IsNullOrWhiteSpace($FeedName)
$hasUrl  = -not [string]::IsNullOrWhiteSpace($FeedUrl)

if ($hasName -xor $hasUrl) {
    throw "-FeedName and -FeedUrl must be provided together."
}

if ($hasName -and $hasUrl) {
    Ensure-AzureArtifactsCredProvider
    Ensure-NuGetSource -Name $FeedName -Url $FeedUrl
} else {
    Write-Warn2 "No -FeedName/-FeedUrl provided; skipping NuGet source setup."
}

Write-Step "Done."