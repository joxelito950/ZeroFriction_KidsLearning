# HU-040 · Sombras: siluetas en espejo y boca abajo

| | |
|---|---|
| **Estado** | **En curso (2026-11-27)**: entrega 1 hecha en `feature/hu-040-1-twists` (espejo en esmeralda con su pista, vista en el emulador de Android 8). Los tres giros están programados, pero boca abajo, 90° y la mezcla de diamante esperan la validación con niños (`ShadowTwists.lateTwistsEnabled = false`); mientras tanto, zafiro, obsidiana y diamante siguen con el espejo, sin pista. Preguntas respondidas el 2026-11-25 (sección 12) |
| **Épica** | E4 · Juegos |
| **Prioridad** | P2 |
| **Tamaño** | S (1–1,5 días, 2 entregas) |
| **Depende de** | HU-007 (Sombras), HU-050 (arrastre visible e imán), HU-051 (ocho rondas: obsidiana y diamante son el antiguo «Imposible»), HU-039 (tocar o arrastrar), HU-031 (mano izquierda) |

## 1. Historia

**Como** niño o niña de 4 a 5 años que ya domina Sombras,
**quiero** encontrar la sombra de un objeto aunque esté dada la vuelta,
**para** seguir teniendo un reto en las últimas rondas y practicar la rotación mental.

## 2. Situación actual y qué reutiliza

- Sombras tiene 8 niveles y 8 rondas (HU-051 3.2). En las últimas rondas los diales son el **imán** (hasta el 90 %), el **tiempo** y la **disposición al azar**; ya no queda mucho por subir sin que sea injusto.
- HU-007 dejó fuera de alcance las siluetas giradas o en espejo (sección 9) y se apuntó como idea en HU-040.
- **Se reutiliza todo:** `ShadowThemes.pick`, `ShadowBoard`, `ShadowDrop` (el encaje cuenta la parte de la celda cubierta, y una celda cuadrada girada o reflejada es la misma celda: **el cálculo no cambia**), la escalera, los tiempos, las estrellas y el progreso de Sombras.
- **Es nuevo:** marcar algunas sombras del tablero con una transformación y pintarlas transformadas (`Transform` con `Matrix4`), y el giro del objeto al encajar.

## 3. Cómo se juega

### 3.1 El tablero

- Igual que hoy: sombras arriba (o a un lado) y bandeja abajo. **Algunas sombras salen transformadas:**
  - **en espejo** (reflejada de izquierda a derecha): el 🐘 mira al otro lado;
  - **boca abajo** (giro de 180°): la 🦒 está del revés;
  - **tumbada** (giro de 90°, P3): el 🐊 está de pie o de lado.
- **Los objetos de la bandeja nunca se transforman:** el niño ve el objeto normal y busca su sombra aunque esté dada la vuelta.

### 3.2 Gestos y encaje

- **Arrastrar, tocar o ambas** según HU-039, igual que en el resto de Sombras.
- **Al encajar**, el objeto **gira hasta la postura de su sombra** (300 ms) y se queda así: el niño ve que es el mismo, solo que dado la vuelta. Con «reducir animaciones», sin giro animado.
- **Fallo:** el de siempre (vuelve a la bandeja con el vaivén, sin sonido de error, cuenta como fallo y como movimiento).

### 3.3 Mano guía

No hay tutorial nuevo: el nivel 1 nunca tiene sombras transformadas.

**Pista (P5, 2026-11-25):** en la ronda que presenta cada giro —**esmeralda** (espejo), **zafiro** (boca abajo) y **obsidiana** (90°)—, el objeto de la sombra transformada hace un pequeño giro en la bandeja hasta la postura de la sombra y vuelve (1 s), si el niño no toca nada en unos segundos. **En diamante no hay pistas.** Es una excepción decidida por el dueño a la regla común de ayudas (solo tutorial y bronce, `Helps`): cada giro nuevo se enseña en su ronda.

## 4. Niveles y rondas

### 4.1 Qué rondas y cuántas por tablero

| Ronda | Niveles con sombras transformadas | Cuántas por tablero | Cuáles | Pista |
|---|---|---|---|---|
| Bronce a rubí | Ninguno | 0 | — | — |
| **Esmeralda** | 4 a 8 | **1** | Espejo | Sí |
| **Zafiro** | 4 a 8 | **1** | Boca abajo | Sí |
| **Obsidiana** | 4 a 8 | **1** | Giro de 90° | Sí |
| **Diamante** | 4 a 5 | **1** | Al azar: espejo, boca abajo o 90° | No |
| **Diamante** | 6 a 8 | **2** | Al azar, dos distintas | No |

