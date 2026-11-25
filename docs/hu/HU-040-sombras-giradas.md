# HU-040 · Sombras: siluetas en espejo y boca abajo

| | |
|---|---|
| **Estado** | **En refinamiento (2026-11-24)** |
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
  - **boca abajo** (giro de 180°): la 🦒 está del revés.
- **Los objetos de la bandeja nunca se transforman:** el niño ve el objeto normal y busca su sombra aunque esté dada la vuelta.

### 3.2 Gestos y encaje

- **Arrastrar, tocar o ambas** según HU-039, igual que en el resto de Sombras.
- **Al encajar**, el objeto **gira hasta la postura de su sombra** (300 ms) y se queda así: el niño ve que es el mismo, solo que dado la vuelta. Con «reducir animaciones», sin giro animado.
- **Fallo:** el de siempre (vuelve a la bandeja con el vaivén, sin sonido de error, cuenta como fallo y como movimiento).

### 3.3 Mano guía

No hay tutorial nuevo: el nivel 1 nunca tiene sombras transformadas. La **primera vez** que aparece una sombra transformada (primer tablero de obsidiana), el objeto de esa sombra hace un pequeño giro en la bandeja hasta la postura de la sombra y vuelve (una sola vez, 1 s). Es la pista visual que sustituye a una explicación.

## 4. Niveles y rondas

### 4.1 Qué rondas y cuántas por tablero

| Ronda | Niveles con sombras transformadas | Cuántas por tablero | Cuáles |
|---|---|---|---|
| Bronce a zafiro | Ninguno | 0 | — |
| **Obsidiana** | 4 a 8 | **1** | Espejo |
| **Diamante** | 4 a 5 | **1** | Espejo o boca abajo |
| **Diamante** | 6 a 8 | **2** | Espejo y boca abajo (una de cada) |

- **El giro de 90° queda fuera** (P3): un objeto tumbado ocupa la celda de otra manera, cambia el encaje y es el giro más difícil a esta edad.
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
| **El objeto gira al encajar** | Enseña qué ha pasado: el niño no se queda con la duda |

## 5. Contenido (de `ShadowThemes`, Emoji 5.0 o anterior)

| Transformación | Objetos que sirven | Fuera y por qué |
|---|---|---|
| **Espejo** | 🐘 🦒 🐢 🐌 🐟 🐳 🐊 🐇 🐓 🦆 🐈 🦕 🦖 🚗 🚲 🚁 🚀 ✈️ ⛵ 🚂 🚜 🍌 🔑 🔨 🔧 ☂️ | 🦋 🍐 🍇 🍒 🍎 🍉 🎈 ⏰ ✂️: casi simétricos de izquierda a derecha |
| **Boca abajo** | 🐘 🦒 🐢 🐌 🐳 🐊 🐇 🐓 🦆 🐈 🦕 🦖 🚗 🚲 🚁 ⛵ 🚂 🚜 🍐 🍒 ☂️ 🎈 ⏰ 🔑 🔨 | 🍌 🔧 ✂️ 🍉 🍎 🍇 🦋 🐟: del revés se parecen demasiado a sí mismos (o a otro), y 🚀 ✈️ porque ya van inclinados en diagonal |

- **La lista final se valida viendo cada sombra transformada** en el moto g55 y en el emulador con Android 8 (otra fuente de emojis), como pidió HU-007 4.5: una sombra transformada que se confunda con otra no entra.
- Las fuentes dibujan los emojis mirando a lados distintos (el 🐘 de una fuente mira a la derecha y el de otra a la izquierda). No importa: la transformación es **respecto al dibujo de la bandeja**, que es la misma fuente.

## 6. Accesibilidad e idiomas

- Sin texto para el niño.
- **Lector de pantalla:** las sombras transformadas añaden la postura: «Sombra del elefante, al revés» (espejo) y «Sombra de la jirafa, boca abajo». Al encajar, como hoy («Elefante en su sombra»).
- **Dos claves nuevas** en los 9 idiomas:

| Idioma | Espejo | Boca abajo |
|---|---|---|
| es | Sombra de {objeto}, al revés | Sombra de {objeto}, boca abajo |
| en | {object} shadow, mirrored | {object} shadow, upside down |
| fr | Ombre de {objet}, inversée | Ombre de {objet}, à l'envers |
| it | Ombra di {oggetto}, a specchio | Ombra di {oggetto}, capovolta |
| de | Schatten von {Objekt}, gespiegelt | Schatten von {Objekt}, auf dem Kopf |
| pt | Sombra de {objeto}, espelhada | Sombra de {objeto}, de cabeça para baixo |
| ja | {もの}のかげ、はんてん | {もの}のかげ、さかさま |
| ko | {물건} 그림자, 좌우 반전 | {물건} 그림자, 거꾸로 |
| ar | ظل {الشيء}، معكوس | ظل {الشيء}، مقلوب |

- Con la mano izquierda (HU-031) el tablero se refleja como hoy; las sombras transformadas se calculan sobre el emoji, no sobre la disposición, así que no cambia nada.

