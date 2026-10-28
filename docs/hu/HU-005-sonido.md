# HU-005 · Sonidos suaves y ajuste de sonido

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-27; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | M (2–3 días) |
| **Depende de** | HU-004 (Zona de Padres, hecha) |

## 1. Historia

**Como** niño o niña que juega,
**quiero** oír sonidos suaves cuando volteo una carta, encuentro una pareja o completo un tablero,
**para** que el juego sea más alegre y entienda lo que pasa sin saber leer.

**Como** madre, padre o adulto a cargo,
**quiero** poder silenciar la app desde la Zona de Padres,
**para** que el niño juegue en silencio cuando haga falta.

## 2. Situación actual

- La app **no tiene ningún sonido**. `UserProfile.isSoundEnabled` existe y se guarda (por defecto `true`), pero nada lo usa.
- El backlog llamaba a esta historia «sonido y **dificultad**». La dificultad ya la cubren la escalera de HU-001 y el punto de partida de HU-010, así que se propone **retirarla** de esta historia (P1).
- Reglas ya decididas que tocan el sonido: el aviso de tiempo agotado va **sin sonido** (HU-001 R15) y la barra de tiempo no suena (D-021); sin sonidos estridentes ante un error (SPECIFICATION 4.2).

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | Sonidos breves y suaves en tres momentos: **voltear una carta**, **encontrar una pareja** y **completar un tablero** (y uno especial con la insignia). |
| R2 | **Ningún sonido de error**: dos cartas distintas, el tiempo agotado o un fallo en el desafío de adultos no suenan. |
| R3 | Sin música de fondo en esta historia (P3). |
| R4 | La Zona de Padres tiene un interruptor **«Sonido»** que usa `isSoundEnabled`. Se aplica al instante y se guarda. |
| R5 | Se respeta el volumen y el modo silencio del teléfono: la app nunca sube el volumen. |
| R6 | Los sonidos se incluyen en la app (sin red), con **licencia que permita el uso comercial** (por ejemplo, CC0), anotada en `docs/`. |
| R7 | Si un sonido no se puede reproducir, el juego sigue igual y sin avisos (D-010). |

## 4. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dependencias | Un paquete de audio (por ejemplo, `audioplayers` o `just_audio`), justificado en el PR (SPECIFICATION 4.4). Ver P4 |
| Assets | `assets/sounds/` con 4–5 archivos cortos (OGG o MP3, pocos KB cada uno) |
| Presentación | Un servicio de sonido detrás de una interfaz, para poder probarlo con un *fake*; el juego lo llama en R1; interruptor en la Zona de Padres |
| Catálogo | 2 claves nuevas en los 9 idiomas (título del interruptor y explicación) |
| Persistencia | Ninguna nueva: reutiliza `isSoundEnabled` |
| Tests | Que suena en R1 y no en R2 (con el *fake*), interruptor y guardado, layout de la sección |

## 5. Criterios de aceptación (borrador)

1. **Dado** el sonido activado, **cuando** volteo una carta, encuentro una pareja o completo un tablero, **entonces** suena el sonido correspondiente.
2. **Dado** el sonido activado, **cuando** dos cartas no coinciden o se agota el tiempo, **entonces** no suena nada.
3. **Dado** la Zona de Padres, **cuando** desactivo «Sonido», **entonces** la app queda en silencio al instante y sigue así al reabrirla.
4. **Dado** el teléfono en silencio, **entonces** la app no suena.
5. **Dado** que falla la reproducción, **entonces** el juego sigue sin errores visibles.

## 6. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| HU-001 R15, D-021 | Se mantienen: el tiempo y el tiempo agotado no suenan (R2) |
| SPECIFICATION 4.3 | Sin red ni analítica: los sonidos van dentro de la app (R6) |
| HU-014 | Una dependencia nueva aumenta el tamaño del APK; se mide en el PR |

## 7. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Se retira la «dificultad» de esta historia? | ✅ Decidido (2026-10-27): **sí**, la cubren HU-001 (escalera) y HU-010 (punto de partida) | — |
| P2 | ¿El sonido viene activado o desactivado al instalar? | ✅ Decidido (2026-10-27): **activado**, a volumen moderado; un adulto lo apaga en la Zona de Padres | — |
| P3 | ¿Música de fondo? | ✅ Asumida la recomendación: **no** en esta historia: distrae, cansa a los padres y aumenta el tamaño. Se puede proponer aparte | — |
| P4 | ¿Qué paquete de audio? | ✅ Asumida la recomendación: **`audioplayers`**: maduro, mantenido y suficiente para efectos cortos. Se confirma midiendo el tamaño del APK | — |
| P5 | ¿Quién elige los sonidos? | ✅ Decidido (2026-10-27): **el desarrollo propone** una selección corta de bancos CC0 (Kenney, freesound.org con filtro CC0) y **el dueño del producto aprueba** antes de integrarla | — |
| P6 | ¿Narración por voz de las instrucciones (para niños que no leen)? | ✅ Asumida la recomendación: **fuera de esta historia**: es otra necesidad (voz por idioma, grabaciones o TTS) y se propuso como HU-018, **descartada** el 2026-10-28 (D-034: la app es visual y los sonidos solo acompañan logros e interacciones) | — |

## 8. Fuera de alcance

- Música de fondo (P3).
- Narración por voz (descartada, D-034).
- Sonidos de juegos futuros (llegan con cada juego).
