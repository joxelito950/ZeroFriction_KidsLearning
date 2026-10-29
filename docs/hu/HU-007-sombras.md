# HU-007 · Sombras: arrastrar cada objeto a su silueta

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-10-29; decisiones principales tomadas, quedan las preguntas de la sección 8) |
| **Épica** | E4 · Nuevos juegos (y E3 · Premium) |
| **Prioridad** | P2: es el próximo juego |
| **Tamaño** | L (estimación previa; se confirma al cerrar el refinamiento) |
| **Depende de** | HU-022 (tutorial visual), que se refina y desarrolla **antes** (P1). Lee `isPremium`; la compra llega con HU-006 (P10). Se coordina con HU-030 (dificultad, P7) |

## 1. Historia

**Como** niño o niña de 3 años,
**quiero** arrastrar cada dibujo hasta la sombra que tiene su misma forma,
**para** practicar el reconocimiento de formas y la coordinación entre la vista y la mano, sin miedo a equivocarme.

**Como** madre, padre o adulto a cargo,
**quiero** un segundo juego tan tranquilo como el de memoria, con un reto extra si compro Premium,
**para** que la app tenga variedad y el pago único tenga un valor claro.

## 2. Situación actual

- El README describe el **módulo 2 (Emparejamiento, Shadow Matching)**: arrastrar y soltar objetos coloridos hacia su silueta. No hay nada desarrollado.
- La app tiene un solo juego (memoria, HU-001). El menú muestra un botón por juego (HU-001 R1), así que un segundo botón cabe sin rediseñar el menú (HU-023 hace falta antes del tercer juego).
- `UserProfile.isPremium` ya se guarda, pero nadie lo lee (sección 9 de la especificación). No existe el pago (HU-006).
- Reglas que ya aplican a todo juego: sin botones dentro del juego y avance automático (D-022), salida protegida (D-025), estrellas y dorado progresivo (D-030), pérdida de logros con la práctica (D-031), emojis de Emoji 5.0 o anterior (D-024), paleta cerrada (D-032), sin narración (D-034).
- El README dice, en sus reglas de negocio, que un error devuelve el objeto a su origen con una animación suave, y que lo Premium se marca con un **candado sutil**.

## 3. Modelo de acceso (D-028, decidido el 2026-10-29)

| | Gratis | Premium |
|---|---|---|
| Niveles | 1 a 7 | 1 a 8 |
| Tiempo | Nunca | Barra de tiempo como en la memoria (sección 4.3) |
| Estrellas por nivel | Hasta 2★ | Hasta 3★: la 3.ª exige superar el nivel con tiempo |
| Dorado progresivo (HU-002) | Como mucho 14 de 24 estrellas (unos dos tercios) | Hasta el 100 % |
| Medalla | No | Al superar el nivel 8 |
| Al superar el último nivel disponible | Vuelve al nivel 1 | Medalla y vuelve al nivel 1 (como HU-001 R8) |

El ajuste de dificultad de HU-030 aplica en los dos modos (P7).

## 4. Comportamiento propuesto

### 4.1 Pantalla

- **Zona de sombras:** las siluetas, repartidas con espacio entre ellas.
- **Bandeja:** los objetos en color, en orden aleatorio.
- En vertical, las sombras van arriba y la bandeja abajo; en horizontal, una al lado de la otra. Como en la memoria, sin scroll ni recortes desde 914 × 411 dp (D-011, D-013).
- Encabezado: indicador de nivel con **8 puntos**, como el de la memoria (HU-001 S4). Sin Premium, el octavo lleva un **candado sutil** y no se puede tocar. Con Premium, la barra de tiempo aparece debajo, como en la memoria (D-021).

### 4.2 Escalera de 8 niveles (propuesta, P2)

