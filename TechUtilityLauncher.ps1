cls
$outputfile = "C:\ProgramData\RETSD\Tech Utility App\Logs\TechUtilityError.LOG"
if (!(test-path "C:\ProgramData\RETSD")){New-Item -Path "C:\ProgramData\RETSD" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\configs")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App\Configs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\Logs")) {New-Item -Path "C:\ProgramData\RETSD\Tech Utility App\Logs" -ItemType directory}
if (!(test-path "C:\ProgramData\RETSD\Tech Utility App\configs\RETSDLogo.ico")){Invoke-WebRequest -Uri https://github.com/retsdmbca/TechUtility/blob/master/RETSDLogo.ico?raw=true -OutFile "C:\ProgramData\RETSD\Tech Utility App\configs\RETSDLogo.ico"}
if (!(test-path "C:\ProgramData\RETSD\CMTrace.exe")){Invoke-WebRequest -Uri https://github.com/retsdmbca/TechUtility/blob/master/CMTrace.exe?raw=true -OutFile C:\ProgramData\RETSD\CMTrace.exe}
Invoke-WebRequest -Uri https://raw.githubusercontent.com/retsdmbca/TechUtility/master/TechUtility.ps1 -OutFile "C:\ProgramData\RETSD\Tech Utility App\TechUtility.ps1"

Function GithubTest {
    $HTTP_Request = [System.Net.WebRequest]::Create('http://github.com')
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    If ($HTTP_Status -eq 200) {Run}
    Else {
        $Labeloutput.Visible = $true
        $Labeloutput2.Visible = $true
        $Labeloutput.Text = "Can't connect to Github."
    }
}
Function Run {
    $HTTP_Response.Close()
    $Labeloutput.Text = "Please Wait..."
    $Labeloutput.Visible = $true
    $ButtonRun.Visible = $false
    if ($RadioButton1.Checked -eq $true) {
        write-output "normal" | out-file -filepath "C:\ProgramData\RETSD\Tech Utility App\configs\state.txt"
        try{Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -noprofile -file "C:\ProgramData\RETSD\Tech Utility App\TechUtility.ps1"' }
        catch{write "$_.Exception.Message" | out-file -filepath $outputfile}
}
    if ($RadioButton2.Checked -eq $true) {
        write-output "elevated" | out-file -filepath "C:\ProgramData\RETSD\Tech Utility App\configs\state.txt"
        try{Start-Process powershell.exe -ArgumentList '-WindowStyle Hidden -noprofile -file "C:\ProgramData\RETSD\Tech Utility App\TechUtility.ps1"' -Verb RunAs}
        catch{write "$_.Exception.Message" | out-file -filepath $outputfile}
    }
}

Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Tech Utility'
$main_form.Width = 210
$main_form.Height = 230
$main_form.StartPosition = 'CenterScreen'
$main_form.FormBorderStyle = 'Fixed3D'
$main_form.AutoSize = $false
$main_form.MinimizeBox = $false
$main_form.MaximizeBox = $false
$main_form.Icon = "C:\ProgramData\RETSD\Tech Utility App\configs\RETSDLogo.ico"

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
$ButtonRun.Location = New-Object System.Drawing.Size(20,110)
$ButtonRun.Size = New-Object System.Drawing.Size(150,23)
$ButtonRun.Text = "Run Program"
$ButtonRun.Add_Click({GithubTest})
$main_form.Controls.Add($ButtonRun)

$Labeloutput = New-Object System.Windows.Forms.Label
$Labeloutput.Text = "Please Wait..."
$Labeloutput.Location  = New-Object System.Drawing.Point(20,140)
$Labeloutput.AutoSize = $true
$Labeloutput.Visible = $false
$main_form.Controls.Add($Labeloutput)

$Labeloutput2 = New-Object System.Windows.Forms.Label
$Labeloutput2.Text = "Check Connection"
$Labeloutput2.Location  = New-Object System.Drawing.Point(20,160)
$Labeloutput2.AutoSize = $true
$Labeloutput2.Visible = $false
$main_form.Controls.Add($Labeloutput2)

$main_form.ShowDialog()