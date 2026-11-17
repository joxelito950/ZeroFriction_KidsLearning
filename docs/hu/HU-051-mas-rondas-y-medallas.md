# HU-051 · Ocho rondas: de bronce a diamante

| | |
|---|---|
| **Estado** | **Casi lista** (2026-11-17): P1 a P6 decididas y colores nuevos aprobados. Falta confirmar P7 (cómo se baja de ronda sin tutorial en cada ronda) |
| **Épica** | E1 · Juegos (progresión) |
| **Prioridad** | **P1** (cambia el modelo de rondas: conviene antes de la pantalla «Su progreso» y de más juegos) |
| **Tamaño** | L (4 entregas, más de una semana) |
| **Depende de** | HU-037 (rondas y medallas, D-038), HU-048 (medalla propia). Cambia HU-007, HU-025, HU-030, HU-034, HU-046, HU-049 y HU-050 (sección 7) |

## 1. Historia

**Como** niño o niña,
**quiero** subir poco a poco, con muchas medallas por el camino,
**para** sentir que avanzo a menudo y no chocar con un salto de dificultad que me frustre.

**Como** adulto,
**quiero** que la dificultad suba en pasos pequeños,
**para** que mi hijo encuentre su nivel y lo note cuando mejora.

## 2. La propuesta del dueño (2026-11-17)

- **El Reto máximo actual pasa a ser el diamante**: la cima no se vuelve más difícil.
- Entre el Fácil actual y el diamante, la dificultad, las ayudas y los tiempos **se reparten en pasos**: **bronce, plata, oro, rubí, esmeralda, zafiro, obsidiana y diamante**.
- Durante la prueba cerrada **no importa que baje el dorado** ni recalcular los logros.

Sustituye la primera versión de esta historia (las rondas nuevas como variaciones del Reto máximo): ya no hacen falta temáticas para cada medalla, y HU-052 (vehículos) queda independiente.

### Por qué es mejor que la primera versión

- **Pasos más pequeños.** Hoy, de Fácil a Normal, el primer nivel de la memoria pasa de 270 s a 90 s (un tercio del tiempo) y, de Normal a Reto máximo, se pierde la vista previa a la vez que el tiempo se reduce a la mitad. Son saltos grandes. Con 8 rondas, cada paso cambia **una o dos cosas**.
- **Bajar de ronda frustra menos.** La regla de HU-037 (R10: dos caídas al tutorial, ronda anterior) baja ahora un escalón pequeño, no de Normal a Fácil.
- **Más medallas, más a menudo**, sin hacer la cima más difícil.

## 3. Cómo se reparte la dificultad

Cada juego tiene unos «diales»: tiempo, ayudas y exigencia. Bronce es el Fácil actual y diamante, el Reto máximo actual. En medio, cada ronda gira uno o dos diales.

### 3.1 Memoria

Los tableros no cambian (tutorial 2×2, después 2×3, 2×4, 3×4 y 4×4). Cambian el tiempo y la vista previa.

| Ronda | Tiempo del primer nivel → último | Vista previa de las cartas |
|---|---|---|
| Bronce | 270 → 90 s (el Fácil de hoy) | 2 s |
| Plata | 210 → 70 s | 1,5 s |
| Oro | 160 → 55 s | 1 s |
| Rubí | 125 → 42 s | 1 s |
| Esmeralda | 95 → 32 s | 0,7 s |
| Zafiro | 75 → 25 s | 0,5 s |
| Obsidiana | 58 → 20 s | Sin vista previa |
| Diamante | 45 → 15 s (el Reto máximo de hoy) | Sin vista previa |

Los tiempos bajan un 22–25 % por ronda (una serie geométrica de 270 s a 45 s), que es un cambio que se nota sin ser brusco. El Normal de hoy (90 → 30 s) queda entre el rubí y la esmeralda.

### 3.2 Sombras