- **Cada giro llega solo en su ronda** (P3 y P6, 2026-11-25): espejo en esmeralda, boca abajo en zafiro y 90° en obsidiana; en diamante, mezclados al azar.
- **El giro de 90°** (P3): el objeto tumbado ocupa la celda de otra manera, así que la sombra se pinta girada dentro de su misma celda cuadrada y el encaje se mide igual. Solo con objetos que, tumbados, no se parecen a otro objeto del tablero (4.2).
- **Las sombras libres** (distractores, desde oro) **nunca** se transforman: una sombra libre girada que se parezca a un objeto de la bandeja sería una trampa.
- **Tiempo:** el de la tabla de Sombras (HU-051 3.2), **sin cambios** al principio. Si la validación muestra que se tarda más, +5 s por sombra transformada (P4).
- **Imán, estrellas, medallas, disposición al azar y Premium:** sin cambios.

### 4.2 Cómo se mantiene justo

| Regla | Por qué |
|---|---|
| **Solo objetos asimétricos** para cada transformación | Si el objeto reflejado es igual que el normal (🍎, 🎈, ⏰), la transformación no se nota y no aporta nada; si se parece a otro objeto, confunde |
| **La transformada nunca coincide con otra silueta del tablero** | El 🐊 reflejado no puede parecerse a otra sombra del mismo tablero (test con la lista de parecidos) |
| **Nunca dos transformaciones a la vez** sobre la misma sombra | Espejo y boca abajo juntos es un giro distinto, más difícil |
| **Solo en los niveles 4 a 8** | Los primeros niveles de cada ronda calientan con sombras normales |
| **El giro de 90° solo con objetos alargados o con una dirección clara** (tabla 5) | Un objeto redondo tumbado no cambia; uno casi cuadrado parece otro |
| **El objeto gira al encajar** | Enseña qué ha pasado: el niño no se queda con la duda |

## 5. Contenido (de `ShadowThemes`, Emoji 5.0 o anterior)

| Transformación | Objetos que sirven | Fuera y por qué |
|---|---|---|
| **Espejo** | 🐘 🦒 🐢 🐌 🐟 🐳 🐊 🐇 🐓 🦆 🐈 🦕 🦖 🚗 🚲 🚁 🚀 ✈️ ⛵ 🚂 🚜 🍌 🔑 🔨 🔧 ☂️ | 🦋 🍐 🍇 🍒 🍎 🍉 🎈 ⏰ ✂️: casi simétricos de izquierda a derecha |
| **Boca abajo** | 🐘 🦒 🐢 🐌 🐳 🐊 🐇 🐓 🦆 🐈 🦕 🦖 🚗 🚲 🚁 ⛵ 🚂 🚜 🍐 🍒 ☂️ 🎈 ⏰ 🔑 🔨 | 🍌 🔧 ✂️ 🍉 🍎 🍇 🦋 🐟: del revés se parecen demasiado a sí mismos (o a otro), y 🚀 ✈️ porque ya van inclinados en diagonal |
| **Giro de 90°** (propuesta, P3) | 🦒 🐊 🦕 🦖 🐘 🐢 🐌 🐳 🚂 🚜 ⛵ 🔑 🔨 ☂️ | 🍎 🍉 🎈 ⏰ 🍇 🦋: redondos o casi cuadrados, tumbados no cambian; 🚀 ✈️ 🍌 🔧 ✂️: ya van en diagonal y tumbados parecen otra postura de sí mismos |

- **La lista final se valida viendo cada sombra transformada** en el moto g55 y en el emulador con Android 8 (otra fuente de emojis), como pidió HU-007 4.5: una sombra transformada que se confunda con otra no entra.
- Las fuentes dibujan los emojis mirando a lados distintos (el 🐘 de una fuente mira a la derecha y el de otra a la izquierda). No importa: la transformación es **respecto al dibujo de la bandeja**, que es la misma fuente.

## 6. Accesibilidad e idiomas

- Sin texto para el niño.
- **Lector de pantalla:** las sombras transformadas añaden la postura: «Sombra del elefante, al revés» (espejo), «Sombra de la jirafa, boca abajo» y «Sombra del cocodrilo, tumbada» (90°). Al encajar, como hoy («Elefante en su sombra»).
- **Tres claves nuevas** en los 9 idiomas:

