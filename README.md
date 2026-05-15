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