# SimTurnsAI Patch - GUI (ASCII only, no encoding issues)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "patch_core.ps1")

$form = New-Object System.Windows.Forms.Form
$form.Text = "SimTurnsAI Patch v$PatchVersion"
$form.Size = New-Object System.Drawing.Size(680, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Location = New-Object System.Drawing.Point(15, 12)
$lblInfo.Size = New-Object System.Drawing.Size(640, 60)
$lblInfo.Text = "Select GAME folder (with HeroesOldenEra.exe), then click Install patch.`nSimultaneous turns stay ON near AI only.`nEvery multiplayer player needs this patch."
$form.Controls.Add($lblInfo)

$lblPath = New-Object System.Windows.Forms.Label
$lblPath.Location = New-Object System.Drawing.Point(15, 80)
$lblPath.Size = New-Object System.Drawing.Size(120, 20)
$lblPath.Text = "Game folder:"
$form.Controls.Add($lblPath)

$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Location = New-Object System.Drawing.Point(15, 102)
$txtPath.Size = New-Object System.Drawing.Size(520, 23)
$form.Controls.Add($txtPath)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(545, 100)
$btnBrowse.Size = New-Object System.Drawing.Size(110, 27)
$btnBrowse.Text = "Browse..."
$form.Controls.Add($btnBrowse)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(15, 132)
$lblStatus.Size = New-Object System.Drawing.Size(640, 22)
$lblStatus.Text = "Status: select game folder"
$lblStatus.ForeColor = [System.Drawing.Color]::DarkBlue
$form.Controls.Add($lblStatus)

$log = New-Object System.Windows.Forms.TextBox
$log.Location = New-Object System.Drawing.Point(15, 160)
$log.Size = New-Object System.Drawing.Size(640, 210)
$log.Multiline = $true
$log.ScrollBars = "Vertical"
$log.ReadOnly = $true
$log.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($log)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Location = New-Object System.Drawing.Point(15, 385)
$btnInstall.Size = New-Object System.Drawing.Size(150, 32)
$btnInstall.Text = "Install patch"
$form.Controls.Add($btnInstall)

$btnUninstall = New-Object System.Windows.Forms.Button
$btnUninstall.Location = New-Object System.Drawing.Point(175, 385)
$btnUninstall.Size = New-Object System.Drawing.Size(150, 32)
$btnUninstall.Text = "Uninstall"
$form.Controls.Add($btnUninstall)

$btnCheck = New-Object System.Windows.Forms.Button
$btnCheck.Location = New-Object System.Drawing.Point(335, 385)
$btnCheck.Size = New-Object System.Drawing.Size(150, 32)
$btnCheck.Text = "Check status"
$form.Controls.Add($btnCheck)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Location = New-Object System.Drawing.Point(495, 385)
$btnClose.Size = New-Object System.Drawing.Size(160, 32)
$btnClose.Text = "Close"
$form.Controls.Add($btnClose)

function Write-Log([string]$Message) { $log.AppendText("$Message`r`n") }

function Update-StatusLabel() {
    $path = $txtPath.Text.Trim()
    if (-not $path) {
        $lblStatus.Text = "Status: select game folder"
        $lblStatus.ForeColor = [System.Drawing.Color]::DarkBlue
        return
    }
    try {
        $st = Get-PatchStatus $path
        switch ($st.State) {
            "installed" {
                $lblStatus.Text = "Status: PATCH INSTALLED"
                $lblStatus.ForeColor = [System.Drawing.Color]::DarkGreen
            }
            "vanilla" {
                $lblStatus.Text = "Status: NOT INSTALLED"
                $lblStatus.ForeColor = [System.Drawing.Color]::DarkOrange
            }
            "broken" {
                $lblStatus.Text = "Status: ERROR - reinstall"
                $lblStatus.ForeColor = [System.Drawing.Color]::DarkRed
            }
            default {
                $lblStatus.Text = "Status: $($st.Message)"
                $lblStatus.ForeColor = [System.Drawing.Color]::DarkRed
            }
        }
    } catch {
        $lblStatus.Text = "Status: error"
        $lblStatus.ForeColor = [System.Drawing.Color]::DarkRed
    }
}

$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select Heroes of Might and Magic: Olden Era folder"
    $dlg.ShowNewFolderButton = $false
    if ($txtPath.Text.Trim()) { $dlg.SelectedPath = $txtPath.Text.Trim() }
    if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtPath.Text = $dlg.SelectedPath
        Update-StatusLabel
    }
})

$btnCheck.Add_Click({
    $log.Clear()
    $path = $txtPath.Text.Trim()
    if (-not $path) { [System.Windows.Forms.MessageBox]::Show("Select game folder first.") ; return }
    try {
        $st = Get-PatchStatus $path
        Write-Log "Folder: $path"
        Write-Log "Result: $($st.Message)"
        if ($st.Sites) { Write-Log ("Sites: " + ($st.Sites -join ", ")) }
        Update-StatusLabel
    } catch {
        Write-Log "ERROR: $_"
        [System.Windows.Forms.MessageBox]::Show("$_", "Error")
    }
})

$btnInstall.Add_Click({
    $log.Clear()
    $path = $txtPath.Text.Trim()
    if (-not $path) { [System.Windows.Forms.MessageBox]::Show("Select game folder first.") ; return }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Install patch to:`n$path`n`nClose the game first.",
        "Confirm", "YesNo", "Question")
    if ($confirm -ne "Yes") { return }
    try {
        $lines = Install-Patch $path
        foreach ($line in $lines) { Write-Log $line }
        Write-Log "[OK] Patch installed."
        Update-StatusLabel
        [System.Windows.Forms.MessageBox]::Show("Patch installed!", "Done")
    } catch {
        Write-Log "ERROR: $_"
        [System.Windows.Forms.MessageBox]::Show("$_", "Error")
    }
})

$btnUninstall.Add_Click({
    $log.Clear()
    $path = $txtPath.Text.Trim()
    if (-not $path) { [System.Windows.Forms.MessageBox]::Show("Select game folder first.") ; return }
    if ([System.Windows.Forms.MessageBox]::Show("Restore original files in:`n$path", "Confirm", "YesNo") -ne "Yes") { return }
    try {
        Uninstall-Patch $path | ForEach-Object { Write-Log $_ }
        Write-Log "[OK] Patch removed."
        Update-StatusLabel
        [System.Windows.Forms.MessageBox]::Show("Restored.", "Done")
    } catch {
        Write-Log "ERROR: $_"
        [System.Windows.Forms.MessageBox]::Show("$_", "Error")
    }
})

$btnClose.Add_Click({ $form.Close() })

$found = Find-GameFolders
if ($found.Count -gt 0) {
    $txtPath.Text = $found[0]
    Write-Log "Auto-detected: $($found[0])"
    Update-StatusLabel
} else {
    Write-Log "Click Browse and select folder with HeroesOldenEra.exe"
}

[void]$form.ShowDialog()
