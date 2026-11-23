# Prueba rápida de funcionamiento en los emuladores (TD-015, SPECIFICATION §5).
#
# Arranca, si hace falta, los dos emuladores de referencia y ejecuta en cada uno
# integration_test/smoke_test.dart: menú, los cuatro juegos y el desafío de la
# Zona de Padres, con la app real.
#   - LowEnd_API26: la versión más antigua que soporta la app (Android 8.0,
#     API 26), gama baja: 2 núcleos, 2 GB, 720 x 1280, GPU por software.
#   - Medium_Phone_API_37.0: la más reciente.
#
# Uso:   powershell -File tool/smoke.ps1
#        powershell -File tool/smoke.ps1 -Avds LowEnd_API26
param(
    [string[]]$Avds = @('LowEnd_API26', 'Medium_Phone_API_37.0'),
    [int]$BootTimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emulator = Join-Path $sdk 'emulator\emulator.exe'

function Get-RunningAvds {
    $running = @{}
    foreach ($line in & $adb devices) {
        if ($line -match '^(emulator-\d+)\s+device') {
            $serial = $Matches[1]
            $name = (& $adb -s $serial emu avd name 2>$null | Select-Object -First 1)
            if ($name) { $running[$name.Trim()] = $serial }
        }
    }
    return $running
}

function Wait-Boot([string]$avd) {
    $deadline = (Get-Date).AddSeconds($BootTimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $running = Get-RunningAvds
        if ($running.ContainsKey($avd)) {
            $serial = $running[$avd]
            $booted = (& $adb -s $serial shell getprop sys.boot_completed 2>$null | Select-Object -First 1)
            if ($booted -and $booted.Trim() -eq '1') { return $serial }
        }
        Start-Sleep -Seconds 5
    }
    throw "El emulador $avd no arrancó en $BootTimeoutSeconds s."
}

$failed = @()
foreach ($avd in $Avds) {
    $started = $false
    if (-not (Get-RunningAvds).ContainsKey($avd)) {
        Write-Host "Arrancando $avd..."
        Start-Process -FilePath $emulator -ArgumentList @('-avd', $avd, '-no-snapshot', '-no-boot-anim', '-no-audio') -WindowStyle Minimized
        $started = $true
    }
    $serial = Wait-Boot $avd
    # Un margen para que el sistema termine de arrancar sus servicios.
    Start-Sleep -Seconds 20
    Write-Host "== $avd ($serial)"
    & flutter test integration_test/smoke_test.dart -d $serial
    if ($LASTEXITCODE -ne 0) { $failed += $avd }
    # Uno cada vez: dos emuladores a la vez dejaban sin respuesta al de API 37.
    if ($started) { & $adb -s $serial emu kill | Out-Null; Start-Sleep -Seconds 5 }
}

if ($failed.Count -gt 0) {
    Write-Host "Falló en: $($failed -join ', ')"
    exit 1
}
Write-Host 'Prueba rápida superada en todos los emuladores.'
