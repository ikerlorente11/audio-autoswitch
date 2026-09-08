# AudioAutoSwitch

Cambia automáticamente los dispositivos de audio por defecto de Windows cuando
enciendes o apagas unos auriculares Bluetooth (p. ej. Sennheiser MOMENTUM 4):

- **Auriculares encendidos** → salida de sonido (y opcionalmente micrófono) a los auriculares.
- **Auriculares apagados** → vuelve a los altavoces y micrófono que elijas.

Funciona en Windows 10/11, sin permisos de administrador.

## Puesta en marcha en un PC nuevo

1. **Empareja los auriculares** por Bluetooth en Windows y **déjalos encendidos**
   (si no, el instalador no podrá verlos en la lista).

2. **Descarga el repo.** Abre PowerShell y ejecuta:

   ```powershell
   git clone https://github.com/ikerlorente11/audio-autoswitch.git
   cd audio-autoswitch
   ```

   (o descarga el ZIP desde GitHub con el botón *Code → Download ZIP* y descomprímelo).

3. **Ejecuta el instalador:**

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

4. **Elige en el menú** (escribiendo el número de cada dispositivo):
   - Los auriculares Bluetooth (salida de sonido).
   - Su micrófono (o `0` para no cambiar el micro al encenderlos).
   - Los altavoces de respaldo (a los que volver al apagarlos).
   - El micrófono de respaldo, p. ej. el de la webcam (o `0` para no cambiarlo).

Y listo: queda funcionando desde ese momento y se arranca solo (oculto) cada
vez que inicies sesión en Windows. Puedes borrar la carpeta clonada si quieres;
la instalación queda copiada en `%LOCALAPPDATA%\AudioAutoSwitch`.

El instalador también instala automáticamente el módulo
[AudioDeviceCmdlets](https://github.com/frgnca/AudioDeviceCmdlets) si falta
(solo para tu usuario) y crea la tarea programada **AudioAutoSwitch**.

## Cambiar de auriculares o de altavoces

Vuelve a ejecutar `install.ps1`: sobrescribe la configuración y la tarea con lo
que elijas de nuevo.

## Desinstalar

Desde la carpeta del repo:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Elimina la tarea programada y la carpeta `%LOCALAPPDATA%\AudioAutoSwitch`.

## Cómo funciona

Un pequeño script de PowerShell comprueba cada 2 segundos el estado del endpoint
de audio de los auriculares en el registro de Windows
(`HKLM\...\MMDevices\Audio\Render\<guid>\DeviceState`). Cuando pasa a activo (1)
o deja de estarlo, cambia el dispositivo predeterminado y el de comunicaciones
con `Set-AudioDevice`. El consumo de CPU es despreciable.

- Registro de actividad: `%LOCALAPPDATA%\AudioAutoSwitch\AudioAutoSwitch.log`
- Configuración: `%LOCALAPPDATA%\AudioAutoSwitch\config.json`

## Archivos

| Archivo | Qué es |
|---|---|
| `install.ps1` | Instalador interactivo (elige dispositivos, crea la tarea) |
| `AudioAutoSwitch.ps1` | El vigilante (se copia a `%LOCALAPPDATA%` al instalar) |
| `uninstall.ps1` | Elimina la tarea y la carpeta instalada |

## Licencia

Puedes usar, modificar y compartir este proyecto libremente para fines **no comerciales**.
No está permitido venderlo ni ganar dinero con él. Ver [LICENSE](LICENSE) (PolyForm Noncommercial 1.0.0).
