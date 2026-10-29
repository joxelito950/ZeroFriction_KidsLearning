# HU-007 · Sombras: arrastrar cada objeto a su silueta

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-10-29) |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: es el próximo juego |
| **Tamaño** | L (estimación previa; se confirma al cerrar las preguntas) |
| **Depende de** | HU-022 (tutorial visual, P3). Se refina junto con HU-030 (dificultad, P7) |

## 1. Historia

**Como** niño o niña de 3 años,
**quiero** arrastrar cada dibujo hasta la sombra que tiene su misma forma,
**para** practicar el reconocimiento de formas y la coordinación entre la vista y la mano, sin miedo a equivocarme.

**Como** madre, padre o adulto a cargo,
**quiero** un segundo juego tan tranquilo como el de memoria,
**para** que la app tenga variedad sin perder la paz mental que promete.

## 2. Situación actual

- El README describe el **módulo 2 (Emparejamiento, Shadow Matching)**: arrastrar y soltar objetos coloridos hacia su silueta. No hay nada desarrollado.
- La app tiene un solo juego (memoria, HU-001). El menú muestra un botón por juego (HU-001 R1), así que un segundo botón cabe sin rediseñar el menú (HU-023 hace falta antes del tercer juego).
- Reglas que ya aplican a todo juego: sin botones dentro del juego y avance automático (D-022), salida protegida (D-025), estrellas y dorado progresivo (D-030), pérdida de logros con la práctica (D-031), emojis de Emoji 5.0 o anterior (D-024), paleta cerrada (D-032), sin narración (D-034).
- El README dice, en sus reglas de negocio: «si el niño se equivoca, el objeto regresa a su origen con una animación suave».

## 3. Comportamiento propuesto

### 3.1 Pantalla

- **Zona de sombras:** las siluetas, repartidas con espacio entre ellas.
- **Bandeja:** los objetos en color, en orden aleatorio.
- En vertical, las sombras van arriba y la bandeja abajo; en horizontal, una al lado de la otra. Como en la memoria, sin scroll ni recortes desde 914 × 411 dp (D-011, D-013).
- Encabezado con el indicador de nivel de 5 puntos, como en la memoria (HU-001 S4).

### 3.2 Escalera (propuesta, P2)

| Nivel | Objetos | Sombras | Qué lo hace más difícil |
|---|---|---|---|
| 1 | 2 | 2 | Formas muy distintas (de temáticas diferentes) |
| 2 | 3 | 3 | Más objetos |
| 3 | 4 | 4 | Más objetos |
| 4 | 4 | 5 | Una sombra sobra (distractor) |
| 5 (máximo) | 5 | 6 | Todo de la misma temática: formas más parecidas |

### 3.3 Reglas

| # | Regla |
|---|---|
| R1 | El menú muestra un segundo botón, **«Sombras»** (nombre por confirmar en los 9 idiomas), debajo de «Memoria». |
| R2 | Cada tablero muestra los objetos de su nivel (tabla 3.2) en la bandeja y sus sombras en la zona de sombras, en posiciones al azar. |
| R3 | **Arrastrar:** el objeto sigue al dedo y se ve un poco más grande mientras se arrastra. |
| R4 | **Acierto:** si se suelta sobre su sombra, o cerca de ella (zona **magnética**, P3), el objeto encaja con una animación suave y queda fijo en color sobre la sombra. |
| R5 | **Fallo:** si se suelta sobre otra sombra o fuera de cualquier sombra, el objeto **vuelve a la bandeja** con una animación suave. Sin sonido de error, sin vibración, sin rojo (README; sección 4.2 de la especificación). |
| R6 | **Sin tiempo y sin derrota:** el juego no tiene cronómetro. No se puede perder ni bajar de nivel (P4). |
| R7 | **Al completar el tablero:** la misma celebración breve que la memoria (unos 2 s, sin botón, con las estrellas) y paso automático al siguiente nivel (D-022). |
| R8 | **Estrellas** por fallos de forma: 3★ sin fallos; 2★ con como mucho tantos fallos como objetos; 1★ hasta el doble; 0 por encima (P5). Soltar en el vacío no cuenta como fallo (es imprecisión del dedo, no un error de forma). |
| R9 | **Insignia** al superar el nivel 5, permanente como la de la memoria. Después se vuelve a empezar en el nivel 1 (como HU-001 R8). |
| R10 | **Contenido:** emojis elegidos **por su silueta**, no por su cara (ver 3.4). Las sombras se dibujan con el mismo emoji pintado de un solo color de la paleta, así que **siempre** coinciden con el objeto, sea cual sea el fabricante del teléfono. |
| R11 | **Persistencia:** como la memoria: nivel actual, insignia, mejor resultado en estrellas por nivel con su fecha y fecha de la última partida (para HU-002 y D-031). |
| R12 | **Tutorial:** la primera vez, y tras unos segundos sin tocar nada, la mano animada de HU-022 arrastra un objeto hasta su sombra (P1). |
| R13 | **Lector de pantalla:** cada objeto y cada sombra se anuncian con su emoji (como las cartas de la memoria) y se pueden emparejar sin arrastrar: se elige el objeto y después la sombra. |
| R14 | Un objeto ya encajado no se puede volver a mover. Mientras se arrastra uno, los demás no responden (un solo dedo). |

