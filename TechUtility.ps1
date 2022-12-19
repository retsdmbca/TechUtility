Add-Type -AssemblyName PresentationCore,PresentationFramework
$outputfile = "C:\ProgramData\RETSD\Tech Utility App\TU.LOG"
$computername = Get-Content env:computername
$OSBuild = (Get-ComputerInfo OsHardwareAbstractionLayer).OsHardwareAbstractionLayer
$SerialNumber = (Get-ComputerInfo BiosSeralNumber).BiosSeralNumber
$version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
$BIOS = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$permissions = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$state = get-content "C:\ProgramData\RETSD\Tech Utility App\state.txt"

### Function to End Tasks ###
Function Running{$Labeloutput.Text = "Script Output: Program Running"}
Function ResetLabel{$Labeloutput.Text = "Script Output"}

Function EndTask($taskname) {
    Stop-Process -name "$taskname" -Force
    $ProcessList = @("$taskname")
    Do {
        $ProcessesFound = Get-Process | Where-Object {$ProcessList -contains $_.Name} | Select-Object -ExpandProperty Name
        If ($ProcessesFound) {Start-Sleep 2}
    } Until (!$ProcessesFound)
}
function Test-RegistryValue {
	param (
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]$Path,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]$Value
	)
	try {
		Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
		return $true
	}
	catch {return $false}
}

$usercount=0
$users = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | ForEach-Object { $_.GetValue('ProfileImagePath') }
foreach ($user in $Users) {if($user -notlike '*systemprofile*' -and $user -notlike '*LocalService*' -and $user -notlike '*NetworkService*' -and $user -notlike '*Administrator*' -and $user -notlike '*jbergen*') {$usercount++}}

### Clear Teams Cache ###
Function ClearTeamsCache {
    Running
    EndTask teams  
    $folder = $env:APPDATA + '\microsoft\teams'
    remove-item -Recurse -Force $folder
    $TextBoxOutput.text = "Teams Cache has been cleared"
    ResetLabel
}
################################################################################################

### Repair Onedrive ###
Function RepairOnedrive {
    Running
    EndTask onedrive

    Remove-Item -Recurse -Force -ErrorAction Ignore "C:\Users\$env:UserName\AppData\Local\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction Ignore "C:\Users\$env:UserName\AppData\Local\Microsoft\OneDrive"
    $TextBoxOutput.text = "You can now open Onedrive manually from the Start Menu.  Installer can be found in \\ao-sccm\MS\OneDrive 21"
    ResetLabel
}

################################################################################################

