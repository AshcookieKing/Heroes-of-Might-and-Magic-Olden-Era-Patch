$ErrorActionPreference = "Stop"
$PatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $PatchDir "patch_core.ps1")
$found = Find-GameFolders
if ($found.Count -eq 0) { throw "Game not found. Pass path manually." }
Uninstall-Patch $found[0] | ForEach-Object { Write-Host $_ }
Write-Host "[OK] Restored."
