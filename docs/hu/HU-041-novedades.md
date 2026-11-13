# HU-041 · Celebración de novedades tras actualizar

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-11-12). Faltan las respuestas del dueño a P1–P4 |
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

- **R1.** La app recuerda qué juegos **ha visto** el niño (un conjunto de `GameId`), no la versión. Así no depende de cómo se numeran las versiones y funciona igual con cualquier actualización.
- **R2.** En la **primera instalación** todos los juegos cuentan como vistos: para un niño nuevo todo es nuevo, y destacar uno sería ruido.
- **R3.** Tras una actualización con un juego que no estaba en el conjunto, su tarjeta del menú se **destaca**: unos destellos ámbar alrededor y un pequeño saltito cada pocos segundos. **Sin texto**: los niños aún no leen. Para el lector de pantalla, la tarjeta dice «Nuevo».
- **R4.** El destaque dura hasta que el niño **abre ese juego** una vez. Entonces el juego pasa a vistos y no vuelve a destacarse.
- **R5.** Si el sistema pide reducir las animaciones, en lugar de saltito y destellos se muestra un punto ámbar fijo en la esquina de la tarjeta.

## 4. Criterios de aceptación (borrador)

1. En una instalación nueva, ninguna tarjeta se destaca.
2. Al actualizar desde una versión sin un juego, su tarjeta se destaca; al abrirlo y volver al menú, ya no.
3. Con «quitar animaciones» activo, se ve el punto fijo en vez de la animación.
4. El lector de pantalla anuncia «Nuevo» en la tarjeta destacada, en los 9 idiomas.

## 5. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `seenGames: Set<GameId>` en `UserProfile` |
| Datos | Campo nuevo en `UserProfileHiveModel`. **`null` (perfil anterior a esta historia) se interpreta como «había visto los juegos que existían en `1.0.0-rc.4`»** (memoria, sombras y ¿Cuál es diferente?), para que la primera actualización con esta historia no destaque juegos viejos. Sin perfil (instalación nueva): todos vistos (R2) |
| Presentación | `NewGameHighlight`, un envoltorio de la tarjeta del menú con un `AnimationController` que respeta `MediaQuery.disableAnimations` |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿El destaque dura hasta abrir el juego, o unos días? | **Hasta abrirlo**: es lo que el niño entiende |
| P2 | ¿Se destacan también otras novedades (rondas, medallas, un nivel nuevo)? | **No.** Solo juegos: lo demás se descubre jugando, y HU-037 P11 ya decidió no avisar del dorado |
| P3 | ¿Un aviso para los padres («Novedades de esta versión»)? | **No** en la app: las notas de la versión de Google Play ya lo cuentan (`docs/store/`) |
| P4 | ¿Se desarrolla junto con el 4.º juego? | **Sí:** sin un juego nuevo no hay nada que probar en un teléfono real. Queda lista para entonces |

## 7. Fuera de alcance

- Notificaciones del sistema.
- Pantallas de «¿Qué hay de nuevo?» con texto.
