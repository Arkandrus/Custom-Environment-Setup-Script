<#
.SYNOPSIS
    Register a private NuGet feed and install the Azure Artifacts
    Credential Provider for authenticated feeds.

.DESCRIPTION
    Configures a user-scoped NuGet source via the dotnet CLI and installs
    the Azure Artifacts Credential Provider so that the first
    'dotnet restore' against an authenticated feed can prompt for
    interactive sign-in.

    Idempotent — safe to re-run.

    The .NET SDK must be installed separately (e.g. via winget,
    'dotnet-install.ps1', or the official MSI from https://dot.net).

.PARAMETER FeedName
    Name to register the NuGet source under. Required.

.PARAMETER FeedUrl
    NuGet v3 feed URL (an index.json endpoint). Required.

.PARAMETER SkipCredProvider
    Do not install the Azure Artifacts Credential Provider.
    Use for public feeds or when the provider is managed separately.

.EXAMPLE
    .\nuget-feed-setup.ps1 -FeedName 'MyFeed' -FeedUrl 'https://pkgs.dev.azure.com/Org/Project/_packaging/MyFeed/nuget/v3/index.json'

.EXAMPLE
    .\nuget-feed-setup.ps1 -FeedName 'PublicMirror' -FeedUrl 'https://example.com/nuget/v3/index.json' -SkipCredProvider

.NOTES
    Exit codes:
      0   Success
      non-zero   A required step failed (dotnet missing, source command failed, etc.)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FeedName,
    [Parameter(Mandatory)][string]$FeedUrl,
    [switch]$SkipCredProvider
)

$ErrorActionPreference = 'Stop'

# --- Helpers ---------------------------------------------------------------

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }
function Write-Err2($msg) { Write-Host "    $msg" -ForegroundColor Red }

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
        throw "dotnet CLI not found on PATH. Install the .NET SDK first (https://dot.net) and re-run."
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
        throw "dotnet nuget exited with $LASTEXITCODE."
    }
}

# --- Main ------------------------------------------------------------------

if (-not $SkipCredProvider) {
    Ensure-AzureArtifactsCredProvider
} else {
    Write-Warn2 "Skipping credential provider install (per -SkipCredProvider)."
}

Ensure-NuGetSource -Name $FeedName -Url $FeedUrl

Write-Step "Done."