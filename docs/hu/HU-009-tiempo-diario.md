# HU-009 · Tiempo de juego diario y descanso

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-27; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | M (3 días) |
| **Depende de** | HU-004 (Zona de Padres, hecha; ya incluye las instrucciones de «Fijar pantalla») |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** fijar cuánto tiempo al día puede jugar mi hijo,
**para** que el uso de la pantalla sea saludable sin tener que vigilarlo.

## 2. Situación actual

- No hay control de tiempo. README, dominio «Gestión Parental»: control de tiempo diario y límite de sesiones.
- La parte informativa de «Fijar pantalla» ya está en la Zona de Padres (HU-004). El botón que la inicie desde la app requiere código nativo y Android siempre pide confirmación; se propone aparte (P6).
- El cronómetro del juego ya se pausa en segundo plano (HU-001 R11), lo que sirve de base para medir solo el tiempo **en pantalla**.

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | La Zona de Padres tiene una sección **«Tiempo de juego»** en tres pasos (P1, decisión del dueño del producto): |
| R1a | **Primero, los controles del sistema:** se recomienda usar los controles parentales del teléfono, que son más completos y no se pueden saltar desde la app: *Bienestar digital y controles parentales* de Android y *Google Family Link*. Solo como texto, sin enlaces ni permisos (como «Fijar pantalla»). |
| R1b | **Si el adulto quiere reforzarlos desde la app**, ve una leyenda con las **recomendaciones de la OMS** (2019) para la pantalla sedentaria: menores de 2 años, nada; de 2 a 4 años, **como máximo 1 hora al día**, y mejor menos. |
| R1c | **Un selector** con el límite diario: **sin límite** (por defecto), 15, 30, 45, 60, 90 y 120 minutos, y **personalizado**, que permite escribir los minutos con un mínimo de **5 minutos** y un máximo de **12 horas** (720 minutos). Un valor fuera de ese rango no se acepta y se explica el rango, sin tono de error. |
| R2 | Solo cuenta el tiempo con la app **en primer plano y la pantalla encendida**, en cualquier pantalla menos la Zona de Padres. |
| R3 | El día empieza a las **00:00 de la hora del teléfono**; el contador vuelve a cero cada día. |
| R4 | Al llegar al límite **no se corta un tablero a medias**: se termina el tablero en curso y, al acabar (ganando o perdiendo), aparece la pantalla de descanso (P2). |
| R5 | **Pantalla de descanso:** tranquila y amable («¡Hora de descansar! Volvemos mañana»), sin cuenta atrás, sin rojo ni sonidos de alarma. Desde ahí no se puede abrir ningún juego. |
| R6 | La pantalla de descanso tiene el acceso a la Zona de Padres (doble toque y desafío, D-029), donde un adulto puede **dar 15 minutos más** hoy o cambiar el límite. |
| R7 | Cambiar el límite o dar tiempo extra se aplica al instante. |
| R8 | El tiempo de hoy se guarda en el teléfono (minutos y fecha); no se guarda ningún historial ni se envía a ningún sitio. |
| R9 | Si alguien cambia la fecha del teléfono, solo afecta a ese teléfono; se acepta (como D-031 R12). |

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-022 (sin botones en los juegos) | Se mantiene: el aviso llega entre tableros, sin botones en el juego (R4) |
| D-025 (salida protegida) | La pantalla de descanso protege el «atrás» igual que el menú |
| D-029 (control para adultos) | El tiempo extra y los ajustes quedan tras el desafío (R6) |
| SPECIFICATION 4.3 | Sin datos personales ni historial (R8) |

## 5. Criterios de aceptación (borrador)

