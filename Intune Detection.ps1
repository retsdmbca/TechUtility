$ver = (Get-Command "C:\ProgramData\RETSD\Tech Utility App\TechUtilityLauncher.exe").FileVersionInfo.FileVersion
if ($ver -eq '1.02') {
    write-host "Version matches"
    exit 0
}
else {
    write-host "Version Does Not Match"
    exit 1
}