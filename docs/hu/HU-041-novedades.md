# HU-041 · Celebración de novedades tras actualizar

| | |
|---|---|
| **Estado** | **Lista** (2026-11-18): P1 a P4 decididas. **Bases desarrolladas** (dominio y guardado, sin cambios visibles); el resto se termina con el próximo juego (P4) |
| **Épica** | E1 · Juegos y menú |
| **Prioridad** | P3 (sube a P2 si el 4.º juego llega antes de la publicación) |
| **Tamaño** | S (1 entrega, 1 día) |
| **Depende de** | HU-023 (menú de varios juegos) y `GameId` (HU-025). Sin dependencias de datos de otras historias |

## 1. Historia

**Como** niño que ya usaba la app,
**quiero** ver que hay un juego nuevo cuando se actualiza,
**para** descubrirlo sin que nadie me lo tenga que señalar.

## 2. Situación actual

- El menú muestra las tarjetas de los juegos, todas iguales. Al llegar Sombras y «¿Cuál es diferente?», nada los distinguía.
- HU-037 P11 decidió que **no hace falta avisar del cambio de dorado**. Esta historia trata solo de **juegos nuevos**.

## 3. Comportamiento propuesto

- **R1.** La app recuerda, por juego, **cuántas veces lo ha abierto** el niño (un contador por `GameId`), no la versión. Así no depende de cómo se numeran las versiones y funciona igual con cualquier actualización.
- **R2.** En la **primera instalación** todos los juegos cuentan como vistos: para un niño nuevo todo es nuevo, y destacar uno sería ruido.
- **R3.** Tras una actualización con un juego que no estaba en el conjunto, su tarjeta del menú se **destaca**: unos destellos ámbar alrededor y un pequeño saltito cada pocos segundos. **Sin texto**: los niños aún no leen. Para el lector de pantalla, la tarjeta dice «Nuevo».
- **R4.** El destaque dura hasta que el niño **abre ese juego por tercera vez** o **supera la ronda plata** en él (consigue la medalla de plata), lo que ocurra antes (P1). Entonces el juego pasa a visto y no vuelve a destacarse.
- **R5.** Si el sistema pide reducir las animaciones, en lugar de saltito y destellos se muestra un punto ámbar fijo en la esquina de la tarjeta.
- **R6.** **Al niño solo se le destacan juegos nuevos** (P2): ni rondas, ni medallas, ni niveles. No hay celebración de «¡Nuevas medallas!» (la que se propuso para HU-051 queda descartada).
- **R7.** **En la Zona de Padres sí se destacan las funciones nuevas** (P2): la fila de una opción nueva lleva una etiqueta «Nuevo» (el adulto sí lee) hasta que el adulto la abre una vez. Se guardan las filas vistas, con la misma regla de R2: en una instalación nueva no se destaca ninguna.
- **R8.** No hay pantalla ni aviso de «Novedades de esta versión» para los padres (P3): lo cuentan las notas de Google Play.

## 4. Criterios de aceptación (borrador)

1. En una instalación nueva, ninguna tarjeta ni fila de la Zona de Padres se destaca.
2. Al actualizar desde una versión sin un juego, su tarjeta se destaca; tras abrirlo dos veces sigue destacada; al abrirlo la tercera vez, o al ganar en él la medalla de plata, ya no.
3. Con «quitar animaciones» activo, se ve el punto fijo en vez de la animación.
4. El lector de pantalla anuncia «Nuevo» en la tarjeta destacada, en los 9 idiomas.
5. Una fila nueva de la Zona de Padres lleva «Nuevo» hasta que el adulto la abre una vez.

## 5. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `GameDiscovery` (veces que se ha abierto cada juego y filas de la Zona de Padres vistas), con `isNew(GameId, medals)` según R4 y `isNewSetting(id)` según R7 |
| Datos | Campos nuevos en `UserProfileHiveModel`. **`null` (perfil anterior a esta historia) se interpreta como «había visto los juegos y las filas que existían en `1.0.0-rc.5`»** (memoria, sombras y ¿Cuál es diferente?), para que la primera actualización con esta historia no destaque nada viejo. Sin perfil (instalación nueva): todo visto (R2) |
| Presentación | `NewGameHighlight`, un envoltorio de la tarjeta del menú con un `AnimationController` que respeta `MediaQuery.disableAnimations` |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿El destaque dura hasta abrir el juego, o unos días? | ✅ Decidido (2026-11-18): **hasta abrirlo por tercera vez, o hasta que el niño supere la ronda plata** en ese juego (R4) |
| P2 | ¿Se destacan también otras novedades (rondas, medallas, un nivel nuevo)? | ✅ Decidido (2026-11-18): **no** para el niño (sin «¡Nuevas medallas!»), **pero en la Zona de Padres sí se destacan las funciones nuevas** (R6, R7) |
| P3 | ¿Un aviso para los padres («Novedades de esta versión»)? | ✅ Decidido (2026-11-18), como la recomendación: **no** en la app; lo cuentan las notas de la versión de Google Play (`docs/store/`) |
| P4 | ¿Se desarrolla junto con el 4.º juego? | ✅ Decidido (2026-11-18): **sí**, se une a las historias que van con el próximo juego. Las bases (dominio y guardado) se adelantan para que la versión que lo traiga ya sepa qué ha visto cada niño |

## 7. Entregas

| Entrega | Estado | Qué se hizo |
|---|---|---|
| Bases | ✅ 2026-11-18, rama `feature/hu-034-3-progress-screen` | Dominio `Discovery` (`lib/domain/news/discovery.dart`): veces abierto cada juego (hasta 3), `isNewGame` (R4: tercera apertura o medalla de plata), `ParentsFeature` y `isNewFeature` (R7). Guardado en `UserProfileHiveModel`, campos 3 y 4 (sin typeId nuevo): un perfil anterior se lee como «visto lo de `1.0.0-rc.5`» (los tres juegos y las filas sin «Su progreso»), y una instalación nueva guarda todo como visto (R2). El menú ya **cuenta cada apertura** de un juego, para que la versión del próximo juego sepa qué ha visto cada niño. **Sin cambios visibles** |
| Destaque | Con el próximo juego (P4) | `NewGameHighlight` en el menú (destellos, saltito, punto fijo sin animaciones, «Nuevo» para el lector de pantalla) y la etiqueta «Nuevo» en las filas de la Zona de Padres. Con las bases, «Su progreso» ya saldría como nueva para quien actualice desde la `rc.5` |

## 8. Fuera de alcance

- Notificaciones del sistema.
- Pantallas de «¿Qué hay de nuevo?» con texto.