### 3.4 Contenido

En la memoria, muchos emojis son **caras** (🐮 🐷 🦁): su silueta es casi un círculo y no sirven aquí. Para las sombras se eligen emojis de **cuerpo entero o de perfil**, con formas que se distinguen sin color. Propuesta inicial (Emoji 5.0 o anterior, sin ZWJ):

| Temática | Emojis |
|---|---|
| Animales | 🐘 🦒 🐢 🐌 🦋 🐟 🐳 🐊 🐇 🐓 🦆 🐈 |
| Dinosaurios | 🦕 🦖 |
| Vehículos | 🚗 🚲 🚁 🚀 ✈️ ⛵ 🚂 🚜 |
| Frutas | 🍌 🍐 🍇 🍒 🍎 🍉 |
| Objetos | 🔑 ✂️ ☂️ 🔨 🔧 🎈 ⏰ |

La lista final se valida viendo las siluetas en el moto g55 y en un emulador con otra fuente de emojis. Una silueta que se confunda con otra no entra.

### 3.5 Colores (paleta, D-032)

| Elemento | Color |
|---|---|
| Fondo | Crema cálido |
| Sombras | Teal profundo (9,73:1 sobre crema; como elemento no textual, solo necesita 3:1) |
| Objetos | Sus colores de emoji (son contenido, como las cartas de la memoria) |
| Celebración y estrellas | Ámbar y dorado, como en la memoria |

Sin colores nuevos.

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-022, D-025 | Se aplican sin cambios: sin botones dentro del juego y salida protegida |
| D-020, D-021 | No aplican: este juego no tiene tiempo (P4) |
| D-028 (modelo de acceso) | Hay que decidirlo (P6) |
| D-030 (estrellas) | Mismo concepto (0–3★ por nivel, se guarda la mejor) con un cálculo propio basado en fallos (R8) |
| D-031, HU-002, HU-016 | Aplican por juego: este juego tendrá su propio dorado y su propia pérdida de logros |
| D-024, D-026 | Solo emojis de Emoji 5.0 o anterior |
| D-034 | El juego se entiende mirando; por eso depende de HU-022 |
| HU-030 (dificultad) | Este juego define sus tres niveles (P7) |
| HU-005 (sonido) | Cuando exista, encajar un objeto suena igual de suave que encontrar una pareja; fallar no suena |

## 5. Criterios de aceptación (borrador)

