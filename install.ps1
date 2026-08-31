# install.ps1 - Instalador de AudioAutoSwitch
# Ejecutar en una consola PowerShell normal (sin admin):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
# IMPORTANTE: enciende los auriculares Bluetooth ANTES de ejecutar esto,
# para que aparezcan en la lista de dispositivos.

$ErrorActionPreference = 'Stop'

# 1. Modulo AudioDeviceCmdlets
if (-not (Get-Module -ListAvailable AudioDeviceCmdlets)) {
    Write-Host 'Instalando modulo AudioDeviceCmdlets...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
    }
    Install-Module AudioDeviceCmdlets -Scope CurrentUser -Force -AllowClobber
}
Import-Module AudioDeviceCmdlets

# 2. Seleccion de dispositivos
function Select-Device($devices, $prompt, $optional = $false) {
    Write-Host ''
    Write-Host $prompt -ForegroundColor Cyan
    for ($i = 0; $i -lt $devices.Count; $i++) {
        Write-Host ("  [{0}] {1}" -f ($i + 1), $devices[$i].Name)
    }
    if ($optional) { Write-Host '  [0] (ninguno / no cambiar)' }
    while ($true) {
        $sel = Read-Host 'Numero'
        if ($optional -and $sel -eq '0') { return $null }
        $n = 0
        if ([int]::TryParse($sel, [ref]$n) -and $n -ge 1 -and $n -le $devices.Count) {
            return $devices[$n - 1]
        }
        Write-Host 'Opcion no valida.' -ForegroundColor Yellow
    }
}

$all      = Get-AudioDevice -List
$playback = @($all | Where-Object Type -eq 'Playback')
$record   = @($all | Where-Object Type -eq 'Recording')

$hpRender  = Select-Device $playback 'Auriculares Bluetooth (SALIDA de sonido) - deben estar encendidos ahora:'
$hpCapture = Select-Device $record   'Microfono de los auriculares (0 si no quieres cambiar el micro):' $true
$fbRender  = Select-Device $playback 'Altavoces a usar cuando los auriculares se apaguen:'
$fbCapture = Select-Device $record   'Microfono a usar cuando los auriculares se apaguen (0 = no cambiar):' $true

# GUID del endpoint de salida de los auriculares (para vigilar su estado en el registro)
if ($hpRender.ID -notmatch '\{0\.0\.0\.00000000\}\.(\{[0-9a-fA-F-]+\})') {
    throw "No se pudo extraer el GUID del dispositivo: $($hpRender.ID)"
}
$renderGuid = $Matches[1]

# 3. Copiar a la carpeta de instalacion local (fuera de OneDrive, para que corra siempre)
$installDir = Join-Path $env:LOCALAPPDATA 'AudioAutoSwitch'
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'AudioAutoSwitch.ps1') $installDir -Force

$cfg = [ordered]@{
    HeadphoneLabel     = $hpRender.Name
    HeadphoneRenderId  = $hpRender.ID
    HeadphoneCaptureId = if ($hpCapture) { $hpCapture.ID } else { $null }
    FallbackLabel      = $fbRender.Name
    FallbackRenderId   = $fbRender.ID
    FallbackCaptureId  = if ($fbCapture) { $fbCapture.ID } else { $null }
    RenderGuid         = $renderGuid
}
$cfg | ConvertTo-Json | Out-File (Join-Path $installDir 'config.json') -Encoding utf8

$ps1 = Join-Path $installDir 'AudioAutoSwitch.ps1'
$vbs = Join-Path $installDir 'AudioAutoSwitch.vbs'
"CreateObject(""Wscript.Shell"").Run ""powershell.exe -NoProfile -ExecutionPolicy Bypass -File """"$ps1"""""", 0, False" |
    Out-File $vbs -Encoding ascii

# 4. Tarea programada (arranca oculto al iniciar sesion)
$taskName = 'AudioAutoSwitch'
$action   = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$vbs`""
$trigger  = New-ScheduledTaskTrigger -AtLogOn -User "$env:COMPUTERNAME\$env:USERNAME"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -ExecutionTimeLimit ([TimeSpan]::Zero) -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings `
    -Description 'Cambia el audio por defecto al encender/apagar los auriculares' -Force | Out-Null
Start-ScheduledTask -TaskName $taskName

Write-Host ''
Write-Host 'Instalado y en marcha.' -ForegroundColor Green
Write-Host "  Config y log: $installDir"
Write-Host "  Tarea programada: $taskName (al iniciar sesion)"
