$ErrorActionPreference = "Stop"
$PatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $PatchDir "patch_core.ps1")
$GameRoot = Split-Path -Parent $PatchDir
$st = Get-PatchStatus $GameRoot
Write-Host "Game folder: $GameRoot"
Write-Host "Result: $($st.Message)"
if ($st.Sites) { Write-Host ("Sites: " + ($st.Sites -join ", ")) }
switch ($st.State) {
    "installed" { Write-Host "[OK] PATCH INSTALLED" }
    "vanilla"   { Write-Host "[--] PATCH NOT INSTALLED" }
    default     { Write-Host "[!!] PROBLEM" }
}
