if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App")){New-Item -Path "C:\ProgramData\RETSD\Tech Utility App" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\Logs")){New-Item -Path "C:\ProgramData\RETSD\Logs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")) {copy-item 'CMTrace.exe' 'C:\ProgramData\RETSD\CMTrace.exe'}

