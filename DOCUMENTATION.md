# Arquitectura de Persistencia Local (Hive)

## Componentes

### `HivePersistenceConfig`
Responsable de la infraestructura de Hive:
- Inicializa Hive con la ruta local (`Hive.init(hivePath)`).
- Registra los adapters de los modelos de guardado (`LevelStateHiveModelAdapter`, `UserProfileHiveModelAdapter`), generados por `hive_ce_generator`.
- Abre y expone las boxes tipadas:
  - `Box<LevelStateHiveModel>` en `level_states`.
  - `Box<UserProfileHiveModel>` en `user_profile`.

### Modelos de guardado (`data/local/models/`)
`LevelStateHiveModel` y `UserProfileHiveModel` definen el formato en disco (`@HiveType`/`@HiveField`). Mantienen los typeIds (0 y 1) y los índices de campo originales, por lo que leen los datos guardados por versiones anteriores. Cada uno convierte con `fromEntity` y `toEntity`; las entidades del dominio (`LevelState`, `UserProfile`) son Dart puro y no conocen Hive.

### `IPersistenceRepository`
Contrato de dominio para lectura/escritura de datos persistidos:
- Estados de nivel (`readLevelState`, `readAllLevelStates`, `saveLevelState`, `saveLevelStates`).
- Perfil de usuario (`readUserProfile`, `saveUserProfile`).

La capa de dominio depende de esta abstraccion, no de Hive directamente.

### `HivePersistenceRepository`
Implementacion concreta de `IPersistenceRepository` sobre Hive.
Recibe por constructor las dependencias tipadas:
- `Box<LevelStateHiveModel>`
- `Box<UserProfileHiveModel>`

Convierte entre modelos de guardado y entidades: hacia fuera solo expone entidades de dominio.

Reglas clave:
- Guarda y lee `LevelState` usando `levelId` como llave.
- Lee `UserProfile` desde la llave `current_user_profile`.
- Si no hay perfil guardado, retorna un perfil por defecto:
  - `isPremium: false`
  - `isSoundEnabled: true`

## Flujo de Inicializacion Segura (Race Conditions)

`HivePersistenceConfig.initialize(...)` usa un `Completer<void>` compartido para serializar la inicializacion:

1. Primera llamada crea `_initializationCompleter`.
2. Llamadas concurrentes detectan que ya existe y esperan el mismo `future`.
3. Solo una ejecucion realiza `Hive.init`, registro de adapters y apertura de boxes.
4. Al finalizar correctamente, se marca `_initialized = true` y se completa el `Completer`.
5. Si ocurre un error:
   - Se cierran boxes abiertas parcialmente.
   - Se completa el `Completer` con error para que todas las llamadas concurrentes fallen de forma consistente.
6. En `finally`, `_initializationCompleter` se limpia para permitir reintentos controlados.

Este patron evita condiciones de carrera durante el arranque, como dobles aperturas de box, inicializacion duplicada de adapters o estados inconsistentes en accesos tempranos.

## Relacion entre Componentes

1. App bootstrap:
   - Invoca `HivePersistenceConfig.initialize(hivePath: ...)` una sola vez al arrancar.
2. Composicion de dependencias:
   - Se crean `Box<LevelStateHiveModel>` y `Box<UserProfileHiveModel>` desde `HivePersistenceConfig`.
   - Se inyectan en `HivePersistenceRepository`.
3. Uso en capa de dominio/aplicacion:
   - El resto del sistema consume solo `IPersistenceRepository`.
   - Se preserva desacoplamiento y testabilidad.