| Ronda | Tiempo del primer nivel → último | Solape para encajar | Sombras libres | Animación de inicio | Disposición |
|---|---|---|---|---|---|
| Bronce | 90 → 30 s | 40 % | No | Sí | Fija |
| Plata | 80 → 29 s | 45 % | No | Sí | Fija |
| Oro | 70 → 27 s | 50 % | Sí | Sí | Fija |
| Rubí | 65 → 25 s | 60 % | Sí | Sí | Fija |
| Esmeralda | 60 → 24 s | 65 % | Sí | No | Fija |
| Zafiro | 55 → 22 s | 70 % | Sí | No | Fija |
| Obsidiana | 52 → 21 s | 80 % | Sí | No | Al azar |
| Diamante | 50 → 20 s | **90 %** (HU-050 P3) | Sí | No | Al azar |

En Sombras el dial principal es el **solape**, no el tiempo (los tiempos de hoy ya están muy juntos). El aviso de «casi» de HU-050 se ve en todas las rondas.

### 3.3 ¿Cuál es diferente?

| Ronda | Tiempo del primer nivel → último | Qué se compara |
|---|---|---|
| Bronce | 60 → 40 s | Idénticos (niveles 2 y 3) y colores |
| Plata | 52 → 35 s | Colores |
| Oro | 45 → 30 s | Grupos muy distintos (el Normal de hoy) |
| Rubí | 40 → 25 s | Grupos muy distintos y selva o granja |
| Esmeralda | 35 → 22 s | Selva o granja, y tierra o aire |
| Zafiro | 30 → 19 s | Tierra o aire, y tierra o agua |
| Obsidiana | 28 → 17 s | Tierra o agua, y ruedas o alas |
| Diamante | 25 → 15 s | Las cuatro comparaciones (el Reto máximo de hoy) |

Las comparaciones difíciles se presentan **de una en una**, en lugar de las cuatro de golpe al llegar al Reto máximo.

### 3.4 Las ocho medallas

Con `MedalBadge` (HU-048). Los metales llevan estrellas y las gemas, una **forma facetada** distinta del disco, para no depender solo del color:

| Medalla | Forma | Color |
|---|---|---|
| Bronce | Disco con ★ | Bronce `#B0603C` |
| Plata | Disco con ★★ | Plata `#748A8E` |
| Oro | Disco con ★★★ | Ámbar `#ECA463` con borde dorado `#A86B12` |
| Rubí | Gema | **Rubí oscuro (color nuevo; propuesto `#8E1F3B`)** |
| Esmeralda | Gema | **Verde esmeralda (color nuevo; propuesto `#1E7F5C`)** |
| Zafiro | Gema | Azul petróleo `#176B78` |
| Obsidiana | Gema | Teal profundo `#00454D` con reflejo crema |
| Diamante | Diamante tallado | Blanco y crema con destellos |

✅ **Aprobado por el dueño (2026-11-17):** rubí y esmeralda entran en la paleta como **colores exclusivos de las medallas**: **nunca** se usan en mensajes, textos, botones ni secciones. Se registra en PALETA.md con esa restricción y `palette_test` comprueba que solo los use `MedalBadge`. Los valores propuestos se ajustan al verlos en el moto g55. El rubí es oscuro, para no parecerse al rojo de un error (C7).

## 4. ¿Dónde está el límite? (pregunta del dueño)

**Recomendación: 8 rondas es el límite práctico.** Se pueden poner más técnicamente, pero cada una más rinde menos y cuesta más:

| Límite | Por qué |
|---|---|
| **La cima no sube** | El diamante es el Reto máximo de hoy, que ya es difícil para un adulto (HU-050). Más rondas solo **subdividen** el camino, no lo alargan hacia arriba |
| **Cada paso se tiene que notar** | Entre 270 s y 45 s hay 6 veces de diferencia. Con 8 rondas, cada paso baja un 22–25 %, que se nota. Con 12, cada paso bajaría un 15 % o menos: rondas casi iguales, medallas «de relleno» |
| **Los diales se acaban** | La memoria tiene 2 diales (tiempo y vista previa) y Sombras, 5. Con más de 8 rondas habría rondas que no cambian nada visible en algún juego |
| **El camino se alarga** | Cada ronda empieza por el tutorial y tiene 4 niveles con tiempo (más en Sombras). Con 8 rondas, completar la memoria son unos 40 tableros; con 12, unos 60. Para niños de 2 a 5 años, con sesiones de 15–30 minutos, eso son semanas |
| **Las medallas se tienen que distinguir** | 8 medallas ya exigen dos colores nuevos y formas distintas (lección de HU-048). Con 10 o 12, los niños no distinguirían unas de otras |
| **El dorado avanza más despacio** | Las estrellas totales se multiplican (memoria: de 36 a 96). Cada estrella llena menos el botón |

Si más adelante se quieren **más metas** después del diamante, mejor con **variedad** (temáticas como los vehículos de HU-052) que con más rondas de dificultad.

## 5. Reglas que cambian

- **R1.** Un juego nuevo empieza por el **tutorial**, que es el **nivel 0**: sin tiempo, sin estrellas y **solo una vez, al principio del juego** (P5). Después, bronce.
- **R2.** Completar una ronda da su medalla y pasa a la siguiente. En diamante se sigue en diamante (como HU-037 P4).
- **R3.** Bajar de ronda baja **un escalón**: de esmeralda a rubí, no hasta el principio. Como ya no hay tutorial en cada ronda, la regla de HU-037 R10 (dos caídas al tutorial) se adapta: **perder dos veces en el primer nivel de la ronda** baja a la anterior, en su primer nivel (P7).
- **R3b.** Cada ronda empieza en su **primer nivel con tiempo**. Al cambiar de ronda (porque se completa, se baja o lo cambia el adulto) no se repite el tutorial. La invitación a jugar (HU-037 R9, HU-049) aparece una sola vez, al terminar el tutorial.
- **R4.** Las rondas se llaman por su medalla: «Ronda oro», en el juego y en la Zona de Padres (los nombres Fácil, Normal y Reto máximo desaparecen).
- **R5.** El dorado del botón es la suma de las estrellas de las 8 rondas (sección 4: avanza más despacio).

## 6. Migración (durante la prueba cerrada)

Como el dueño acepta recalcular, la regla es simple:

| Hoy | Pasa a |
|---|---|
| Ronda Fácil, Normal, Reto máximo | Bronce, **oro** y **diamante** (la más parecida en dificultad) |
| Medalla de Fácil | Bronce |
| Medalla de Normal | Bronce, plata y oro |
| Medalla de Reto máximo | Todas hasta el diamante |
| Estrellas de cada nivel | Se quedan en la ronda a la que pasa la suya (Fácil → bronce, Normal → oro, Reto máximo → diamante) |

El dorado **baja** (hay más estrellas posibles). Hace falta una celebración única de «¡Nuevas medallas!» al abrir la app tras actualizar (como HU-037 P11), para que no se viva como una pérdida.

## 7. Impacto en las demás historias y en el backlog