1. **Dado** el menú, **entonces** veo el botón «Sombras» debajo de «Memoria» y al tocarlo empieza el nivel en el que me quedé (el 1 la primera vez).
2. **Dado** un tablero, **cuando** suelto un objeto sobre su sombra o dentro de su zona magnética, **entonces** encaja y queda fijo.
3. **Dado** un tablero, **cuando** suelto un objeto sobre otra sombra o en el vacío, **entonces** vuelve a la bandeja con una animación suave, sin sonido ni color de error.
4. **Dado** que encajo el último objeto, **entonces** veo la celebración con las estrellas y paso solo al siguiente nivel.
5. **Dado** el nivel 5 superado, **entonces** consigo la insignia, aparece la medalla en el menú y vuelvo al nivel 1.
6. **Dado** que salgo y vuelvo a entrar, **entonces** sigo en el mismo nivel y conservo estrellas e insignia.
7. **Dado** el juego en vertical y en horizontal, en los dos teléfonos de los tests de diseño y en los 9 idiomas (incluido el árabe RTL), **entonces** nada se recorta ni necesita scroll.
8. **Dado** TalkBack activo, **entonces** puedo emparejar cada objeto con su sombra sin arrastrar.
9. **Dado** el catálogo de contenido, **entonces** todos los emojis son de Emoji 5.0 o anterior (test, como en la memoria).
10. **Dado** el código, **entonces** solo usa colores de la paleta (`palette_test.dart`).

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `domain/shadows/`: escalera (`ShadowLadder`), catálogo de contenido (`ShadowThemes`), estrellas (`ShadowStars`). Dart puro, como `domain/memory/` |
| Estado | `ShadowGameCubit`: tablero, objetos encajados, fallos, victoria y paso de nivel |
| Persistencia | Progreso propio con el mismo formato que `MemoryProgress` (nivel, insignia, estrellas por nivel, fechas). Necesita un **typeId nuevo**: el 3 está reservado para `ParentalSettings` (HU-009), así que sería el **4** (P8). Actualizar la sección 3.4 de la especificación |
| Presentación | `ShadowGameScreen`, widgets de objeto y sombra (`Draggable`/`DragTarget`; silueta con `ColorFiltered` y `BlendMode.srcIn`), segundo botón en `MainMenuScreen` |
| Reutilización | Celebración, indicador de nivel, salida protegida y medalla de la memoria. Si alguno está atado a la memoria, se generaliza en la primera entrega |
| Catálogo | Nombre del juego, etiquetas del lector de pantalla y mensajes en los 9 idiomas |
| Tests | Dominio (escalera, estrellas, contenido de Emoji 5.0), cubit, widgets (arrastrar y soltar, zona magnética, vuelta a la bandeja), layout en los 9 idiomas y en las dos orientaciones, compatibilidad de datos |

## 7. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿HU-022 (tutorial visual) se hace antes, como historia propia, o dentro de HU-007? | **Antes, como historia propia y pequeña.** HU-007 es el primer juego que la necesita, pero la van a usar todos los juegos | Sí |
| P2 | ¿La escalera de la tabla 3.2 (5 niveles, de 2 a 5 objetos, con distractores en los niveles 4 y 5)? | Aceptarla: 5 niveles como la memoria, para que el indicador, la insignia y el dorado se entiendan igual | Sí |
| P3 | ¿Zona magnética al soltar? | **Sí:** el objeto encaja si se suelta a menos de media sombra de distancia. A los 3 años, la precisión del dedo todavía es baja | No |
| P4 | ¿El juego tiene tiempo, como la memoria? | **No.** El reto está en la forma, no en la velocidad. Sin tiempo no hay derrota, y la dificultad la ponen el número de objetos y los distractores | Sí |
| P5 | ¿Estrellas por fallos de forma (R8)? | Aceptarlo y calibrar los umbrales por simulación al desarrollar, como en HU-002 | No |
| P6 | Modelo de acceso (D-028): ¿niveles gratis y Premium, o 100 % Premium? | **100 % gratis en esta historia.** El pago (HU-006) aún no existe; más adelante, temáticas Premium extra sin tocar los 5 niveles gratis | Sí |
| P7 | ¿Qué cambia en cada nivel de dificultad de HU-030? | **Fácil:** zona magnética más grande y sin distractores. **Normal:** la tabla 3.2. **Imposible:** un objeto más por nivel, dos distractores y siluetas de la misma temática desde el nivel 3. Se cierra al refinar HU-030 | No |
| P8 | ¿Progreso propio (typeId 4) o un modelo común para todos los juegos? | **Propio en esta historia**, con el mismo formato que la memoria. Un modelo común se decide cuando haya un tercer juego (HU-023) | No |
| P9 | Nombre del juego en el menú | «Sombras» en español; en inglés «Shadows». Traducción en los 9 idiomas con la revisión de TD-011 | No |

## 8. Fuera de alcance

- Pago y candado Premium (HU-006).
- Ilustraciones propias: las siluetas salen de los emojis (D-024). Las ilustraciones en vector quedan para HU-028.
- Siluetas giradas o en espejo (posible nivel Imposible, P7).
- Rediseño del menú para varios juegos (HU-023).
- Sonidos (HU-005).
