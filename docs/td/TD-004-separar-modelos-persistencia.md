# TD-004 · Separar los modelos de persistencia del dominio

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-10-19; el desarrollo **no** ha empezado) |
| **Épica** | E5 · Plataforma y calidad |
| **Prioridad** | P3 hoy; propuesta de subirla a **P2** (ver P1) |
| **Tamaño** | M (2–3 días) |
| **Decisión que cierra** | D-012 («las entidades de dominio llevan anotaciones de Hive», deuda aceptada) |

## 1. Objetivo

Que la capa de dominio sea **Dart puro**, como promete el README («no depende de ningún framework ni librería»). Hoy `LevelState` y `UserProfile` importan `hive_ce` y llevan `@HiveType`/`@HiveField`, y sus adapters generados (`*.g.dart`) viven dentro de `lib/domain/`.

## 2. Por qué importa

- **Arquitectura:** si se cambia de base de datos, hoy habría que tocar el dominio y todo lo que lo usa.
- **Datos:** el formato de guardado está atado a la clase de dominio. Renombrar o cambiar un campo para el negocio puede romper los datos guardados sin que se note.
- **Crecimiento:** HU-001 añade `MemoryProgress` (typeId 2). Si se crea con anotaciones de Hive, la deuda crece y luego habrá que migrar tres entidades en vez de dos.

## 3. Propuesta

| Capa | Antes | Después |
|---|---|---|
| `domain/entities/` | `LevelState`, `UserProfile` con `@HiveType` y el `part '*.g.dart'` | Las mismas clases, **sin ninguna importación de `hive_ce`** |
| `data/local/models/` | — | `LevelStateHiveModel`, `UserProfileHiveModel`: modelos de guardado con los **mismos typeIds (0 y 1) e índices de campo** |
| `data/local/mappers/` | — | Conversión entre modelo de guardado y entidad, en los dos sentidos |
| `HivePersistenceRepository` | Guarda y lee entidades directamente | Convierte con los mappers; **la interfaz `IPersistenceRepository` no cambia** |

Como se mantienen los typeIds y los índices de campo, **el formato en disco es idéntico** y los datos guardados se siguen leyendo. Lo comprueba el test de compatibilidad con fixtures que añade TD-002.

## 4. Criterios de aceptación

1. **Dado** `lib/domain/`, **entonces** ningún archivo importa `hive_ce` ni contiene `*.g.dart`. Un test de arquitectura lo comprueba leyendo los imports, y falla si alguien lo vuelve a introducir.
2. **Dado** los datos guardados con versiones anteriores (fixtures de `test/fixtures/hive_v2/`), **entonces** se leen igual que antes.
3. **Dado** `IPersistenceRepository`, **entonces** su firma no cambia, y los Cubits y pantallas no se tocan.
4. **Dado** cada mapper, **entonces** tiene tests de ida y vuelta (entidad → modelo → entidad).
5. **Dado** el checklist de calidad, **entonces** el CI está en verde y la cobertura se mantiene.

## 5. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Cuándo hacerlo? | **Antes de la entrega 2 de HU-001**, para que `MemoryProgress` nazca ya separado. Implica subirla de P3 a P2 | Sí (orden del backlog) |
| P2 | ¿Los modelos de guardado usan `@HiveType` o el estilo nuevo de `hive_ce` (`@GenerateAdapters`)? | `@GenerateAdapters`: ya no contamina el dominio, y es la recomendación actual de `hive_ce`. Hay que comprobar que respeta los typeIds existentes | No (se valida al implementar) |
| P3 | ¿La validación de estrellas (0–3) se queda en la entidad? | Sí: es una regla de negocio. Los modelos de guardado no validan | No |

## 6. Riesgos

| Riesgo | Mitigación |
|---|---|
| Un cambio involuntario de typeId o índice de campo corrompería la lectura de los datos guardados | Criterio 2 (test con fixtures) y revisión explícita del registro de typeIds (sección 3.4 de la especificación) |
| Más código (modelos y mappers) para dos entidades sencillas | Coste asumido a cambio de un dominio puro; los mappers son triviales y tienen tests |

## 7. Fuera de alcance

- Cambiar de base de datos.
- Cambios en la interfaz del repositorio.
