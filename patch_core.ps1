$script:PatchVersion = "1.0.5"
$script:PatchRvas = @(0x22F6D00, 0x22F7310, 0x22F7B80)
$script:OldRel = 0xBD
$script:NewRel = 0xB7
$script:Pattern = [byte[]](0x83, 0x78, 0x24, 0x01, 0x0F, 0x84)

function Get-RvaOffset([int]$Rva) { return 0x400 + ($Rva - 0x1000) }

function Test-GameFolder([string]$GameRoot) {
    $root = [System.IO.Path]::GetFullPath($GameRoot)
    $dll = Join-Path $root "GameAssembly.dll"
    $exe = Join-Path $root "HeroesOldenEra.exe"
    if (-not (Test-Path $dll)) { return "GameAssembly.dll not found" }
    if (-not (Test-Path $exe)) { return "HeroesOldenEra.exe not found" }
    return $null
}

function Get-PatchPaths([string]$GameRoot) {
    $root = [System.IO.Path]::GetFullPath($GameRoot)
    return @{
        Root   = $root
        Dll    = Join-Path $root "GameAssembly.dll"
        Backup = Join-Path $root "GameAssembly.dll.simturns_backup"
        Marker = Join-Path $root "SimTurnsAI_Patch.installed"
    }
}

function Find-GameFolders() {
    $candidates = New-Object System.Collections.Generic.List[string]
    $names = @(
        "Heroes of Might and Magic - Olden Era",
        "Heroes of Might and Magic Olden Era"
    )
    $roots = @(
        ${env:ProgramFiles},
        ${env:ProgramFiles(x86)},
        "C:\Games",
        "D:\Games",
        "D:\SteamLibrary\steamapps\common",
        "E:\SteamLibrary\steamapps\common"
    )
    if ($env:SteamPath) { $roots += Join-Path $env:SteamPath "steamapps\common" }
    foreach ($steam in @(
        "C:\Program Files (x86)\Steam\steamapps\common",
        "C:\Program Files\Steam\steamapps\common",
        "D:\Steam\steamapps\common"
    )) { if ($roots -notcontains $steam) { $roots += $steam } }

    foreach ($base in $roots) {
        if (-not $base -or -not (Test-Path $base)) { continue }
        foreach ($name in $names) {
            $path = Join-Path $base $name
            if ((Test-Path $path) -and -not $candidates.Contains($path)) {
                if (-not (Test-GameFolder $path)) { $candidates.Add($path) }
            }
        }
    }
    return $candidates
}

function Get-PatchStatus([string]$GameRoot) {
    $err = Test-GameFolder $GameRoot
    if ($err) { return @{ Ok = $false; Message = $err; State = "invalid" } }

    $paths = Get-PatchPaths $GameRoot
    $bytes = [System.IO.File]::ReadAllBytes($paths.Dll)
    $states = @()

    foreach ($rva in $script:PatchRvas) {
        $offset = Get-RvaOffset $rva
        $match = $true
        for ($i = 0; $i -lt $script:Pattern.Length; $i++) {
            if ($bytes[$offset + $i] -ne $script:Pattern[$i]) { $match = $false; break }
        }
        if (-not $match) {
            $states += "version_mismatch"
            continue
        }
        $b = $bytes[$offset + 6]
        if ($b -eq $script:NewRel) { $states += "patched" }
        elseif ($b -eq $script:OldRel) { $states += "vanilla" }
        else { $states += ("unknown_0x{0:X2}" -f $b) }
    }

    $patched = ($states | Where-Object { $_ -eq "patched" }).Count
    $vanilla = ($states | Where-Object { $_ -eq "vanilla" }).Count

    if ($patched -eq 3) {
        return @{ Ok = $true; Message = "Patch installed"; State = "installed"; Sites = $states }
    }
    if ($vanilla -eq 3) {
        return @{ Ok = $true; Message = "Vanilla (no patch)"; State = "vanilla"; Sites = $states }
    }
    return @{ Ok = $false; Message = "Broken or incompatible"; State = "broken"; Sites = $states }
}

function Install-Patch([string]$GameRoot) {
    $err = Test-GameFolder $GameRoot
    if ($err) { throw $err }

    $paths = Get-PatchPaths $GameRoot
    if (-not (Test-Path $paths.Backup)) {
        Copy-Item $paths.Dll $paths.Backup
    }

    $bytes = [System.IO.File]::ReadAllBytes($paths.Dll)
    $changed = 0
    $log = New-Object System.Collections.Generic.List[string]

    foreach ($rva in $script:PatchRvas) {
        $offset = Get-RvaOffset $rva
        for ($i = 0; $i -lt $script:Pattern.Length; $i++) {
            if ($bytes[$offset + $i] -ne $script:Pattern[$i]) {
                throw ("Patch mismatch at RVA 0x{0:X}. Update the game or get a new patch version." -f $rva)
            }
        }
        $relOffset = $offset + 6
        if ($bytes[$relOffset] -eq $script:NewRel) {
            $log.Add(("Already patched: 0x{0:X}" -f $rva))
            continue
        }
        if ($bytes[$relOffset] -ne $script:OldRel) {
            throw ("Patch mismatch at 0x{0:X}, byte 0x{1:X2}" -f $rva, $bytes[$relOffset])
        }
        $bytes[$relOffset] = $script:NewRel
        $changed++
        $log.Add(("Patched: 0x{0:X}" -f $rva))
    }

    if ($changed -gt 0) {
        [System.IO.File]::WriteAllBytes($paths.Dll, $bytes)
        $log.Add("Changed bytes: $changed")
    } else {
        $log.Add("Patch was already installed.")
    }

    "version=$($script:PatchVersion)`ngame=$($paths.Root)" | Set-Content -Path $paths.Marker -Encoding UTF8
    return $log
}

function Uninstall-Patch([string]$GameRoot) {
    $paths = Get-PatchPaths $GameRoot
    if (-not (Test-Path $paths.Backup)) {
        throw "Backup not found. Cannot restore original GameAssembly.dll."
    }
    Copy-Item $paths.Backup $paths.Dll -Force
    if (Test-Path $paths.Marker) { Remove-Item $paths.Marker -Force }
    return @("Original GameAssembly.dll restored.")
}
