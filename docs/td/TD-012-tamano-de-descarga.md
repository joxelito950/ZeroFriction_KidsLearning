# TD-012 · Medir y vigilar el tamaño de descarga

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-10; preguntas en la sección 6) |
| **Prioridad** | P3 (P2 antes de producción, con TD-013) |
| **Tamaño** | S (1 día) |
| **Depende de** | Nada |

## 1. Objetivo

Saber cuánto descarga de verdad cada teléfono, documentarlo en la sección 1.1 de la especificación y que el CI avise si crece sin que nadie lo note. El README promete menos de 50 MB.

## 2. Lo que se sabe (2026-11-10)

| Medida | Tamaño | Qué es |
|---|---|---|
| AAB `1.0.0-rc.3` | 50,3 MB | Lo que se sube a Play: las tres arquitecturas, todas las densidades y todos los idiomas. **No** es lo que descarga nadie |
| APK de *release* solo arm64 (2026-11-10, con HU-032) | 18,4 MB | Se parece mucho a lo que descarga un teléfono moderno: Google Play entrega solo su arquitectura y su densidad |
| Recursos propios | ≈ 0,5 MB | Logo e iconos (≈ 410 KB), sonidos de HU-005 (≈ 118 KB) |

El grueso es el motor de Flutter y el código compilado de cada arquitectura; los recursos propios pesan poco.

## 3. Propuesta

1. **Medir con `bundletool`** (`get-size total` sobre el AAB, con la especificación de un teléfono arm64 y otro armeabi-v7a con Android 8). Da el rango real de descarga.
2. **Documentar** el resultado en la sección 1.1 de la especificación y en `docs/store/README.md` (una columna en la tabla de versiones subidas).
3. **Vigilarlo en el CI:** un script (`tool/check_download_size.dart`) que compile el APK de arm64 y falle si pasa de un límite (P1). Es rápido y no necesita `bundletool` en el CI.
4. **Reducir, si hace falta** (sin tocar nada visible):
   - `--split-debug-info` y `--obfuscate` al compilar el *release* (el código ocupa menos; los símbolos se guardan aparte para leer errores).
   - Comprimir los PNG de la identidad con `oxipng` o pasarlos a WebP (sin pérdida visible).
   - Pasar los sonidos de WAV a OGG (de ≈ 118 KB a ≈ 20 KB).

## 4. Criterios de aceptación

1. La especificación dice cuánto descarga un teléfono arm64 y uno armeabi-v7a.
2. El CI falla si el APK de arm64 pasa del límite (P1).
3. La tabla de versiones subidas tiene el tamaño de cada versión.

## 5. Impacto

| Área | Cambio |
|---|---|
| CI | Un paso más (compilar el APK de arm64, unos 2 minutos) |
| Herramientas | `tool/check_download_size.dart` y su test |
| Documentos | Especificación 1.1, `docs/store/README.md` |

## 6. Preguntas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Qué límite pone el CI? | **20 MB para el APK de arm64** (hoy 18,4 MB): avisa de cualquier salto grande (una fuente, un vídeo, una dependencia pesada) sin bloquear el día a día | Sí |
| P2 | ¿Se activan `--split-debug-info` y `--obfuscate`? | **Sí**, guardando los símbolos fuera del repo (como la clave de subida): reducen el código y Play Console acepta los símbolos para leer los errores | No |
| P3 | ¿Se pasan los sonidos a OGG? | **Sí, si HU-005 se aprueba**: mismo sonido, una sexta parte del tamaño | No |