| Nivel | Objetos | Sombras | Qué lo hace más difícil | Acceso |
|---|---|---|---|---|
| 1 | 2 | 2 | Formas muy distintas (de temáticas diferentes) | Gratis |
| 2 | 3 | 3 | Más objetos | Gratis |
| 3 | 4 | 4 | Más objetos | Gratis |
| 4 | 4 | 5 | Una sombra sobra (distractor) | Gratis |
| 5 | 5 | 6 | Más objetos y un distractor | Gratis |
| 6 | 5 | 6 | Todo de la misma temática: formas más parecidas | Gratis |
| 7 | 6 | 7 | Misma temática, más objetos | Gratis |
| 8 (máximo) | 6 | 8 | Misma temática y dos distractores | **Premium** |

Con 6 objetos y 8 sombras, el teléfono compacto en horizontal es el caso límite: los tests de diseño lo validan antes de cerrar la tabla.

### 4.3 Tiempo con Premium (propuesta, P3)

Funciona como en la memoria (HU-001 R3–R6, R10, R11, R16): el nivel 1 sin tiempo; al ganar, se sube de nivel y el límite pasa al siguiente de la serie; al perder (la barra llega a 0), se baja un nivel conservando el límite; perder en el nivel 1 cronometrado reinicia sin tiempo. Perder se comunica como ayuda, con un mensaje que hay que adaptar («¡Se acabó el tiempo! Probemos con menos objetos»).

| Nivel | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| Límite con el que se llega subiendo | Sin tiempo | 90 s | 75 s | 60 s | 50 s | 40 s | 35 s | 30 s |

Para un adulto, encajar un objeto cuesta alrededor de 1 s, así que el nivel 8 (6 objetos) se hace en unos 8 s. La serie se calibra con el niño de pruebas antes de cerrar el refinamiento. HU-030 la multiplica en Fácil y la recorta en Imposible.

### 4.4 Reglas

| # | Regla |
|---|---|
| R1 | El menú muestra un segundo botón, **«Sombras»** (nombre en los 9 idiomas, P9), debajo de «Memoria». |
| R2 | Cada tablero muestra los objetos de su nivel (tabla 4.2) en la bandeja y sus sombras en la zona de sombras, en posiciones al azar. |
| R3 | **Arrastrar:** el objeto sigue al dedo y se ve un poco más grande mientras se arrastra. |
| R4 | **Acierto:** si se suelta sobre su sombra, o cerca de ella (zona **magnética**, P4), el objeto encaja con una animación suave y queda fijo en color sobre la sombra. |
| R5 | **Fallo:** si se suelta sobre otra sombra o fuera de cualquier sombra, el objeto **vuelve a la bandeja** con una animación suave. Sin sonido de error, sin vibración, sin rojo (README; sección 4.2 de la especificación). |
| R6 | **Gratis:** sin tiempo y sin derrota; no se puede bajar de nivel. Al superar el nivel 7 se vuelve al nivel 1, sin medalla. |
| R7 | **Premium:** tiempo y escalera según la sección 4.3. El cronómetro arranca al tocar el primer objeto y se pausa en segundo plano y durante las transiciones (como HU-001 R10 y R11). |
| R8 | **Al completar el tablero:** la misma celebración breve que la memoria (unos 2 s, sin botón, con las estrellas) y paso automático al siguiente nivel (D-022). |
| R9 | **Estrellas** (P5). Se cuentan los **fallos de forma**, es decir, soltar sobre una sombra equivocada. Soltar en el vacío no cuenta: es imprecisión del dedo, no un error de forma. Con N objetos en el tablero: **1★** con como mucho 2N fallos; **2★** con como mucho N fallos; **3★** con como mucho N fallos **y** superado con tiempo. En el nivel 1, que nunca tiene tiempo, la 3.ª estrella se gana sin fallos en modo Premium (P6). Cada nivel guarda su mejor resultado (D-030). |
| R10 | **Medalla** al superar el nivel 8 (solo con Premium), permanente como la de la memoria. Después se vuelve a empezar en el nivel 1. |
| R11 | **Candado sutil:** sin Premium, el nivel 8 se ve en el indicador con un candado. Ni el candado ni nada del juego invita al niño a comprar ni abre la tienda: la compra solo existe en la Zona de Padres, tras el control para adultos (HU-006, D-029, política de familias de Google Play). |
| R12 | **Comprar Premium a mitad de partida** activa el tiempo y el nivel 8 en el **siguiente** tablero. Las estrellas ganadas sin tiempo se conservan y se pueden mejorar. |
| R13 | **Contenido:** emojis elegidos **por su silueta**, no por su cara (sección 4.5). Las sombras se dibujan con el mismo emoji pintado de un solo color de la paleta, así que **siempre** coinciden con el objeto, sea cual sea el fabricante del teléfono. |
| R14 | **Persistencia:** como la memoria: nivel actual, medalla, mejor resultado en estrellas por nivel con su fecha y fecha de la última partida (para HU-002 y D-031). Con Premium no se guarda el tiempo: se deduce del nivel (como HU-001 R12). |
| R15 | **Tutorial:** la primera vez, y tras unos segundos sin tocar nada, la mano animada de HU-022 arrastra un objeto hasta su sombra. |
| R16 | **Lector de pantalla:** cada objeto y cada sombra se anuncian con su emoji (como las cartas de la memoria) y se pueden emparejar sin arrastrar: se elige el objeto y después la sombra. |
| R17 | Un objeto ya encajado no se puede volver a mover. Mientras se arrastra uno, los demás no responden (un solo dedo). |