### Remove Local Profiles ###
Function RemoveProfiles {
    Running
    $i=1
    $reg = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MpsSvc | Select-Object -ExpandProperty Start
    if ($reg -eq "4") {
        New-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MpsSvc -Name Start -Value "2" -Force
        $TextBoxOutput.text = "The Windows firewall was not ON, regkey changed and computer needs to be restarted before trying again"
    }
    if([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
        (Get-WmiObject -Class Win32_UserProfile | Where-Object {($_.Special -eq $false) -and ($_.Loaded -eq $False) -and ($_.SID -ne "S-1-5-21-3830986519-219807107-1256945042-500")}) | ForEach-Object{
            $TextBoxOutput.text = "Removing profile $($i) of $($usercount)"
            $progressbar1.PerformStep()
            $_.Delete()
            $i++
        }
    }
    $TextBoxOutput.text = "User profiles have been removed"
    ResetLabel
}

################################################################################################

### Rerun RETSD Wallpaper Deployment ###   Add info for
Function RegenerateWallpaper {
    Running
    if (test-path 'C:\ProgramData\RETSD\RETSD Wallpaper'){Remove-Item -Recurse -Force 'C:\ProgramData\RETSD\RETSD Wallpaper'}
    if (Test-RegistryValue -Path 'HKLM:\SOFTWARE\RETSD' -Value 'Desktop Wallpaper Version' -ErrorAction SilentlyContinue) {Remove-ItemProperty -name "Desktop Wallpaper Version" -Path 'HKLM:\Software\RETSD'}
    $TextBoxOutput.text = "Wallpaper will be regenerated"
    ResetLabel
}


################################################################################################

### Get Autopilot HWID file ###
Function AutopilotHWID {
    Running
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Script -name Get-WindowsAutopilotInfo -Force
    $APfilename = "c:\$($computername) AutopilotHWIDs.csv"
    Get-WindowsAutoPilotInfo -OutputFile $APfilename

    #Sanity Check
    $Sanity = Import-Csv -Path $APfilename | Where-Object {$_.'Device Serial Number' -eq ((Get-CimInstance win32_bios | Select-Object serialnumber).serialnumber)}
    if($Sanity.'Device Serial Number'.Count -eq 1){$TextBoxOutput.text = "Serial number imported into $APfilename successfully"}
    else{$TextBoxOutput.text = "Serial number DID NOT import into $APfilename"}
    ResetLabel
}

#################################################################################

### Upload HWID ###
Function UploadHWID {
    Running
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Script -name Get-WindowsAutopilotInfo -Force
    $TextBoxOutput.text = "Process has begun, it may take a few minutes to complete."
    $grouptag = 'NoAdmin_Staff_Assigned','NoAdmin_Staff_Shared','French_Staff_Shared','NoAdmin_Student_Shared','LOM_Student_Shared' | Out-GridView -Title "Select Group Tag" -PassThru

    Get-WindowsAutoPilotInfo -Online -GroupTag $grouptag
    $TextBoxOutput.text = "Upload has completed.  Please verify in Intune."
    ResetLabel
}

#################################################################################

### Remove Unnecessary Icons ###
Function RemoveIcons {
    Running
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /V PenWorkspaceButtonDesiredVisibility /T REG_DWORD /D 0 /F
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /V EnableFeeds /T REG_DWORD /D 0 /F
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V ShowCortanaButton /T REG_DWORD /D 0 /F
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V ShowTaskViewButton /T REG_DWORD /D 0 /F
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 0

    $apps = "Microsoft Store","Mail"
    foreach ($appname in $apps) {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object{$_.DoIt(); $exec = $true}
    }
    taskkill /f /im explorer.exe
    start-process explorer.exe
    $TextBoxOutput.text = "Taskbar items removed. (Windows Ink Workspace, News Feed, Cortana Button, Taskview Button, Search Box, MS Store Icon, Mail Icon)"
    ResetLabel
}

#################################################################################

### Repair Windows Update ###
Function RepairWindows{
    Running
    if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\Logs")) {New-Item -Path "C:\ProgramData\RETSD\Logs" -ItemType directory}
    $date = get-date -f yyyy-MM-dd
    $TextBoxOutput.text = "Stopping Services"
    Stop-Service wuauserv -Force
    Stop-Service cryptSvc -Force
    Stop-Service bits -Force
    Stop-Service msiserver -Force
    Start-Sleep -s 4
    try {
        Rename-item C:\Windows\System32\catroot2 Catroot2.old -force
        Rename-item C:\Windows\SoftwareDistribution SoftwareDistribution.old -force 
        
    } catch {
        $ErrorMessage = $_.Exception.Message
        $TextBoxOutput.text =  $errormessage
    }
    $TextBoxOutput.AppendText("`r`n")
    $TextBoxOutput.AppendText("Restarting Services`r`n")
    Start-Service wuauserv
    Start-Service cryptSvc
    Start-Service bits
    Start-Service msiserver
    $TextBoxOutput.AppendText("Opening Log file with CMTRACE.  Click YES to both pop up windows`r`n")
    Start-Sleep -s 10
    if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
    
    start-process C:\ProgramData\RETSD\CMTrace.exe "C:\ProgramData\RETSD\Logs\$($date)-WindowsUpdate.log"
    $TextBoxOutput.AppendText("Installing Packages`r`n")
    install-packageprovider -name NuGet -MinimumVersion 2.8.5.201 -force
    Install-Module PSWindowsUpdate -force
    $TextBoxOutput.AppendText("Beginning Updates`r`n")
    install-windowsupdate -AcceptAll -install -IgnoreReboot | Out-File "C:\ProgramData\RETSD\Logs\$($date)-WindowsUpdate.log" -force
    write-output "Windows Update script finished" | out-file -filepath "C:\ProgramData\RETSD\\Logs\$($date)-WindowsUpdate.log" -append
    $TextBoxOutput.AppendText("Updates Completed`r`n")
    ResetLabel
}

#################################################################################

### Check Encryption Status ###
Function EncryptionStatus {
    Running
    $status = Get-BitLockerVolume -MountPoint c
    $TextBoxOutput.text = "Encryption at $($status.EncryptionPercentage)%"
    ResetLabel
}

endtask TechUtilityLauncher

#################################################################################

Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
if ($permissions -eq $true) {$main_form.Text ='Tech Utility [Administrator]'}
if ($permissions -eq $false) {$main_form.Text ='Tech Utility'}
#$main_form.Text ='Tech Utility'
$main_form.Width = 800
$main_form.Height = 600
$main_form.AutoSize = $true
$main_form.StartPosition = 'CenterScreen'
$main_form.FormBorderStyle = 'Fixed3D'
$main_form.AutoSize = $false
$main_form.MaximizeBox = $false

$Labeloutput = New-Object System.Windows.Forms.Label
$Labeloutput.Text = "Script Output"
$Labeloutput.Location  = New-Object System.Drawing.Point(10,400)
$Labeloutput.AutoSize = $true
$main_form.Controls.Add($Labeloutput)

$TextBoxOutput = New-Object system.Windows.Forms.TextBox
$TextBoxOutput.multiline = $true
$TextBoxOutput.width = 760
$TextBoxOutput.height = 70
$TextBoxOutput.ScrollBars = "Vertical"
$TextBoxOutput.location = New-Object System.Drawing.Point(10,420)
$main_form.Controls.Add($TextBoxOutput)

$Buttonencrypt = New-Object System.Windows.Forms.Button
$Buttonencrypt.Location = New-Object System.Drawing.Size(10,10)
$Buttonencrypt.Size = New-Object System.Drawing.Size(160,23)
$Buttonencrypt.Text = "Encryption Status"
$Buttonencrypt.Add_Click({EncryptionStatus})
$main_form.Controls.Add($Buttonencrypt)

$ButtonIcons = New-Object System.Windows.Forms.Button
$ButtonIcons.Location = New-Object System.Drawing.Size(10,60)
$ButtonIcons.Size = New-Object System.Drawing.Size(160,23)
$ButtonIcons.Text = "Remove Icons"
$ButtonIcons.Add_Click({RemoveIcons})
$main_form.Controls.Add($ButtonIcons)

$ButtonWallpaper = New-Object System.Windows.Forms.Button
$ButtonWallpaper.Location = New-Object System.Drawing.Size(10,110)
$ButtonWallpaper.Size = New-Object System.Drawing.Size(160,23)
$ButtonWallpaper.Text = "Regenerate Wallpaper"
$ButtonWallpaper.Add_Click({RegenerateWallpaper})
$main_form.Controls.Add($ButtonWallpaper)

$ButtonTeams = New-Object System.Windows.Forms.Button
$ButtonTeams.Location = New-Object System.Drawing.Size(10,160)
$ButtonTeams.Size = New-Object System.Drawing.Size(160,23)
$ButtonTeams.Text = "Clear Teams Cache"
$ButtonTeams.Add_Click({ClearTeamsCache})
$main_form.Controls.Add($ButtonTeams)

$ButtonOnedrive = New-Object System.Windows.Forms.Button
$ButtonOnedrive.Location = New-Object System.Drawing.Size(10,210)
$ButtonOnedrive.Size = New-Object System.Drawing.Size(160,23)
$ButtonOnedrive.Text = "Repair Onedrive Client"
$ButtonOnedrive.Add_Click({RepairOnedrive})
$main_form.Controls.Add($ButtonOnedrive)

$ButtonAutopilotHWID = New-Object System.Windows.Forms.Button
$ButtonAutopilotHWID.Location = New-Object System.Drawing.Size(10,260)
$ButtonAutopilotHWID.Size = New-Object System.Drawing.Size(160,23)
$ButtonAutopilotHWID.Text = "Create AutopilotHWID"
$ButtonAutopilotHWID.Add_Click({AutopilotHWID})
$main_form.Controls.Add($ButtonAutopilotHWID)

$ButtonUploadHWID = New-Object System.Windows.Forms.Button
$ButtonUploadHWID.Location = New-Object System.Drawing.Size(10,310)
$ButtonUploadHWID.Size = New-Object System.Drawing.Size(160,23)
$ButtonUploadHWID.Text = "Upload HWID"
$ButtonUploadHWID.Add_Click({UploadHWID})
$main_form.Controls.Add($ButtonUploadHWID)

$RemoveProfiles = New-Object System.Windows.Forms.Button
$RemoveProfiles.Location = New-Object System.Drawing.Size(10,360)
$RemoveProfiles.Size = New-Object System.Drawing.Size(160,23)
$RemoveProfiles.Text = "Remove Local Profiles"
$RemoveProfiles.Add_Click({RemoveProfiles})
$main_form.Controls.Add($RemoveProfiles)

$ButtonWindowsUpdates = New-Object System.Windows.Forms.Button
$ButtonWindowsUpdates.Location = New-Object System.Drawing.Size(200,10)
$ButtonWindowsUpdates.Size = New-Object System.Drawing.Size(160,23)
$ButtonWindowsUpdates.Text = "Repair Windows Update"
$ButtonWindowsUpdates.Add_Click({RepairWindows})
$main_form.Controls.Add($ButtonWindowsUpdates)

$progressbar1 = New-Object System.Windows.Forms.ProgressBar
$progressbar1.Maximum = $usercount
$progressbar1.Step = 1
$progressbar1.Value = 0
$progressbar1.Location = New-Object System.Drawing.Size(10,500)
$progressbar1.Size = New-Object System.Drawing.Size(760,23)
$main_form.Controls.Add($progressbar1)

$TextInfo = New-Object system.Windows.Forms.TextBox
$TextInfo.multiline = $true
$TextInfo.width = 200
$TextInfo.height = 80
$TextInfo.location = New-Object System.Drawing.Point(570,10)
$TextInfo.AppendText("OS Version: " + $version + "`r`n")
$TextInfo.AppendText("BIOS: " + $BIOS + "`r`n")
$TextInfo.AppendText("SN: " + $SerialNumber + "`r`n")
$TextInfo.AppendText("Build: " + $OSBuild + "`r`n")
$TextInfo.AppendText($computername)
$main_form.Controls.Add($TextInfo)

if ($state -eq "normal") {
    $ButtonWallpaper.Enabled = $false
    $ButtonWallpaper.
    $RemoveProfiles.Enabled = $false
    $ButtonWindowsUpdates.Enabled = $false
    $ButtonAutopilotHWID.Enabled = $false
    $ButtonUploadHWID.Enabled = $false
}

$main_form.ShowDialog()