## 7. Colores (D-032)

Ninguno nuevo: la sombra sigue siendo el emoji en teal profundo (`ColorFilter` de `_Emoji`), solo que transformada.

## 8. Acceso y «Nuevo»

- **Acceso:** el de Sombras (HU-051 P4): **todo gratis salvo el nivel 8** de cada ronda. Obsidiana y diamante, por tanto, gratis en los niveles 4 a 7. En la prueba cerrada, todo gratis (D-040).
- **«Nuevo» (HU-041):** no es un juego nuevo y **no se destaca** al niño (HU-041 R6: solo juegos nuevos). Lo cuentan las notas de Google Play y, para los padres, la descripción de la ronda en «Su progreso» (HU-034).

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio | `lib/domain/shadows/`: `enum ShadowTwist { none, mirror, upsideDown }`; listas de objetos válidos por transformación en `ShadowThemes` (tabla 5); `ShadowRules.twistsFor(level)` (tabla 4.1); `ShadowBoardContent.twists` (`Map<String, ShadowTwist>`), sorteado en `ShadowThemes.pick` respetando las reglas 4.2 |
| Presentación | `ShadowBoard`: `_ShadowCell` y `_Emoji` aplican `Transform` (`Matrix4.diagonal3Values(-1, 1, 1)` para espejo, `Matrix4.rotationZ(pi)` para boca abajo) alrededor del centro; el objeto encajado anima el giro; la pista de la primera vez (3.3) se guarda en el propio progreso de Sombras o en `Discovery` |
| Persistencia | Ninguna nueva: el progreso de Sombras (`GameProgressHiveModel`, clave `shadows`). Si se guarda la pista vista, un campo opcional nuevo (P5) |
| Interruptor | `ShadowRules.twistsEnabled` (constante) para apagarlo en una versión si la validación sale mal |
| Tests | Sorteo con miles de semillas (solo obsidiana y diamante, solo niveles 4–8, como mucho 1 o 2, nunca en sombras libres, solo objetos válidos), pantalla (la sombra se pinta transformada, el objeto gira al encajar, el lector dice la postura), encaje igual con y sin transformación |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Espejo en obsidiana y diamante** (1 por tablero, niveles 4–8): dominio, pintura, giro al encajar, lector, 9 idiomas | Sí |
| 2 | **Boca abajo en diamante** y 2 transformaciones en los niveles 6–8, **después de la validación** (P2) | Sí |

## 11. Tamaño estimado

**1–1,5 días:** medio día el dominio y el sorteo con sus tests, medio día la pintura, el giro y el lector, y lo que haga falta para revisar las sombras transformadas en el teléfono.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre? No es un juego nuevo | **Sigue siendo «Sombras»**, sin nombre aparte. En «Su progreso», las rondas de obsidiana y diamante dicen «con sombras dadas la vuelta» |
| P2 | ¿Cómo se valida con niños de 4–5 años? | **Antes de la entrega 2**, con 3–5 niños de 4–5 años (familia del dueño o testers), en obsidiana: se mira si terminan el tablero sin ayuda (8 de cada 10 al menos), si tardan más de 1,5 veces lo que tardan sin transformaciones y si dejan el juego. Si falla, solo espejo y solo en diamante |
| P3 | ¿Giro de 90°? | **No por ahora:** cambia cómo ocupa la celda y es el giro más difícil a esta edad. Se puede revisar tras la validación |
| P4 | ¿Más tiempo con sombras transformadas? | **No al principio**; si la validación lo pide, +5 s por sombra transformada |
| P5 | ¿Pista de la primera vez (el objeto gira en la bandeja)? | **Sí, una vez por perfil**, guardada en el progreso de Sombras. Sin ella, el primer tablero puede parecer injusto |
| P6 | ¿Las rondas de obsidiana y diamante o solo diamante? | **Obsidiana con espejo y diamante con los dos**, como propone 4.1: la dificultad llega de una en una (HU-051 3.3) |

## 13. Criterios de aceptación

1. Bronce a zafiro y los niveles 1 a 3 no tienen nunca sombras transformadas.
2. Obsidiana tiene 1 sombra en espejo en los niveles 4 a 8; diamante, 1 (niveles 4–5) o 2 (niveles 6–8), espejo o boca abajo.
3. Solo se transforman objetos de la tabla 5, nunca una sombra libre, y nunca queda parecida a otra sombra del tablero.
4. El objeto encaja con el mismo imán que una sombra normal y gira hasta la postura de la sombra.
5. El lector de pantalla dice «al revés» o «boca abajo» en los 9 idiomas.
6. El tiempo, las estrellas, las medallas y el acceso de Sombras no cambian.
7. La validación con niños de 4–5 años está hecha antes de publicar la entrega 2.

## 14. Fuera de alcance

- Giros de 90° y otros ángulos.
- Transformar los objetos de la bandeja.
- Sombras transformadas en «A su sitio» o en otros juegos.