### 4.5 Contenido

En la memoria, muchos emojis son **caras** (🐮 🐷 🦁): su silueta es casi un círculo y no sirven aquí. Para las sombras se eligen emojis de **cuerpo entero o de perfil**, con formas que se distinguen sin color. Propuesta inicial (Emoji 5.0 o anterior, sin ZWJ):

| Temática | Emojis |
|---|---|
| Animales | 🐘 🦒 🐢 🐌 🦋 🐟 🐳 🐊 🐇 🐓 🦆 🐈 |
| Dinosaurios | 🦕 🦖 |
| Vehículos | 🚗 🚲 🚁 🚀 ✈️ ⛵ 🚂 🚜 |
| Frutas | 🍌 🍐 🍇 🍒 🍎 🍉 |
| Objetos | 🔑 ✂️ ☂️ 🔨 🔧 🎈 ⏰ |

Los niveles 6 a 8 necesitan al menos 8 emojis de una misma temática; Animales, Vehículos y Objetos los tienen. La lista final se valida viendo las siluetas en el moto g55 y en un emulador con otra fuente de emojis. Una silueta que se confunda con otra no entra.

### 4.6 Colores (paleta, D-032)

| Elemento | Color |
|---|---|
| Fondo | Crema cálido |
| Sombras | Teal profundo (9,73:1 sobre crema; como elemento no textual, solo necesita 3:1) |
| Objetos | Sus colores de emoji (son contenido, como las cartas de la memoria) |
| Barra de tiempo, celebración y estrellas | Como en la memoria |
| Candado del nivel 8 | Teal profundo con transparencia, como el resto de puntos no alcanzados |

Sin colores nuevos.

## 5. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-028 (modelo de acceso) | Primer juego con niveles gratis y Premium (sección 3). Nueva decisión para la sección 8 de la especificación: **el tiempo, el nivel 8, la 3.ª estrella y la medalla de Sombras son Premium** |
| D-020, D-021 | El tiempo de Premium sigue la misma lógica y la misma barra; la serie es propia (4.3) |
| D-022, D-025 | Sin cambios: sin botones dentro del juego y salida protegida |
| D-029, HU-006 | La compra solo existe en la Zona de Padres; el juego nunca la ofrece al niño (R11) |
| D-030 (estrellas) | Mismo concepto (0–3★ por nivel, se guarda la mejor) con un cálculo propio (R9). La 3.ª estrella exige tiempo |
| D-031, HU-002, HU-016 | Aplican por juego: Sombras tendrá su propio dorado y su propia pérdida de logros |
| D-024, D-026 | Solo emojis de Emoji 5.0 o anterior |
| D-034 | El juego se entiende mirando; por eso HU-022 va antes |
| HU-030 (dificultad) | Ajusta la serie de tiempos y los distractores (P7) |
| HU-005 (sonido) | Cuando exista, encajar un objeto suena igual de suave que encontrar una pareja; fallar no suena |
| Sección 9 de la especificación | `isPremium` pasa a leerse por primera vez |

