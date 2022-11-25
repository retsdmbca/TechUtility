if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")){Invoke-WebRequest -Uri https://github.com/retsdmbca/TechUtility/blob/master/CMTrace.exe?raw=true -OutFile C:\ProgramData\RETSD\CMTrace.exe}
Invoke-WebRequest -Uri https://raw.githubusercontent.com/retsdmbca/TechUtility/master/TechUtility.ps1 -OutFile C:\ProgramData\RETSD\TechUtility.ps1

powershell C:\ProgramData\RETSD\TechUtility.ps1
