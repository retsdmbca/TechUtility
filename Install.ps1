if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\Logs")) {New-Item -Path "C:\ProgramData\RETSD\Logs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")) {copy-item 'CMTrace.exe' 'C:\ProgramData\RETSD\CMTrace.exe'}

copy-item 'TechUtilityLauncher.exe' "C:\ProgramData\RETSD\Tech Utility App\TechUtilityLauncher.exe" -Force
Copy-Item 'Battery Info View' "C:\ProgramData\RETSD\Tech Utility App\Battery Info View" -Force -Recurse

if (test-path c:\windows\ccm\ccmexec.exe) {copy-item 'TechUtilityLauncher.lnk' "C:\Tech Utility\TechUtilityLauncher.lnk" -Force}

#Install-Module ps2exe
#Invoke-ps2exe -inputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.ps1" -outputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.exe" -iconFile "D:\ico files\RETSDLogo.ico" -noConsole

Function UpdateSCCM {
    Invoke-ps2exe -inputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.ps1" -outputfile "D:\Git Repository\TechUtility\TechUtilityLauncher.exe" -iconFile "D:\ico files\RETSDLogo.ico" -noConsole
    copy-item 'install.ps1' "\\ao-sccm\source\scripts\Tech Utility App\install.ps1" -Force
    copy-item 'TechUtilityLauncher.exe' "\\ao-sccm\source\scripts\Tech Utility App\TechUtilityLauncher.exe" -Force}