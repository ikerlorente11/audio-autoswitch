# AudioAutoSwitch

Cambia automáticamente los dispositivos de audio por defecto de Windows cuando
enciendes o apagas unos auriculares Bluetooth (p. ej. Sennheiser MOMENTUM 4):

- **Auriculares encendidos** → salida de sonido (y opcionalmente micrófono) a los auriculares.
- **Auriculares apagados** → vuelve a los altavoces y micrófono que elijas.

Funciona en Windows 10/11, sin permisos de administrador.

## Instalación en un ordenador nuevo

1. Empareja los auriculares por Bluetooth y **déjalos encendidos**.
2. Abre PowerShell en esta carpeta y ejecuta:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

3. Elige en el menú: auriculares, su micrófono, y los altavoces/micrófono de respaldo.

El instalador:
- Instala el módulo [AudioDeviceCmdlets](https://github.com/frgnca/AudioDeviceCmdlets) (solo para tu usuario).
- Copia el vigilante a `%LOCALAPPDATA%\AudioAutoSwitch` con tu configuración (`config.json`).
- Crea la tarea programada **AudioAutoSwitch**, que arranca oculta al iniciar sesión.

## Desinstalar

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## Cómo funciona

Un pequeño script de PowerShell comprueba cada 2 segundos el estado del endpoint
de audio de los auriculares en el registro de Windows
(`HKLM\...\MMDevices\Audio\Render\<guid>\DeviceState`). Cuando pasa a activo (1)
o deja de estarlo, cambia el dispositivo predeterminado y el de comunicaciones
con `Set-AudioDevice`. El consumo de CPU es despreciable.

Registro de actividad: `%LOCALAPPDATA%\AudioAutoSwitch\AudioAutoSwitch.log`.

## Archivos

| Archivo | Qué es |
|---|---|
| `install.ps1` | Instalador interactivo (elige dispositivos, crea la tarea) |
| `AudioAutoSwitch.ps1` | El vigilante (se copia a `%LOCALAPPDATA%` al instalar) |
| `uninstall.ps1` | Elimina la tarea y la carpeta instalada |