## 6. Criterios de aceptación (borrador)

1. **Dado** el menú, **entonces** veo el botón «Sombras» debajo de «Memoria» y al tocarlo empieza el nivel en el que me quedé (el 1 la primera vez).
2. **Dado** un tablero, **cuando** suelto un objeto sobre su sombra o dentro de su zona magnética, **entonces** encaja y queda fijo.
3. **Dado** un tablero, **cuando** suelto un objeto sobre otra sombra o en el vacío, **entonces** vuelve a la bandeja con una animación suave, sin sonido ni color de error.
4. **Dado** que encajo el último objeto, **entonces** veo la celebración con las estrellas y paso solo al siguiente nivel.
5. **Dado** que no tengo Premium, **entonces** no hay barra de tiempo, el indicador muestra el nivel 8 con candado, ningún nivel da más de 2★ y, al superar el nivel 7, vuelvo al nivel 1 sin medalla.
6. **Dado** que tengo Premium, **entonces** desde el nivel 2 hay barra de tiempo con los límites de la sección 4.3; al perder bajo un nivel conservando el límite, y al superar el nivel 8 consigo la medalla.
7. **Dado** que tengo Premium, **cuando** supero un nivel con tiempo y como mucho tantos fallos como objetos, **entonces** gano 3★.
8. **Dado** un tablero en juego, **cuando** se activa Premium, **entonces** el tiempo y el nivel 8 aparecen en el siguiente tablero y conservo las estrellas ganadas.
9. **Dado** cualquier pantalla del juego, **entonces** no hay ningún botón ni enlace de compra al alcance del niño.
10. **Dado** que salgo y vuelvo a entrar, **entonces** sigo en el mismo nivel y conservo estrellas y medalla.
11. **Dado** el juego en vertical y en horizontal, en los dos teléfonos de los tests de diseño y en los 9 idiomas (incluido el árabe RTL), **entonces** nada se recorta ni necesita scroll, también en el nivel 8.
12. **Dado** TalkBack activo, **entonces** puedo emparejar cada objeto con su sombra sin arrastrar.
13. **Dado** el catálogo de contenido, **entonces** todos los emojis son de Emoji 5.0 o anterior (test, como en la memoria).
14. **Dado** el código, **entonces** solo usa colores de la paleta (`palette_test.dart`).

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `domain/shadows/`: escalera con tiempo opcional (`ShadowLadder`), catálogo de contenido (`ShadowThemes`), estrellas (`ShadowStars`) y reglas de acceso (qué niveles y qué tiempo según `isPremium`). Dart puro, como `domain/memory/` |
| Estado | `ShadowGameCubit`: tablero, objetos encajados, fallos, tiempo (con Premium), victoria, derrota y paso de nivel. Escucha los cambios de `isPremium` para aplicarlos en el siguiente tablero (R12) |
| Persistencia | Progreso propio con el mismo formato que `MemoryProgress`. Necesita un **typeId nuevo**: el 3 está reservado para `ParentalSettings` (HU-009), así que sería el **4** (P8). Actualizar la sección 3.4 de la especificación |
| Premium sin pago | Mientras no exista HU-006, `isPremium` es siempre `false` en las versiones publicadas. Para probar la parte Premium en el teléfono: un interruptor **solo en compilaciones de depuración** (`kDebugMode`), que un test de arquitectura impide que llegue al *release* (P10) |
| Presentación | `ShadowGameScreen`, widgets de objeto y sombra (`Draggable`/`DragTarget`; silueta con `ColorFiltered` y `BlendMode.srcIn`), indicador de 8 puntos con candado y segundo botón en `MainMenuScreen` |
| Reutilización | Celebración, indicador de nivel, barra de tiempo, mensaje de derrota, salida protegida y medalla de la memoria. Lo que esté atado a la memoria se generaliza en la primera entrega |
| Catálogo | Nombre del juego, mensaje de derrota, etiquetas del lector de pantalla (incluido «nivel bloqueado») en los 9 idiomas |
| Tests | Dominio (escalera gratis y Premium, estrellas, contenido de Emoji 5.0), cubit (activar Premium a mitad), widgets (arrastrar y soltar, zona magnética, vuelta a la bandeja, candado), layout en los 9 idiomas y las dos orientaciones, compatibilidad de datos y ausencia del interruptor de depuración en *release* |