1. **Dado** la sección «Tiempo de juego», **entonces** veo primero la recomendación de usar los controles parentales del sistema, después la leyenda de la OMS y el selector con sin límite, 15, 30, 45, 60, 90, 120 y personalizado.
2. **Dado** «personalizado», **cuando** escribo 3 o 800 minutos, **entonces** no se acepta y se muestra el rango permitido (5 minutos a 12 horas); **cuando** escribo 25, **entonces** el límite queda en 25 minutos.
3. **Dado** un límite de 15 minutos, **cuando** el niño lleva 15 minutos jugando, **entonces** termina el tablero en curso y después ve la pantalla de descanso.
4. **Dado** la pantalla de descanso, **cuando** el niño toca cualquier cosa salvo el doble toque de la Zona de Padres, **entonces** no abre ningún juego.
5. **Dado** la pantalla de descanso, **cuando** un adulto supera el desafío y da 15 minutos más, **entonces** el niño puede volver a jugar 15 minutos.
6. **Dado** que la app pasa a segundo plano o se apaga la pantalla, **entonces** ese tiempo no cuenta.
7. **Dado** el día siguiente, **entonces** el contador empieza de cero.
8. **Dado** «sin límite», **entonces** nunca aparece la pantalla de descanso.
9. **Dado** los 9 idiomas, **entonces** la sección y la pantalla de descanso no se desbordan en vertical ni en horizontal.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `DailyPlayTime` (Dart puro, reloj inyectado): suma minutos por día, decide si se alcanzó el límite, aplica el tiempo extra |
| Persistencia | Ajustes de padres y tiempo de hoy. Propuesta: una entidad nueva `ParentalSettings` con su caja y **typeId 3** (límite diario en minutos o ninguno, tiempo extra de hoy, minutos de hoy y fecha), en lugar de seguir ampliando `UserProfile`. Actualizar la sección 3.4 de la especificación |
| Presentación | Medidor de tiempo en primer plano (observador del ciclo de vida, como `AdultSessionGuard`), pantalla de descanso, sección en la Zona de Padres; el juego consulta el límite al terminar cada tablero |
| Catálogo | 10–12 claves nuevas en los 9 idiomas (incluidas la recomendación de los controles del sistema y la leyenda de la OMS) |
| Tests | Dominio con `fake_async` y reloj inyectado (cambio de día, tiempo extra), widget de la pantalla de descanso, layout |

## 7. Ejemplo

Límite de 30 min. A los 29 min el niño empieza un 3×4; lo termina a los 31 min → celebración → pantalla de descanso. Mamá hace doble toque en «Zona de Padres», resuelve la multiplicación y da 15 min más → el niño vuelve al menú y juega hasta los 46 min.

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Qué opciones de límite? | ✅ Decidido (2026-10-27): primero se recomiendan los controles parentales del sistema; para reforzarlos, leyenda de la OMS y selector con sin límite (por defecto), 15, 30, 45, 60, 90, 120 y personalizado (5 min a 12 h) (R1a–R1c) | — |
| P2 | ¿Se corta el tablero en curso al llegar al límite? | ✅ Asumida la recomendación: **no**: se termina el tablero (R4); cortarlo a medias se viviría como un castigo | — |
| P3 | ¿Límite por sesión además del diario? | ✅ Asumida la recomendación: **no** en esta historia: el diario cubre la necesidad y es más fácil de entender. Se puede añadir después | — |
| P4 | ¿El tiempo extra cuánto es? | ✅ Asumida la recomendación: **15 minutos** por cada vez que el adulto lo da | — |
| P5 | ¿Dónde se guarda? | ✅ Asumida la recomendación: entidad nueva `ParentalSettings` con typeId 3 (sección 6) | — |
| P6 | ¿Botón para iniciar «Fijar pantalla» desde la app? | ✅ Asumida la recomendación: **aparte**, como **HU-020**: requiere código nativo (`startLockTask`) y Android siempre pide confirmación. Las instrucciones ya están en la Zona de Padres | — |

## 9. Fuera de alcance

- Horarios (por ejemplo, no jugar después de las 20:00).
- Estadísticas o historial de uso.
- Límite por juego.
- Botón de «Fijar pantalla» (HU-020).
- Enlaces que abran los ajustes del sistema o Family Link (solo texto, R1a).
