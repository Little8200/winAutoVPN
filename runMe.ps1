if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

if (-not (Test-Path "D:\autoVPN.bat")) {
    Write-Host "error not font D:\autoVPN.bat" -ForegroundColor Red
    pause
    exit
}
try {
   
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
   
    Set-ItemProperty -Path $regPath -Name "EnableLUA" -Value 0 -Force
    
    Set-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force
    Write-Host "[UAC] UAC restrictions have been disabled." -ForegroundColor Cyan

 
    Unregister-ScheduledTask -TaskName "AutoConnectVPN_L2TP" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "[1/2] Clear Task Successfully" -ForegroundColor Green
  
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
   
    $Trigger.Delay = "PT100S" 
    
    $Action = New-ScheduledTaskAction -Execute 'WScript.exe' -Argument '"D:\autoVPN.vbs"'
    
    Register-ScheduledTask -TaskName "AutoConnectVPN_L2TP" `
                           -Trigger $Trigger `
                           -Action $Action `
                           -User $env:USERNAME `
                           -Force | Out-Null
    Write-Host "[2/2] Create Task Successfully" -ForegroundColor Green
} catch {
    Write-Host "error:($_.Exception.Message)" -ForegroundColor Red
}

pause