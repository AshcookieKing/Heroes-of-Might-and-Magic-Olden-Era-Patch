# Called by Inno Setup after install. Applies patch to game folder.
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "patch_core.ps1")

$err = Test-GameFolder $GameRoot
if ($err) { throw $err }

$lines = Install-Patch $GameRoot
$lines | ForEach-Object { Write-Output $_ }
Write-Output "[OK] Patch installed to: $GameRoot"