| Idioma | Espejo | Boca abajo | 90° |
|---|---|---|---|
| es | Sombra de {objeto}, al revés | Sombra de {objeto}, boca abajo | Sombra de {objeto}, tumbada |
| en | {object} shadow, mirrored | {object} shadow, upside down | {object} shadow, turned sideways |
| fr | Ombre de {objet}, inversée | Ombre de {objet}, à l'envers | Ombre de {objet}, couchée |
| it | Ombra di {oggetto}, a specchio | Ombra di {oggetto}, capovolta | Ombra di {oggetto}, sdraiata |
| de | Schatten von {Objekt}, gespiegelt | Schatten von {Objekt}, auf dem Kopf | Schatten von {Objekt}, gekippt |
| pt | Sombra de {objeto}, espelhada | Sombra de {objeto}, de cabeça para baixo | Sombra de {objeto}, deitada |
| ja | {もの}のかげ、はんてん | {もの}のかげ、さかさま | {もの}のかげ、よこむき |
| ko | {물건} 그림자, 좌우 반전 | {물건} 그림자, 거꾸로 | {물건} 그림자, 옆으로 누움 |
| ar | ظل {الشيء}، معكوس | ظل {الشيء}، مقلوب | ظل {الشيء}، مائل على جنبه |

- Con la mano izquierda (HU-031) el tablero se refleja como hoy; las sombras transformadas se calculan sobre el emoji, no sobre la disposición, así que no cambia nada.

## 7. Colores (D-032)

Ninguno nuevo: la sombra sigue siendo el emoji en teal profundo (`ColorFilter` de `_Emoji`), solo que transformada.

## 8. Acceso y «Nuevo»

- **Acceso:** el de Sombras (HU-051 P4): **todo gratis salvo el nivel 8** de cada ronda. Obsidiana y diamante, por tanto, gratis en los niveles 4 a 7. En la prueba cerrada, todo gratis (D-040).
- **«Nuevo» (HU-041):** no es un juego nuevo y **no se destaca** al niño (HU-041 R6: solo juegos nuevos). Lo cuentan las notas de Google Play y, para los padres, la descripción de la ronda en «Su progreso» (HU-034).

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio | `lib/domain/shadows/`: `enum ShadowTwist { none, mirror, upsideDown, quarterTurn }`; listas de objetos válidos por transformación en `ShadowThemes` (tabla 5); `ShadowRules.twistsFor(level)` (tabla 4.1); `ShadowBoardContent.twists` (`Map<String, ShadowTwist>`), sorteado en `ShadowThemes.pick` respetando las reglas 4.2 |
| Presentación | `ShadowBoard`: `_ShadowCell` y `_Emoji` aplican `Transform` (`Matrix4.diagonal3Values(-1, 1, 1)` para espejo, `Matrix4.rotationZ(pi)` para boca abajo, `Matrix4.rotationZ(pi / 2)` para 90°) alrededor del centro; el objeto encajado anima el giro; la pista (3.3) sale en esmeralda, zafiro y obsidiana y nunca en diamante |
| Persistencia | Ninguna nueva: el progreso de Sombras. La pista depende de la ronda, no se guarda |
| Interruptor | `ShadowRules.twistsEnabled` (constante) para apagarlo en una versión si la validación sale mal |
| Tests | Sorteo con miles de semillas (solo obsidiana y diamante, solo niveles 4–8, como mucho 1 o 2, nunca en sombras libres, solo objetos válidos), pantalla (la sombra se pinta transformada, el objeto gira al encajar, el lector dice la postura), encaje igual con y sin transformación |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Espejo en esmeralda** (1 por tablero, niveles 4–8) con su pista: dominio, pintura, giro al encajar, lector, 9 idiomas | Sí |
| 2 | **Boca abajo en zafiro, 90° en obsidiana y la mezcla de diamante** (1 o 2 por tablero, sin pistas), **después de la validación** con niños de 4–5 años (P2) | Sí |

**Entrega 1, hecha el 2026-11-27** (`feature/hu-040-1-twists`):

