# uninstall.ps1 - Desinstala AudioAutoSwitch de este ordenador
$taskName = 'AudioAutoSwitch'
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Parar el vigilante si esta corriendo
Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" |
    Where-Object { $_.CommandLine -match 'AudioAutoSwitch\.ps1' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

$installDir = Join-Path $env:LOCALAPPDATA 'AudioAutoSwitch'
if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
Write-Host 'Desinstalado.' -ForegroundColor Green
