# HU-051 · Más metas: medallas de rubí, esmeralda, zafiro, obsidiana y diamante

| | |
|---|---|
| **Estado** | Idea en refinamiento (2026-11-17). Propuesta del dueño: «revisar la posibilidad de tener muchos más niveles» |
| **Épica** | E1 · Juegos (progresión) |
| **Prioridad** | P2 |
| **Tamaño** | L (por decidir con P1) |
| **Depende de** | HU-037 (rondas), HU-048 (medalla propia), HU-002 (dorado) |

## 1. Historia

**Como** niño o niña que ya tiene el oro de un juego,
**quiero** seguir teniendo nuevas metas en ese juego,
**para** no aburrirme y seguir practicando.

**Como** adulto,
**quiero** que esas metas no conviertan el juego en algo frustrante,
**para** que siga siendo tranquilo (la premisa de HU-034).

## 2. Situación actual

- Cada juego tiene **3 rondas** (Fácil, Normal, Reto máximo) con su medalla: bronce, plata y oro (HU-037, D-038).
- El **dorado** del botón se completa con todas las estrellas de las 3 rondas.
- Al ganar el oro, el niño se queda en el Reto máximo (HU-037 P4): **no hay más metas**.

## 3. La propuesta del dueño: 8 medallas

**Bronce → Plata → Oro → Rubí → Esmeralda → Zafiro → Obsidiana → Diamante.**

### 3.1 ¿Más dificultad o más variedad? (la decisión clave, P1)

| Opción | Cómo serían las rondas 4 a 8 | Valoración |
|---|---|---|
| **A. Más difícil** | Más cartas, menos tiempo, sombras giradas (HU-040), más objetos | ⚠️ Para niños de 2 a 5 años, el Reto máximo ya está en el límite (16 cartas, 90 % de solape). Cinco escalones más difíciles **llevan a la frustración**, contra la premisa del producto, y casi ningún niño los alcanzaría |
| **B. Más variedad, misma dificultad** | Cada nueva medalla es el Reto máximo **con algo nuevo**: otra temática (vehículos, HU-052), otro orden, sombras en espejo suaves… | ✅ **Recomendado.** Da metas nuevas sin subir la frustración; reutiliza las escaleras actuales y crece con cada temática nueva |
| **C. Maestría** | Medallas por repetir: «todas las estrellas sin bajar de nivel», «una semana jugando»… | ⚠️ Se parecen a las rachas, que la premisa descarta («lleva 3 días sin jugar» genera presión) |

### 3.2 Propuesta recomendada (opción B)

| Medalla | Se consigue al completar… | Novedad |
|---|---|---|
| Bronce, plata, oro | Fácil, Normal, Reto máximo (como hoy) | — |
| **Rubí** | El Reto máximo con la **temática de vehículos** (HU-052) | Temática nueva |
| **Esmeralda** | El Reto máximo con **temáticas mezcladas** en el mismo tablero | Mezcla |
| **Zafiro** | El Reto máximo con **disposición al azar** en cada tablero (como ya hace Sombras) en los tres juegos | Orden |
| **Obsidiana** | El Reto máximo con **una pista menos** (sin vista previa en Memoria, sin imán extra en Sombras) | Sin ayudas |
| **Diamante** | Las 7 anteriores: el juego queda **dorado y con brillo de diamante** | Corona |

- Las medallas a partir del rubí son **opcionales**: el niño que tiene el oro sigue jugando el Reto máximo, y el adulto puede activar las nuevas rondas en la Zona de Padres (P3).
- El **dorado** sigue siendo «todas las estrellas de bronce, plata y oro»; las nuevas medallas añaden un **brillo** encima (P4), para no bajar el dorado a quien ya lo tiene (como pasó con HU-037, sección 10.3).

### 3.3 Las medallas nuevas se tienen que distinguir

Con `MedalBadge` (HU-048), cada una con relleno, borde y número de estrellas o una gema:

| Medalla | Color | Señal sin color |
|---|---|---|
| Rubí | **Rojo rubí** (no está en la paleta) | Gema facetada |
| Esmeralda | **Verde** (no está en la paleta) | Gema facetada |
| Zafiro | Azul petróleo `#176B78` (está) | Gema facetada |
| Obsidiana | Teal profundo `#00454D` casi negro (está) | Gema con brillo |
| Diamante | Blanco y crema con destellos (están) | Diamante tallado |

⚠️ **Rubí y esmeralda necesitan dos colores nuevos**: hay que cambiar la paleta (D-032) con su propia decisión. El rojo choca con la regla C7 («sin rojo de error»), aunque aquí es una gema y no un error; conviene un rojo **rubí oscuro**, lejos del rojo de alerta (P5).

## 4. Impacto técnico (estimado, opción B)

| Capa | Cambio |
|---|---|
| Dominio | `GameRound` pasa de 3 a 8 valores; cada ronda nueva = Reto máximo + una variación (`RoundVariation`: temática, mezcla, azar, sin ayudas). Medallas y récords por ronda (el modelo común de HU-037 ya los guarda por ronda) |
| Datos | Las rondas se guardan por nombre: añadir rondas no rompe lo guardado. Sin typeId nuevo |
| Presentación | `MedalBadge` con las 8 medallas; selector de ronda de la Zona de Padres con las nuevas (HU-046); celebración con el niño (HU-049) |
| Contenido | Depende de que existan las temáticas (HU-052) |

## 5. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Más dificultad, más variedad o maestría? | **Más variedad (B)**: metas nuevas sin frustración |
| P2 | ¿Se hacen las 5 a la vez o de una en una? | **De una en una**, empezando por el **rubí con la temática de vehículos** (HU-052), que es lo que pide el dueño a la vez |
| P3 | ¿Las rondas nuevas se activan solas al ganar el oro, o las activa el adulto? | **Solas**, como el paso de Fácil a Normal, pero con una celebración de «¡Nuevo reto!» y la posibilidad de volver al Reto máximo en la Zona de Padres |
| P4 | ¿Cambian el dorado del botón? | **No**: el dorado sigue siendo bronce + plata + oro; las nuevas añaden un brillo o un borde de gema, sin bajar lo ganado |
| P5 | ¿Se aceptan dos colores nuevos (rubí y esmeralda) en la paleta? | **Sí, como colores solo de medallas**, igual que el bronce y la plata (HU-037 P17), con su decisión en la especificación |
| P6 | ¿Son Premium? | **Sí, a partir del rubí**, encaja con D-039 (lo nuevo llega con Premium); bronce, plata y oro siguen como hoy |