| Historia | Impacto |
|---|---|
| **HU-037** (rondas, D-038) | El modelo pasa de 3 rondas (`GameDifficulty`) a **8** (`GameRound`). Las reglas R2, R9 y R10 no cambian, solo el número de rondas. Nueva decisión **D-042**, que sustituye a D-038 |
| **HU-048** (medallas) | Se diseña para 8 medallas: metales con estrellas y gemas con forma propia. Hacerla **junto con HU-051**, o antes con el parámetro preparado |
| **HU-049** (niño celebrando) | Sin cambios: la medalla que se pinta en el pecho puede ser cualquiera de las 8 |
| **HU-050** (arrastre en Sombras) | El 90 % queda como el del diamante. Las rondas intermedias tienen solapes intermedios (tabla 3.2) |
| **HU-007** (Sombras) | Su tabla de tiempos (4.3) pasa a 8 series. La regla de Premium cambia (P4) |
| **HU-025** (¿Cuál es diferente?) | Las comparaciones difíciles se reparten (tabla 3.3). La parte gratis cambia (P4) |
| **HU-030 / D-035** | Ya sustituidas por D-038; quedan sustituidas por D-042 |
| **HU-034** (Su progreso) | El detalle de estrellas tiene 8 filas de rondas. La sugerencia de «bajar de ronda» baja un escalón. **Hacer HU-051 antes de su entrega 3** evita rehacer la pantalla |
| **HU-046** (Zona de Padres) | El selector de ronda de cada juego pasa de 3 a 8 opciones: chips con la medalla, en dos filas, o un deslizador (P3) |
| **HU-002** (dorado) | La fórmula no cambia (estrellas / estrellas posibles), pero las posibles se multiplican |
| **HU-006** (Premium) | Qué rondas son Premium en cada juego (P4) |
| **HU-041** (novedades) | La celebración de «¡Nuevas medallas!» tras actualizar encaja aquí |
| **HU-052** (vehículos) | Ya no es la ronda rubí: queda como **temática independiente**, que elige el adulto |
| **Textos** | 8 nombres de medalla y de ronda en 9 idiomas; desaparecen «Fácil», «Normal» y «Reto máximo» como rondas |
| **Backlog** | HU-051 pasa a **P1**, antes de la entrega 3 de HU-034 y junto con HU-048. HU-049 y HU-050 se pueden hacer ya: no dependen de ella |

## 8. Entregas propuestas

1. **Dominio:** `GameRound` de 8 y las tablas de la sección 3 para los tres juegos. Tests de cada serie y de que cada paso cambia algo.
2. **Guardado y migración** (sección 6), con las cajas reales de `1.0.0-rc.4`.
3. **Medallas (HU-048 con 8)** y celebraciones (HU-049), con la celebración única de «¡Nuevas medallas!».
4. **Zona de Padres** (selector de 8 rondas) y textos en 9 idiomas.

## 9. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿8 rondas o más? | ✅ Decidido (2026-11-17): **8** (sección 4) |
| P2 | ¿Se aceptan las tablas de la sección 3 como punto de partida? | ✅ Decidido (2026-11-17): **sí**, con revisión de los tiempos en la prueba cerrada (como HU-007 tabla 4.3) |
| P3 | ¿Cómo elige el adulto la ronda entre 8? | ✅ Decidido (2026-11-17): **chips con la medalla en dos filas** (bronce a oro y rubí a diamante): se ve todo y no hay que deslizar |
| P4 | ¿Qué es Premium con 8 rondas? | ✅ Decidido (2026-11-17). Memoria: **todo gratis** (HU-037 P6). Sombras: **todo gratis salvo el nivel 8** (como hoy). ¿Cuál es diferente?: **bronce a rubí gratis** (4 de 8, el 50 % que se buscaba en HU-025), **esmeralda a diamante Premium**. Mientras dure la prueba, todo gratis (D-040) |
| P5 | ¿Cada ronda sigue empezando por el tutorial? | ✅ Decidido (2026-11-17), distinto de la recomendación: **no**. El tutorial es el **nivel 0, solo al principio del juego**, sin tiempo ni estrellas (R1, R3b) |
| P6 | ¿Se mantiene la celebración con el niño (HU-049) para las 8 medallas? | ✅ Decidido (2026-11-17): **sí** |
| P7 | Sin tutorial en cada ronda, ¿cuándo se baja de ronda? | **Recomendación:** al **perder dos veces en el primer nivel** de la ronda (el equivalente de las dos caídas al tutorial de hoy), y se sigue en el primer nivel de la anterior. La cuenta vuelve a cero al cambiar de ronda (como HU-037 P15) |
| P8 | ¿Qué pasa con quien ya jugó? ¿Vuelve a ver el tutorial? | **No**: el tutorial se da por hecho si ya tiene alguna estrella o medalla en ese juego |
