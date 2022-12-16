﻿cls
if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")){Invoke-WebRequest -Uri https://github.com/retsdmbca/TechUtility/blob/master/CMTrace.exe?raw=true -OutFile C:\ProgramData\RETSD\CMTrace.exe}
Invoke-WebRequest -Uri https://raw.githubusercontent.com/retsdmbca/TechUtility/master/TechUtility.ps1 -OutFile C:\ProgramData\RETSD\TechUtility.ps1

Function Run {
    $PID
    if ($RadioButton1.Checked -eq $true) {Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -noprofile -file C:\ProgramData\RETSD\TechUtility.ps1' }
    if ($RadioButton2.Checked -eq $true) {Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -noprofile -file C:\ProgramData\RETSD\TechUtility.ps1' -Verb RunAs}
}


Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Tech Utility'
$main_form.Width = 210
$main_form.Height = 220
$main_form.StartPosition = 'CenterScreen'
$main_form.FormBorderStyle = 'Fixed3D'
$main_form.AutoSize = $false
$main_form.MinimizeBox = $false
$main_form.MaximizeBox = $false

$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(20,20)
$groupBox.size = New-Object System.Drawing.Size(150,80)
$groupBox.text = "Permission Level"
$main_form.Controls.Add($groupBox)

$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = new-object System.Drawing.Point(20,20)
$RadioButton1.size = New-Object System.Drawing.Size(120,20)
$RadioButton1.Checked = $true
$RadioButton1.Text = "Run Normal"
$groupBox.Controls.Add($RadioButton1)

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = new-object System.Drawing.Point(20,50)
$RadioButton2.size = New-Object System.Drawing.Size(120,20)
$RadioButton2.Checked = $false
$RadioButton2.Text = "Run Elevated"
$groupBox.Controls.Add($RadioButton2)

$ButtonRun = New-Object System.Windows.Forms.Button
$ButtonRun.Location = New-Object System.Drawing.Size(20,120)
$ButtonRun.Size = New-Object System.Drawing.Size(150,23)
$ButtonRun.Text = "Run Program"
$ButtonRun.Add_Click({Run})
$main_form.Controls.Add($ButtonRun)

$main_form.ShowDialog()