## 8. Preguntas y decisiones

| # | Pregunta | Decisión o recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿HU-022 (tutorial visual) va antes, como historia propia, o dentro de HU-007? | ✅ Decidido (2026-10-29): **antes, como historia propia** | — |
| P2 | ¿Cuántos niveles? | ✅ Decidido (2026-10-29): **más que los 5 de la memoria**. Propuesta: los 8 de la tabla 4.2. Falta confirmar la tabla | Sí |
| P3 | ¿El juego tiene tiempo? | ✅ Decidido (2026-10-29): **solo con Premium, automático como en la memoria** (sección 4.3). Falta calibrar la serie de límites | Sí |
| P4 | ¿Zona magnética al soltar? | Recomendación: **sí**; el objeto encaja si se suelta a menos de media sombra de distancia. A los 3 años, la precisión del dedo todavía es baja | No |
| P5 | ¿Cómo se ganan las estrellas? | ✅ Decidido (2026-10-29): **la 3.ª estrella solo con tiempo**. Los umbrales de R9 se calibran por simulación, como en HU-002 | No |
| P6 | El nivel 1 nunca tiene tiempo: ¿cómo se gana su 3.ª estrella? | Recomendación: **sin fallos, en modo Premium** (R9) | Sí |
| P7 | ¿Qué cambia en cada nivel de dificultad de HU-030? | Recomendación: **Fácil:** tiempos ×3, zona magnética más grande y sin distractores. **Normal:** las tablas 4.2 y 4.3. **Imposible:** tiempos recortados y un distractor más. Se cierra al refinar HU-030 | No |
| P8 | ¿Progreso propio (typeId 4) o un modelo común para todos los juegos? | Recomendación: **propio en esta historia**, con el mismo formato que la memoria. Un modelo común se decide antes del tercer juego (HU-023) | No |
| P9 | Nombre del juego en el menú | Recomendación: «Sombras» en español y «Shadows» en inglés; los 9 idiomas pasan por la revisión de TD-011 | No |
| P10 | ¿Se desarrolla antes de que exista el pago (HU-006)? | ✅ Decidido (2026-10-29): **sí, con candado**. Lo gratis funciona; lo Premium queda bloqueado hasta HU-006 y se prueba con tests y con el interruptor de depuración | — |
| P11 | Sin Premium, ¿qué pasa al superar el nivel 7? | ✅ Decidido (2026-10-29): **vuelve al nivel 1** (R6) | — |

## 9. Fuera de alcance

- El flujo de compra y la restauración (HU-006).
- Ilustraciones propias: las siluetas salen de los emojis (D-024). Las ilustraciones en vector quedan para HU-028.
- Siluetas giradas o en espejo (posible nivel Imposible, P7).
- Rediseño del menú para varios juegos (HU-023).
- Sonidos (HU-005).
