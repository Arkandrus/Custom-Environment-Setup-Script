# Custom Environment Setup Script

Bootstraps a Windows workstation with Git, PowerToys, VS Code, a curated set
of VS Code extensions, and personal `settings.json` / `keybindings.json`.

## Usage

### One-liner (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Arkandrus/Custom-Environment-Setup-Script/main/setup.ps1 | iex
```

### Download and run

```powershell
# Clone or download as ZIP, then:
.\setup.ps1 -LocalConfigDir $PSScriptRoot
```

### Options

- `-BackupExisting` — back up existing settings before overwriting.
- `-SystemInstall` — system-wide VS Code install (requires admin).
- `-NoUpgrade` — don't upgrade Git/PowerToys if already installed.
- `-SkipPowerToys` — skip PowerToys (useful on Windows Server).

# nuget-feed-setup.ps1

Registers a private NuGet feed as a user-scoped source via the `dotnet` CLI
and installs the **Azure Artifacts Credential Provider** so authenticated
feeds (e.g. Azure DevOps) can prompt for interactive sign-in on first restore.

Idempotent — safe to re-run.

> **Prerequisite:** the .NET SDK must already be installed and `dotnet`
> must be on `PATH`. Install it separately from
> [dot.net](https://dot.net) or via your package manager of choice.

---

## Usage

### Register an authenticated feed (e.g. Azure DevOps)

```powershell
.\nuget-feed-setup.ps1 `
    -FeedName 'MyFeed' `
    -FeedUrl  'https://pkgs.dev.azure.com/Org/Project/_packaging/MyFeed/nuget/v3/index.json'
```

### Register a public feed (skip the credential provider)

```powershell
.\nuget-feed-setup.ps1 `
    -FeedName 'PublicMirror' `
    -FeedUrl  'https://example.com/nuget/v3/index.json' `
    -SkipCredProvider
```

---

## Parameters

| Name                 | Type     | Required | Description                                                                  |
| -------------------- | -------- | -------- | ---------------------------------------------------------------------------- |
| `-FeedName`          | `string` | **Yes**  | Name to register the NuGet source under.                                     |
| `-FeedUrl`           | `string` | **Yes**  | NuGet v3 feed URL (an `index.json` endpoint).                                |
| `-SkipCredProvider`  | `switch` | No       | Skip the Azure Artifacts Credential Provider install. Use for public feeds. |

---

## Behavior

1. **Credential provider** (unless `-SkipCredProvider`):
   - If `CredentialProvider.Microsoft.dll` already exists under
     `%USERPROFILE%\.nuget\plugins`, the install step is skipped.
   - Otherwise, runs Microsoft's installer from
     `https://aka.ms/install-artifacts-credprovider.ps1`.
   - Failures here are surfaced as warnings and **do not abort** the script.
2. **NuGet source registration** (always runs):
   - Calls `dotnet nuget list source` to inspect current state.
   - If the URL is already registered → no-op.
   - If the same `-FeedName` exists with a different URL →
     `dotnet nuget update source`.
   - Otherwise → `dotnet nuget add source`.
   - Sources are written to the user-scoped
     `%AppData%\NuGet\NuGet.Config`.
3. On first `dotnet restore` against an authenticated feed, a browser
   window opens for sign-in. The credential provider caches the token.

---

## Requirements

- Windows 11, Windows Server 2022, or Windows Server 2025.
- PowerShell 5.1 or later.
- `dotnet` CLI on `PATH`.
- Network access to:
  - `https://aka.ms` (credential provider redirect, unless `-SkipCredProvider`)
  - Your NuGet feed host.

No admin rights required — everything is user-scoped.

---

## Exit codes

| Code     | Meaning                                                                       |
| -------- | ----------------------------------------------------------------------------- |
| `0`      | All requested steps completed.                                                |
| non-zero | `dotnet` is missing, or the `dotnet nuget` command returned a non-zero exit.  |

A credential-provider install failure produces a warning only — the script
continues and attempts to register the source.

---

## Notes

- The credential provider install uses `irm | iex` against an `aka.ms`
  redirect. This is Microsoft's documented install method but is still
  a remote-execution pattern; be aware in locked-down environments.
- Solution-level `nuget.config` files in a repo override the user-scoped
  config. If a registered source seems "ignored" inside a repo, check
  for a local `nuget.config`.