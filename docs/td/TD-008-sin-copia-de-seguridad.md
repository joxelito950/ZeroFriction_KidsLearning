# TD-008 · Sin copia de seguridad automática de Android

| | |
|---|---|
| **Estado** | Hecha (2026-10-28). Verificada en el moto g55 el 2026-10-29 |
| **Prioridad** | P1: antes de las entregas 1 y 2 de HU-014 (formulario de Seguridad de los datos y política de privacidad) |
| **Tamaño** | S (configuración, sin código de la app) |
| **Decisión que aplica** | D-033 (dueño del producto, 2026-10-28) |
| **Depende de** | Nada |

## 1. Objetivo

Que el progreso y los ajustes de la app (cajas de Hive: nivel, estrellas, insignia e idioma) se queden **solo en el teléfono**, sin copia en la nube ni transferencia a otro teléfono, y que todos los teléfonos se comporten igual.

## 2. Situación anterior

- El manifiesto no declaraba `allowBackup`, así que valía `true`: Android copiaba los datos de la app en la cuenta del usuario y los pasaba al teléfono nuevo.
- La copia **no depende de la tienda**, sino del fabricante: Google en los teléfonos con sus servicios, Huawei Cloud o Phone Clone en los Huawei sin ellos, Smart Switch de Samsung al cambiar de teléfono. Huawei no documenta qué datos de apps copia, así que el comportamiento no se podía garantizar.
- Con `targetSdk` 36, `allowBackup` ya no basta: desde Android 12 la transferencia entre teléfonos se rige por `dataExtractionRules`.

## 3. Opciones evaluadas

| Opción | A favor | En contra |
|---|---|---|
| Mantener la copia | El progreso vuelve al cambiar de teléfono | Distinta en cada fabricante y sin garantías en Huawei; complica la política de privacidad; puede restaurar el idioma guardado de otra persona (caso de HU-021) |
| **Desactivarla** ✅ | Todo se queda en el teléfono, igual en todos; política y formulario más simples; solo configuración | Al cambiar de teléfono, el juego de memoria empieza de nuevo (5 tableros) |

## 4. Alcance

| # | Requisito |
|---|---|
| A1 | `android:allowBackup="false"` en el `<application>` del manifiesto (Android 8 a 11: sin copia en la nube ni por ADB) |
| A2 | `android:dataExtractionRules="@xml/data_extraction_rules"`, que excluye **todos** los dominios en `<cloud-backup>` y en `<device-transfer>` (Android 12 y posteriores) |
| A3 | `test/architecture/android_backup_test.dart`: falla si se quita cualquiera de las dos cosas, si se deja un dominio sin excluir o si se añade un `<include>` |
| A4 | D-033 en la sección 8 de la especificación |

## 5. Criterios de aceptación

1. **Dado** el manifiesto, **entonces** declara `allowBackup="false"` y las reglas de extracción, y el CI falla si se quitan.
2. **Dado** las reglas, **entonces** excluyen los 9 dominios de datos en la nube y en la transferencia entre teléfonos, sin ningún `<include>`.
3. **Dado** el APK instalado, **entonces** el sistema la marca sin copia de seguridad (`dumpsys package` sin `ALLOW_BACKUP`) y la app sigue arrancando con su progreso guardado.

## 6. Verificación en el moto g55 (2026-10-29)

- Instalada encima de la versión anterior: `dumpsys package` muestra `flags=[ DEBUGGABLE HAS_CODE ALLOW_CLEAR_USER_DATA ]`, sin `ALLOW_BACKUP`.
- Con la copia de seguridad del sistema activada (`bmgr enabled`), la app no aparece entre los paquetes que se pueden copiar (`bmgr list packages`).
- La app arranca con sus datos guardados (idioma español).

## 7. Consecuencias

- HU-014: el formulario de Seguridad de los datos y la política de privacidad pueden decir, sin matices, que los datos se guardan **solo en el dispositivo** y se borran al desinstalar.
- HU-021: deja de darse el caso del idioma restaurado desde la copia de otra persona (salvo herramientas de fabricante que no respeten las reglas de Android, que no están documentadas).
- Riesgo aceptado: Huawei no documenta si Phone Clone respeta estas reglas. Si copiara algo, solo serían nivel, estrellas e idioma, sin datos personales.

## 8. Fuera de alcance

- Una copia propia de la app (exportar o importar el progreso): se valoraría solo si los usuarios lo piden.