- **Dominio:** `ShadowTwist`, `ShadowTwistPlan` y `ShadowTwists` (`lib/domain/shadows/shadow_twist.dart`): la tabla 4.1 (`planFor`), las listas de la tabla 5 (`valid`) y los parecidos de 4.2 (`lookAlikes`: 🦕 🦖, 🐟 🐳, 🐓 🦆, 🔨 🔧; se amplía con la validación). `ShadowThemes.pick` sortea las sombras transformadas solo entre los objetos de la bandeja (nunca una sombra libre), con giros distintos si hay dos; si la temática no tiene objetos que sirvan (las frutas tumbadas), vuelve a sortear el tablero.
- **Pantalla:** la silueta se pinta transformada; al encajar, el objeto llega derecho y gira hasta la postura de su sombra en 300 ms (sin giro con «reducir movimiento»). **Pista:** a los 4 s sin tocar nada, y después cada 8 s, el objeto se da la vuelta en la bandeja y vuelve (1 s); solo en la ronda que presenta el giro, nunca en diamante, y no con «reducir movimiento». El toque cuenta aunque el objeto esté a medio girar.
- **Lector de pantalla:** «Sombra de 🐳, al revés», «…, boca abajo» y «…, tumbada», en los 9 idiomas (tabla 6).
- **Hasta la validación (P2):** `ShadowTwists.lateTwistsEnabled = false`. Zafiro, obsidiana y diamante llevan 1 sombra en espejo por tablero, sin pista, para que ninguna ronda sea más fácil que esmeralda. Al encenderlo, cada ronda tiene su giro (tabla 4.1) sin más cambios.
- **Visto en el emulador de Android 8 (2026-11-27):** esmeralda nivel 4, la 🐳 en espejo; la pista la da la vuelta en la bandeja y, al encajar, gira hasta su sombra.
- **Falta:** verla en el moto g55 (otra fuente de emojis, sección 5) y la validación con niños antes de la entrega 2.

## 11. Tamaño estimado

**1,5–2 días:** medio día el dominio y el sorteo con sus tests, medio día la pintura, el giro y el lector, medio día el giro de 90° y su lista de objetos, y lo que haga falta para revisarlo en el teléfono.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre? No es un juego nuevo | ✅ Decidido (2026-11-25): **sigue siendo «Sombras»**. En «Su progreso», las rondas con giros dicen «con sombras dadas la vuelta» |
| P2 | ¿Cómo se valida con niños de 4–5 años? | ✅ Decidido (2026-11-25): **antes de la entrega 2**, con 3–5 niños de 4–5 años: si terminan el tablero sin ayuda (8 de cada 10), si tardan más de 1,5 veces y si dejan el juego |
| P3 | ¿Giro de 90°? | ✅ Decidido (2026-11-25): **sí**. Solo en obsidiana, y en diamante al azar con los otros giros |
| P4 | ¿Más tiempo con sombras transformadas? | ✅ Decidido (2026-11-25): **no al principio**; +5 s por sombra si la validación lo pide |
| P5 | ¿Pista (el objeto gira en la bandeja)? | ✅ Decidido (2026-11-25): **solo en esmeralda, zafiro y obsidiana**, las rondas que presentan cada giro. **En diamante, sin pistas** (3.3) |
| P6 | ¿En qué rondas? | ✅ Decidido (2026-11-25): **espejo desde esmeralda, boca abajo en zafiro, 90° en obsidiana y todos al azar en diamante** (tabla 4.1) |

## 13. Criterios de aceptación

1. Bronce a rubí y los niveles 1 a 3 no tienen nunca sombras transformadas.
2. Esmeralda tiene 1 sombra en espejo, zafiro 1 boca abajo y obsidiana 1 girada 90°, en los niveles 4 a 8; diamante, 1 (niveles 4–5) o 2 distintas (niveles 6–8), al azar entre los tres giros.
3. Solo se transforman objetos válidos para cada giro (tabla 5 y 4.2), nunca una sombra libre, y nunca queda parecida a otra sombra del tablero.
4. El objeto encaja con el mismo imán que una sombra normal y gira hasta la postura de la sombra.
5. La pista sale en esmeralda, zafiro y obsidiana, y nunca en diamante.
6. El lector de pantalla dice «al revés», «boca abajo» o «tumbada» en los 9 idiomas.
7. El tiempo, las estrellas, las medallas y el acceso de Sombras no cambian.
8. La validación con niños de 4–5 años está hecha antes de publicar la entrega 2.

## 14. Fuera de alcance

- Ángulos distintos de 90° y 180°, y dos giros a la vez sobre la misma sombra.
- Transformar los objetos de la bandeja.
- Sombras transformadas en «A su sitio» o en otros juegos.
