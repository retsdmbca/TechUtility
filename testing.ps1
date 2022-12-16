### this could be used to run it in elevated
Start-Process powershell -verb runas 


Get-Process powershell | gm ProcessName,Description