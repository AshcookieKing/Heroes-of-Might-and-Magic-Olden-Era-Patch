$ErrorActionPreference = "Stop"
$PatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $PatchDir "patch_core.ps1")
$GameRoot = Split-Path -Parent $PatchDir
Install-Patch $GameRoot | ForEach-Object { Write-Host $_ }
