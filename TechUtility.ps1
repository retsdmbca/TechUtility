Add-Type -AssemblyName PresentationCore,PresentationFramework
### Function to End Tasks ###
Function EndTask($taskname) {
    Stop-Process -name "$taskname" -Force
    $ProcessList = @("$taskname")
    Do {
        $ProcessesFound = Get-Process | ? {$ProcessList -contains $_.Name} | Select-Object -ExpandProperty Name
        If ($ProcessesFound) {Start-Sleep 2}
    } Until (!$ProcessesFound)
}

### Clear Teams Cache ###
Function ClearTeamsCache {
    EndTask teams  
    $folder = $env:APPDATA + '\microsoft\teams'
    remove-item -Recurse -Force $folder
}
################################################################################################

### Repair Onedrive ###
Function RepairOnedrive {
    EndTask onedrive

    rmdir -Recurse -Force -ErrorAction Ignore "C:\Users\$env:UserName\AppData\Local\OneDrive"
    rmdir -Recurse -Force -ErrorAction Ignore "C:\Users\$env:UserName\AppData\Local\Microsoft\OneDrive"
    [System.Windows.MessageBox]::Show('You can now open Onedrive manually from the Start Menu')
}

################################################################################################

### Remove Local Profiles ###
Function RemoveProfiles {
    $reg = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MpsSvc | Select-Object -ExpandProperty Start
    if ($reg -eq "4") {
        [System.Windows.MessageBox]::Show('The Windows firewall was not ON, regkey changed and computer needs to be restarted')
        New-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MpsSvc -Name Start -Value "2" -Force
        Restart-Computer -Force
    }
    if([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
        (Get-WmiObject -Class Win32_UserProfile | Where-Object {($_.Special -eq $false) -and ($_.Loaded -eq $False) -and ($_.SID -ne "S-1-5-21-3830986519-219807107-1256945042-500")}) | foreach{$_.Delete()}
    }
    [System.Windows.MessageBox]::Show('User profiles have been removed')
}

################################################################################################

### Rerun RETSD Wallpaper Deployment ###
Function RegenerateWallpaper {
    if (test-path 'C:\ProgramData\RETSD\RETSD Wallpaper'){Remove-Item -Recurse -Force 'C:\ProgramData\RETSD\RETSD Wallpaper'}
    start-sleep 3
    [System.Windows.MessageBox]::Show('Wallpaper will be regenerated')
}
################################################################################################

### Get Autopilot HWID file ###
Function AutopilotHWID {
    Install-Script -name Get-WindowsAutopilotInfo -Force
    Get-WindowsAutoPilotInfo -OutputFile "c:\AutopilotHWIDs.csv"

    #Sanity Check
    $Sanity = Import-Csv -Path "c:\AutopilotHWIDs.csv" | Where-Object {$_.'Device Serial Number' -eq ((Get-CimInstance win32_bios | Select-Object serialnumber).serialnumber)}
    if($Sanity.'Device Serial Number'.Count -eq 1){[System.Windows.MessageBox]::Show('SUCCESS: SN Appears to be in c:\AutopilotHWIDs.csv.')}
    else{[System.Windows.MessageBox]::Show('ERROR: Serial Number not found in c:\AutopilotHWIDs.csv')}
}

#################################################################################

### Upload HWID ###     NEED SOMETHING FOR NUGET PROVIDER POPUP
Function UploadHWID {
    Install-Script -name Get-WindowsAutopilotInfo -Force
    $grouptag =""
    $grouptag = 'NoAdmin_Staff_Assigned','NoAdmin_Staff_Shared','French_Staff_Shared' | Out-GridView -Title "Select Group Tag" –PassThru
    Get-WindowsAutoPilotInfo -Online -GroupTag $grouptag
}

#################################################################################

### Remove Unnecessary Icons ###
Function RemoveIcons {
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /V PenWorkspaceButtonDesiredVisibility /T REG_DWORD /D 0 /F
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /V EnableFeeds /T REG_DWORD /D 0 /F
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V ShowCortanaButton /T REG_DWORD /D 0 /F
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V ShowTaskViewButton /T REG_DWORD /D 0 /F
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 0

    $apps = "Microsoft Store","Mail"
    foreach ($appname in $apps) {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
    }
    taskkill /f /im explorer.exe
    start explorer.exe
}
### 

