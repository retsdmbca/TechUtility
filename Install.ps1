
if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\configs")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App\configs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\Logs")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App\Logs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")) {copy-item 'CMTrace.exe' 'C:\ProgramData\RETSD\CMTrace.exe'}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\configs\RETSDLogo.ico")) {copy-item 'RETSDLogo.ico' 'C:\ProgramData\RETSD\Tech Utility App\configs\RETSDLogo.ico'}

copy-item 'TechUtilityLauncher.exe' "C:\ProgramData\RETSD\Tech Utility App\TechUtilityLauncher.exe" -Force

if (test-path c:\windows\ccm\ccmexec.exe) {copy-item 'TechUtilityLauncher.lnk' "C:\Tech Utility\TechUtilityLauncher.lnk" -Force}
if (!(test-path c:\windows\ccm\ccmexec.exe)) {copy-item 'TechUtilityLauncher.lnk' "C:\Program Files\TechUtilityLauncher.lnk" -Force}


Function UpdateSCCM {
    ## These lines are to create the EXE and update SCCM folders
    $version = "1.02"
    Install-Module ps2exe
    Invoke-ps2exe -inputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.ps1" -outputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.exe" -iconFile "D:\ico files\RETSDLogo.ico" -noConsole -version $version
    copy-item 'install.ps1' "\\ao-sccm\source\scripts\Tech Utility App\install.ps1" -Force
    copy-item 'TechUtilityLauncher.exe' "\\ao-sccm\source\scripts\Tech Utility App\TechUtilityLauncher.exe" -Force}

Function UpdateIntuneFiles{
    copy-item 'install.ps1' "D:\Tech Utility - Prep Files\install.ps1" -Force
    copy-item 'TechUtilityLauncher.exe' "D:\Tech Utility - Prep Files\TechUtilityLauncher.exe" -Force   
}