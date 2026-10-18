# TD-001 · CI con GitHub Actions

| | |
|---|---|
| **Estado** | Lista (refinada el 2026-10-18; el desarrollo **no** ha empezado) |
| **Épica** | E5 · Plataforma y calidad |
| **Prioridad** | P1: antes de HU-001 |
| **Tamaño** | S (medio día) |
| **Decisión que cierra** | D-016 («sin CI todavía») |

## 1. Objetivo

Que GitHub ejecute automáticamente la checklist de la sección 5 de la especificación en cada PR y en cada push a `develop` y `main`, y que **no se pueda fusionar** un PR que la incumpla.

## 2. Situación actual

- Las reglas de calidad (análisis con 0 incidencias, tests en verde y cobertura de 90 % total / 80 % por archivo) solo se cumplen si alguien las ejecuta a mano.
- El repositorio es **público**: GitHub Actions es gratis y sin límite de minutos.
- Solo existen los workflows automáticos de **Copilot** (revisión de PRs y agente en la nube). No compilan ni ejecutan tests; TD-001 los complementa y no los reemplaza.

## 3. Alcance

| # | Requisito |
|---|---|
| C1 | Un workflow `.github/workflows/ci.yml` que se dispara en `pull_request` hacia `develop` y `main`, y en `push` a `develop` y `main` |
| C2 | Usa la **misma versión de Flutter que el equipo local**: 3.47.5 stable, fijada en el workflow. Actualizarla es un cambio explícito en un PR |
| C3 | Pasos, en orden: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test --coverage` → `dart run tool/coverage_check.dart` |
| C4 | Si un paso falla, el job falla y el PR muestra el check en rojo |
| C5 | Se publica `coverage/lcov.info` como artefacto del job, para consultarlo sin repetir la ejecución en local |
| C6 | Caché del SDK de Flutter y de los paquetes de pub, para que el job tarde pocos minutos |
| C7 | Un job cancela al anterior de la misma rama (`concurrency`), para no gastar ejecuciones en commits ya superados |
| C8 | La especificación pasa D-016 a «Vigente» y la sección 5 indica que el CI ejecuta la checklist |

## 4. Configuración manual en GitHub (la hace el dueño del repo)

Un workflow no puede bloquear fusiones por sí solo. Una vez que el CI esté en `develop`:

1. GitHub → *Settings* → *Branches* (o *Rules → Rulesets*) → regla para `develop` y `main`.
2. Activar **«Require status checks to pass before merging»** y elegir el check del workflow (nombre propuesto: `CI / quality`).
3. Recomendado: **«Require branches to be up to date before merging»**, para evitar el error de fusionar en la rama equivocada como pasó con el PR #12.

## 5. Criterios de aceptación

1. **Dado** un PR hacia `develop` o `main`, **entonces** aparece el check `CI / quality` y se ejecuta sin intervención manual.
2. **Dado** un PR con una incidencia de `flutter analyze`, un test fallido o cobertura por debajo del umbral, **entonces** el check queda en rojo e indica qué paso falló.
3. **Dado** un PR que cumple todo, **entonces** el check queda en verde y el artefacto `coverage` está disponible.
4. **Dado** que la regla de protección está activa, **entonces** GitHub no permite fusionar un PR con el check en rojo.
5. **Dado** el mismo commit, **entonces** el resultado en el CI coincide con la ejecución local de la checklist (misma versión de Flutter).

Para verificarlo se abre un PR de prueba con un fallo intencionado (por ejemplo, un test que falla), se comprueba el rojo, se corrige y se comprueba el verde. Ese PR no se fusiona.

## 6. Fuera de alcance (posibles mejoras futuras)

- Compilar el APK en el CI: tarda varios minutos más y no aporta a la calidad del código hasta que haya firma de release (TD-003).
- Publicar en Google Play desde el CI.
- Comentar la cobertura en el PR o mostrar badges en el README.

## 7. Riesgos

| Riesgo | Mitigación |
|---|---|
| Versión de Flutter distinta entre local y CI, con resultados distintos | Versión fijada en el workflow (C2); se actualiza a la vez que la local |
| `build_runner` falla en el CI por el `analyzer` antiguo de `hive_generator` | Hoy funciona en local con la misma versión; TD-002 (`hive_ce`) elimina el riesgo |
| Diferencias de rutas Windows/Linux en `lcov.info` | `tool/coverage_check.dart` ya normaliza las barras de las rutas |
