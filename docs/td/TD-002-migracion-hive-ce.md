# TD-002 · Migrar `hive` / `hive_generator` a `hive_ce`

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-10-18; el desarrollo **no** ha empezado) |
| **Épica** | E5 · Plataforma y calidad |
| **Prioridad** | P1: antes de la entrega 2 de HU-001 |
| **Tamaño** | S (≤ 1 día) |
| **Decisión que cierra** | D-014 («se mantiene Hive 2.2.3 en la beta») |

## 1. Objetivo

Sustituir la base de datos local, que ya no tiene mantenimiento, por su continuación mantenida por la comunidad, **sin cambiar el comportamiento de la app ni perder los datos guardados**, antes de que HU-001 añada un tipo nuevo (typeId 2).

## 2. Motivo (datos de pub.dev, 2026-10-18)

| Paquete | Última versión | Publicada | Restricción de Dart declarada | Situación |
|---|---|---|---|---|
| `hive` | 2.2.3 | 2022-06-30 | `>=2.12.0 <3.0.0` | Sin mantenimiento; funciona por tolerancia de versiones |
| `hive_generator` | 2.0.1 | 2023-08-13 | `analyzer <7.0.0` | Obliga a usar `analyzer` 6.4.1 con Dart 3.13; `build_runner` avisa en cada ejecución |
| `hive_ce` | 2.22.0 | 2026-10-14 | `^3.4.0` | Mantenido; continuación de Hive v2 con la misma API |
| `hive_ce_generator` | 1.12.0 | 2026-10-15 | `analyzer >=14.0.0 <14.5.0`, `build ^4.0.0` | Compatible con nuestro Dart 3.13 |

Problemas conocidos que esta migración debería resolver o dejar documentados:

- El aviso de `analyzer` antiguo en `build_runner` y el riesgo de que se rompa al actualizar Flutter (riesgo de la sección 9 de la especificación).
- `Hive.openBox` filtra un error no capturado cuando falla (fallo de Hive 2.2.3, documentado y tolerado en `hive_persistence_config_test.dart`).

## 3. Alcance

| # | Requisito |
|---|---|
| M1 | `pubspec.yaml`: `hive` → `hive_ce` y `hive_generator` → `hive_ce_generator`, en las versiones resueltas al implementar. `build_runner` sube a la versión que exija `build ^4.0.0` |
| M2 | Cambiar los imports `package:hive/hive.dart` por `package:hive_ce/hive.dart` en `lib/` y `test/` |
| M3 | Se mantienen las anotaciones `@HiveType` / `@HiveField` y los typeIds actuales (0 `LevelState`, 1 `UserProfile`). **No** se adopta todavía el nuevo estilo de `hive_ce` (`@GenerateAdapters`) para que el cambio sea mínimo (ver P1) |
| M4 | Se regeneran los `*.g.dart` y `build_runner` no muestra avisos de `analyzer` |
| M5 | **Compatibilidad de datos:** las cajas escritas con Hive 2.2.3 se leen con `hive_ce` sin pérdida |
| M6 | Se revisa la fuga de errores de `openBox`: si `hive_ce` la corrige, el test de `HivePersistenceConfig` pasa a exigir **0** errores no capturados y se actualiza su comentario; si no, se mantiene la tolerancia documentada |
| M7 | Checklist de la sección 5 de la especificación en verde, con la cobertura sin bajar de los umbrales |
| M8 | Documentación: SPECIFICATION (stack, D-014 cerrada, riesgos de la sección 9), README (pasos de instalación si cambian), DOCUMENTATION.md (nombres de paquete) |

## 4. Criterios de aceptación

1. **Dado** el proyecto migrado, **cuando** ejecuto `dart run build_runner build --delete-conflicting-outputs`, **entonces** termina sin errores y sin avisos de versión de `analyzer`.
2. **Dado** el proyecto migrado, **entonces** `flutter analyze` no da incidencias, todos los tests pasan y `tool/coverage_check.dart` está OK.
3. **Dado** un directorio con cajas `level_states` y `user_profile` escritas con Hive 2.2.3, **cuando** la app migrada las abre, **entonces** lee los mismos `LevelState` y `UserProfile`. Se verifica con un test que usa datos generados con la versión anterior.
4. **Dado** el teléfono de pruebas con la versión anterior instalada y progreso guardado, **cuando** instalo la versión migrada encima (sin desinstalar), **entonces** la app abre sin errores y conserva los datos.
5. **Dado** el código migrado, **entonces** no queda ninguna referencia a `package:hive/` ni a `hive_generator`.
6. **Dado** que se abre una caja que falla, **entonces** el test de `HivePersistenceConfig` refleja el comportamiento real de `hive_ce` (0 errores no capturados si está corregido, o la tolerancia documentada si no).

## 5. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Adoptamos ya el estilo nuevo de `hive_ce` (`@GenerateAdapters` y registro automático de adapters) o mantenemos `@HiveType`? | Mantener `@HiveType` en TD-002, para un cambio mínimo y fácil de revisar. El estilo nuevo encaja mejor con TD-004 (separar los modelos de persistencia del dominio) | No (hay recomendación) |
| P2 | ¿Hace falta conservar los datos de las versiones anteriores? | Sí, como buena práctica, aunque la app no se ha publicado y solo afectaría a los dispositivos de prueba. El criterio 3 lo comprueba | No (hay recomendación) |
| P3 | ¿La implementamos antes o después de TD-001 (CI)? | Después: así el CI valida la migración en su propio PR | No |

## 6. Riesgos

| Riesgo | Mitigación |
|---|---|
| Diferencias sutiles de comportamiento entre Hive 2.2.3 y `hive_ce` | Los tests actuales de persistencia (repositorio, configuración, Hive real en un directorio temporal) cubren el uso que hace la app; criterios 3 y 4 |
| Los requisitos de `build ^4.0.0` obligan a actualizar otras dependencias de desarrollo | Se resuelve con `flutter pub get`; si algo choca, se documenta en el PR |
| `hive_ce_generator` restringe `analyzer <14.5.0` | Funciona con nuestro Dart actual; al actualizar Flutter se revisa en el mismo PR que la versión del CI (TD-001, C2) |

## 7. Fuera de alcance

- Separar los modelos de persistencia del dominio (TD-004).
- Adoptar `@GenerateAdapters` o el registro automático de adapters (P1).
- Usar `hive_ce_flutter` (`Hive.initFlutter`): seguimos usando `path_provider`, que ya funciona.
- Añadir `MemoryProgress` (typeId 2): es parte de HU-001, entrega 2.
