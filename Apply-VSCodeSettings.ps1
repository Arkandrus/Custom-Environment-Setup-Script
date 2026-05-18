$scriptDir = $PSScriptRoot
$target = "$env:APPDATA\Code\User"

$files = @("settings.json", "keybindings.json")

foreach ($file in $files) {
    $src = Join-Path $scriptDir $file
    if (-not (Test-Path $src)) {
        Write-Error "Source not found: $src"
        exit 1
    }
    Copy-Item -Path $src -Destination (Join-Path $target $file) -Force
    Write-Host "Applied $file -> $target"
}
