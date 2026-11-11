# HU-002 · Icono dorado progresivo y estrellas por nivel

| | |
|---|---|
| **Estado** | Hecha (vista en el moto g55 el 2026-11-09 y publicada en `1.0.0-rc.2`). Antes: en curso (desarrollada el 2026-11-06 en `feature/hu-002-016-gold-stars`, con HU-016; falta verla en el moto g55). Refinamiento cerrado el 2026-10-21 y revisado el 2026-11-05 |
| **Épica** | E1 · Juego de memoria (la regla del dorado aplica también a los juegos futuros) |
| **Prioridad** | P3 |
| **Tamaño** | M, al límite (unos 4 días): dominio de la pérdida, el dorado líquido animado y la etiqueta en 9 idiomas. HU-016 (S) va en el mismo PR |
| **Depende de** | HU-001 (hecha) y HU-013 (icono del juego, en curso). Se desarrolla junto con HU-016 (P12) |

## 1. Historia

**Como** niño o niña que juega,
**quiero** ver cómo el icono de mi juego se va volviendo dorado a medida que gano estrellas,
**para** saber cuánto he avanzado y tener ganas de mejorar.

## 2. Petición original

> El icono del juego va tomando tono dorado en un porcentaje según los niveles alcanzados; el 100 % de los niveles sería el dorado completo y el 50 % de los niveles, un 50 % de dorado. Puede ir en degradado o en parches o pecas doradas que lo van cubriendo. Las 3 estrellas, que hoy siempre salen llenas, se pueden calcular según cada juego. En el juego de memoria: 3 estrellas si lo logra en el mínimo de movimientos + 2; 2 estrellas entre el mínimo + 2 y el doble del mínimo; 1 estrella entre el doble y el triple del mínimo; sin estrellas si supera el triple. Para llegar al 100 % dorado hay que tener el 100 % de los niveles con 3 estrellas.

## 3. Situación actual (revisada el 2026-11-05)

- **Ya hecho en HU-001:** las estrellas se calculan con D-030 y se ven en la celebración; `MemoryProgress` guarda el mejor resultado y su fecha por nivel y la fecha de la última partida (P4, P5). La insignia del 4×4 y su medalla en el menú también están.
- **Ya hecho en HU-013** (rama `feature/hu-013-identity`): el icono del juego de memoria (dos cartas) está en el botón del menú y en la cabecera, con el widget `GameIcon`, que **ya acepta el porcentaje dorado** (`goldFraction`, llenado de abajo arriba con `ShaderMask`).
- **Ya hecho en HU-009:** `ParentalSettings` (typeId 3), donde HU-016 guardará «Mantener las estrellas».
- **Falta en esta historia:** el cálculo del dorado y de la pérdida (dominio con reloj inyectado), guardar las estrellas perdidas, pasar el porcentaje al icono, la etiqueta del lector de pantalla (R6, 9 idiomas) y el aspecto final del dorado sobre la ilustración (P10).
- **HU-030** (lista) añade una vista previa de 1 s en Fácil y Normal: hace más fáciles las 3★ que la simulación de la sección 4, que no la tenía. Se acepta: la dificultad no cambia los premios (HU-030 P4).

## 4. Análisis de las estrellas (simulación)

El **mínimo de movimientos** es el número de parejas (*m*): acertar todas a la primera. Se simularon miles de partidas en los 5 tableros con tres tipos de jugador: **memoria perfecta** (nunca olvida una carta vista; es el mejor caso realista), **memoria del 50 %** y **al azar** (como un niño muy pequeño).

### Movimientos reales por tipo de jugador

| Tablero | *m* | Memoria perfecta (mediana / percentil 90) | Memoria 50 % (mediana / p90) | Al azar (mediana / p90) |
|---|---|---|---|---|
| 2×2 | 2 | 3 / 3 | 3 / 4 | 3 / 7 |
| 2×3 | 3 | 4 / 5 | 5 / 6 | 8 / 15 |
| 2×4 | 4 | 6 / 7 | 7 / 9 | 14 / 27 |
| 3×4 | 6 | 9 / 10 | 11 / 14 | 33 / 57 |
| 4×4 | 8 | 12 / 13 | 16 / 18 | 60 / 97 |

### Con los umbrales de la petición

| Tablero | 3★ si ≤ *m* + 2 | ¿Cuántas partidas con memoria perfecta logran 3★? |
|---|---|---|
| 2×2 | ≤ 4 | 100 % |
| 2×3 | ≤ 5 | 100 % |
| 2×4 | ≤ 6 | 86 % |
| 3×4 | ≤ 8 | 14 % |
| 4×4 | ≤ 10 | **0,4 %** (pura suerte) |

**Problemas:**
1. Las 3★ en 3×4 y 4×4 dependen de la suerte **incluso con memoria perfecta**. El 100 % dorado (3★ en todos los niveles) sería prácticamente inalcanzable para cualquiera, adulto o niño.
2. En 2×2, la franja de 2★ está vacía: *m* + 2 y 2 · *m* valen lo mismo (4).

### Regla por nivel (propuesta del product owner, 2026-10-20) ✅ recomendada

**3★ si los movimientos son ≤ mínimo + número de nivel.** El nivel 1 se vuelve más exigente (*m* + 1), el nivel 2 se queda como estaba (*m* + 2) y la holgura crece en los niveles altos. Para 2★ y 1★ se mantienen las franjas de la petición: hasta el doble y hasta el triple del mínimo.

| Nivel | Tablero | *m* | ★★★ (≤ *m* + nivel) | ★★ (≤ 2 · *m*) | ★ (≤ 3 · *m*) | — |
|---|---|---|---|---|---|---|
| 1 | 2×2 | 2 | ≤ 3 | 4 | 5–6 | > 6 |
| 2 | 2×3 | 3 | ≤ 5 | 6 | 7–9 | > 9 |
| 3 | 2×4 | 4 | ≤ 7 | 8 | 9–12 | > 12 |
| 4 | 3×4 | 6 | ≤ 10 | 11–12 | 13–18 | > 18 |
| 5 | 4×4 | 8 | ≤ 13 | 14–16 | 17–24 | > 24 |

**Probabilidad de 3★ en un intento** (simulación de 8 000 partidas por caso) y número medio de intentos para lograrlas:

| Nivel | Memoria perfecta | Memoria del 50 % | Al azar |
|---|---|---|---|
| 1 · 2×2 | 100 % (1 intento) | 78 % (~1,3) | 57 % (~1,8) |
| 2 · 2×3 | 100 % (1) | 70 % (~1,4) | 27 % (~3,7) |
| 3 · 2×4 | 100 % (1) | 62 % (~1,6) | 11 % (~9) |
| 4 · 3×4 | 99,5 % (1) | 29 % (~3,4) | 0,7 % (~150) |
| 5 · 4×4 | 96 % (1) | 11 % (~9,4) | ≈ 0 % |

**Conclusión:** con esta regla el 100 % dorado es **exigente pero alcanzable**. Un niño con media memoria necesita repetir el 4×4 unas 9 veces de media, y nadie lo consigue tocando al azar. Además, la franja de 2★ existe en todos los niveles. La regla coincide casi exactamente con la calibración por simulación (solo el nivel 1 es un movimiento más exigente). Los umbrales viven en una **tabla por nivel**, fácil de ajustar tras la prueba cerrada con familias (HU-014), porque la app no recoge datos de uso.

## 5. Regla del dorado (propuesta)

| # | Regla |
|---|---|
| R1 | Cada nivel guarda su **mejor resultado en estrellas** (0–3). Perder por tiempo no da estrellas ni empeora el mejor resultado |
| R2 | **Porcentaje dorado del juego** = estrellas acumuladas (la mejor de cada nivel) ÷ estrellas posibles (niveles × 3). En el juego de memoria: 5 niveles × 3 = **15 estrellas**; cada estrella suma un 6,7 % |
| R3 | **100 % dorado** = las 15 estrellas, es decir, 3★ en todos los niveles (la condición de la petición) |
| R4 | La regla es **igual para todos los juegos**: cada juego futuro define sus niveles y su forma de calcular estrellas, y el porcentaje dorado se calcula igual (D-023 generalizada) |
| R5 | **Las estrellas nunca son un castigo:** la celebración es igual de alegre con 0 que con 3 estrellas. Las que faltan se ven como contorno suave, sin mensajes de «podrías hacerlo mejor» |
| R6 | Accesibilidad: el botón del juego se lee, por ejemplo, «Memoria, 60 % dorado, 9 de 15 estrellas» |

### Cómo se ve el dorado en el icono (P3)

| Opción | Cómo se ve | Ventaja | Inconveniente |
|---|---|---|---|
| **A. Llenado de abajo arriba** | El dorado sube por el icono como un líquido, con un brillo en el borde | El porcentaje se entiende a simple vista | Más sobrio |
| **B. Pecas o parches dorados** | Manchas doradas en posiciones fijas que van apareciendo hasta cubrirlo | Más divertido y «coleccionable» | El porcentaje se percibe con menos precisión |
| C. Degradado de color | El icono pasa poco a poco del color original al dorado | Sutil | A partir de cierto punto apenas se distinguen las diferencias |

Las tres son viables en Flutter: un `ShaderMask` para A y C, y un `CustomPainter` con posiciones fijas por juego para B, para que las pecas no «salten» entre aperturas. El acabado final depende del diseño del icono de HU-013.

## 6. Pérdida gradual de logros si no se juega (análisis)

**Petición:** si el niño deja de jugar una semana, va perdiendo los logros más antiguos, poco a poco, hasta que el icono vuelve a no tener dorado, salvo que los renueve jugando.

### A favor y en contra

| A favor | En contra |
|---|---|
| Invita a volver a practicar: la memoria se entrena con constancia | Es una mecánica de **aversión a la pérdida**, como las «rachas». El borrador del Código de diseño infantil del Reino Unido (ICO) citaba las rachas como técnica que no debe usarse con niños; la versión final se limita a la privacidad, pero la tendencia regulatoria va en esa dirección |
| Da sentido a repetir niveles ya superados | Choca con los principios del README («paz mental», «sin penalizaciones»), y el programa *Teacher Approved* de Google Play valora el desarrollo saludable |
| | Un niño de 3 años no entiende por qué «pierde» su dorado tras unas vacaciones o una enfermedad: lo vive como un castigo sin causa |
| | Depende del reloj del teléfono, que se puede cambiar |

### Opciones

| Opción | Qué pasa tras 7 días sin jugar | Valoración |
|---|---|---|
| **D1. Pérdida real** (la petición) | Cada pocos días el logro más antiguo pierde una estrella; para recuperarla hay que volver a ganar ese nivel con las mismas estrellas | ⚠️ Viable técnicamente, pero con los riesgos de la tabla anterior |
| **D2. Brillo que se apaga** | El dorado se va **apagando** (más mate y menos brillante) poco a poco, pero **no se pierde ninguna estrella**. Con la primera partida, el brillo vuelve entero al momento | ✅ **Recomendada:** mantiene la invitación a volver sin castigar |
| D3. Opción para los padres | D1 o D2 solo si un adulto lo activa en la Zona de Padres (desactivado por defecto) | Posible mejora futura; depende de HU-004 |

### Decisión (2026-10-21): pérdida real (D1)

El product owner elige **D1**, como control de progreso y refuerzo de las habilidades (D-031). Para que no se viva como un castigo:

| # | Regla |
|---|---|
| R7 | **Periodo de gracia:** mientras se juegue al juego al menos una vez cada **7 días**, no se pierde nada. Cuenta como jugar ganar o perder cualquier nivel |
| R8 | **Pérdida:** pasados los 7 días sin jugar, se pierde **una estrella cada 3 días**, empezando por el **logro más antiguo** (el nivel cuyo mejor resultado se consiguió hace más tiempo). Desde el 100 % dorado (15★), se llega a 0 en unos 52 días |
| R9 | **Recuperación:** volver a jugar detiene la pérdida en ese momento. Las estrellas perdidas se recuperan **ganando de nuevo** ese nivel; el resultado nuevo cuenta como mejor resultado con su fecha |
| R10 | **La insignia de superar el 4×4 no se pierde nunca** (HU-001, R8) |
| R11 | **Sin mensajes negativos:** la pérdida es silenciosa; el icono simplemente tiene menos dorado. No hay avisos de «vas a perder» ni contadores de días |
| R12 | Se calcula con el **reloj del teléfono**, inyectado en la lógica de dominio para poder probarlo. Si alguien adelanta o atrasa el reloj, solo afecta a ese teléfono; se acepta |
| R13 | **La pérdida se aplica al empezar el juego, nunca en el menú** (P8, decidido el 2026-11-05): al abrir el juego se calcula la pérdida acumulada con el reloj, se guardan las estrellas que quedan (sin cambiar sus fechas) y después la partida actualiza la fecha de la última partida, lo que detiene la pérdida (R9). El menú solo **lee** lo guardado, sin cálculos: así no se ralentiza en teléfonos de gama baja cuando haya muchos juegos. Consecuencia aceptada: tras muchos días sin jugar, el menú muestra el dorado guardado hasta que se abre el juego; al volver al menú ya se ve el nuevo. Es la regla para **todos los juegos** (D-037) |
| R14 | **Qué nivel pierde primero** (P9): el del logro más antiguo que aún tenga estrellas. Su fecha no cambia al perder, así que se vacía entero antes de pasar al siguiente |
| R15 | **Dorado líquido** (P10, decidido el 2026-11-05): el dorado sube como un **líquido**, no como una imagen dorada con transparencia fija que se llena en línea recta. La superficie es una **ola suave** que se mece despacio; el líquido tiene volumen (dorado `#A86B12` en el fondo y ámbar `#ECA463` en las luces y en la superficie) y deja ver la forma del icono debajo; **burbujas doradas pequeñas** suben lentamente dentro del líquido. Al 0 % no hay líquido; al 100 % el icono está lleno y la ola sigue meciéndose. Movimiento lento y tranquilo: nada parpadea ni llama la atención de golpe |
| R16 | **Dónde** (P11): en el menú, el líquido llena **todo el botón del juego** de abajo arriba (para un niño, el botón es «el juego»); el icono del juego va dentro. En la cabecera del juego, solo el icono, con el mismo porcentaje. El texto del botón sigue siendo legible con cualquier nivel: blanco sobre azul petróleo (6,16:1) o sobre dorado (4,40:1, por debajo de 4,5:1), así que **lleva una sombra suave en teal profundo** cuando el líquido lo alcanza (P13) **Cambio del 2026-11-09:** el dorado va **solo en el botón del menú**; el icono de la cabecera se queda sin dorado (sobre la carta azul petróleo daba un tono verde oliva). `GameIcon` conserva la opción por si un juego futuro la usa. |
| R17 | **Rendimiento y accesibilidad:** una sola animación por botón, que se detiene cuando la pantalla no está a la vista (otra pantalla encima, app en segundo plano). Con «reducir movimiento» del sistema, el líquido se queda quieto, sin ola ni burbujas. El dorado es decorativo para el lector de pantalla: el porcentaje lo anuncia el botón (R6) |

Riesgo aceptado: va contra la idea de «sin penalizaciones» del README y se parece a las «rachas» que el borrador del código infantil del ICO desaconsejaba. Los padres podrán activarla o desactivarla desde la Zona de Padres en **HU-016** (opción D3).

### Datos necesarios

Para cualquiera de las tres opciones, cada nivel guarda, además de su mejor resultado en estrellas, la **fecha en que lo logró**, y el juego guarda la **fecha de la última partida**. El cálculo del dorado efectivo es **lógica pura de dominio** con el reloj inyectado: se puede probar «dentro de 10 días» sin esperar.

## 7. Conflictos con lo ya decidido

| Decisión | Conflicto | Resolución propuesta |
|---|---|---|
| D-009 | «Siempre 3 estrellas: se celebra el logro, no la eficiencia» | Sustituirla por las estrellas calculadas, conservando su espíritu con R5 (celebración siempre igual) |
| D-023 / HU-001 R9 | El botón se pone dorado **de golpe** al superar el 4×4 | El botón pasa a dorado **progresivo** (R2). La **insignia** de superar el 4×4 se mantiene como logro aparte (P2) |
| README, «sin penalizaciones» | Ver menos estrellas podría sentirse como castigo | R5 |
| HU-001, entrega 2 | `MemoryProgress` guarda nivel e insignia, no estrellas | Guardar ya el **mejor resultado en estrellas de cada nivel** en HU-001 (coste bajo) y evitar una migración de datos después (P4) |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Qué regla de estrellas usamos? | ✅ Decidido: 3★ si ≤ mínimo + número de nivel; 2★ hasta el doble y 1★ hasta el triple del mínimo (D-030) | — |
| P2 | ¿Qué pasa con la insignia de superar el 4×4 (HU-001)? | ✅ Decidido: se mantiene como logro aparte, una medalla junto al botón del juego. El dorado mide las estrellas | — |
| P3 | ¿Cómo se ve el dorado? | ✅ Decidido el 2026-10-26 (HU-013, P5): **opción A, llenado de abajo arriba**, con un `ShaderMask` sobre la silueta del icono del juego. El color del llenado es el **dorado de la paleta** `#A86B12` (D-032, `AppPalette.gold`); el brillo del borde, ámbar `#ECA463` | — |
| P4 | ¿HU-001 guarda ya las estrellas por nivel? | ✅ Decidido: sí. Mejor resultado y fecha de cada nivel, y fecha de la última partida del juego, en `MemoryProgress` | — |
| P5 | Hasta que llegue HU-002, ¿qué muestra el diálogo de victoria de HU-001? | ✅ Asumida la recomendación: las estrellas calculadas desde HU-001. HU-002 queda con el icono dorado y la pérdida de logros | — |
| P6 | ¿Cuenta el nivel 1 (2×2 sin tiempo) para el dorado? | ✅ Decidido: sí, son 5 niveles × 3 estrellas | — |
| P7 | ¿Se pierden los logros si no se juega? | ✅ Decidido: **sí, pérdida real (D1)**, como control de progreso y refuerzo de las habilidades (D-031). Parámetros asumidos en la sección 6 | — |
| P8 | ¿La pérdida se calcula al vuelo o se guarda? | ✅ Decidido (2026-11-05): **se calcula al empezar el juego y se guarda**; nunca en el menú, para no gastar procesamiento ni ralentizar teléfonos de gama baja cuando haya muchos juegos. Regla para todos los juegos futuros (R13, D-037) | — |
| P9 | ¿Qué nivel pierde primero? | ✅ Decidido (2026-11-05): **el logro más antiguo** (R14) | — |
| P10 | ¿Cómo se ve el dorado sobre la ilustración 3D de las cartas? | ✅ Decidido (2026-11-05): **dorado líquido** con ola suave y **burbujas doradas** que suben despacio, no una capa dorada fija que se llena en línea recta (R15). Se ajusta viéndolo en el moto g55 | — |
| P11 | ¿Dónde se ve el dorado? | ✅ Decidido (2026-11-05): principalmente el icono del juego; en el menú puede llenar **todo el botón del juego** (R16). En la cabecera del juego, solo el icono | — |
| P12 | ¿Se desarrolla junto con HU-016? ¿Es Premium? | ✅ Decidido (2026-11-05): **juntas**, y «Mantener las estrellas» es **gratuito**: protege al niño y no es contenido de pago | — |
| P13 | El texto blanco del botón sobre el dorado queda en 4,40:1, justo por debajo del 4,5:1 de la paleta para texto pequeño (el subtítulo) | Recomendación: **sombra suave en teal profundo** bajo el texto del botón, solo donde lo cubre el líquido; se comprueba en el moto g55 a 60 % y 100 % | No |

## 9. Criterios de aceptación (borrador)

1. **Dado** que gano el nivel *N* del juego de memoria, **entonces** recibo 3★ si usé como mucho mínimo + *N* movimientos, 2★ hasta el doble del mínimo, 1★ hasta el triple y ninguna si lo supero.
2. **Dado** que vuelvo a ganar un nivel con más estrellas, **entonces** se guarda el nuevo mejor resultado; con menos estrellas, el mejor no cambia.
3. **Dado** que pierdo por tiempo, **entonces** no gano estrellas y el mejor resultado no cambia.
4. **Dado** que tengo 9 de las 15 estrellas posibles, **entonces** el icono del juego está dorado en un 60 %.
5. **Dado** que tengo 3★ en los 5 niveles, **entonces** el icono está dorado al 100 %.
6. **Dado** cualquier número de estrellas, **entonces** la celebración es igual de alegre y no hay mensajes negativos.
7. **Dado** el lector de pantalla, **entonces** el botón del juego anuncia su porcentaje dorado y sus estrellas.
8. **Dado** que cierro y abro la app, **entonces** el dorado y las estrellas se conservan.
9. **Dado** que no juego durante más de 7 días, **entonces** pierdo una estrella cada 3 días, empezando por la más antigua, y el icono pierde dorado en proporción, sin mensajes negativos.
10. **Dado** que vuelvo a jugar, **entonces** la pérdida se detiene; **cuando** gano de nuevo un nivel, **entonces** recupero sus estrellas según el resultado.
11. **Dado** que tenía la insignia del 4×4, **entonces** la conservo aunque pierda estrellas.
12. **Dado** que llevo 20 días sin jugar, **cuando** abro el menú, **entonces** veo el dorado guardado; **cuando** abro el juego, **entonces** se aplican y se guardan las estrellas perdidas y, al volver al menú, el botón muestra el dorado nuevo.
13. **Dado** que pierdo estrellas, **entonces** las pierde primero el nivel con el logro más antiguo, hasta quedarse sin ninguna.
14. **Dado** un porcentaje dorado entre 1 y 99 %, **entonces** el botón del juego en el menú se llena hasta esa altura con un líquido dorado cuya superficie se mece y con burbujas que suben despacio; al 0 %, sin líquido.
15. **Dado** «reducir movimiento», **entonces** el líquido se ve a su altura, sin ola ni burbujas.
16. **Dado** otra pantalla encima del menú, o la app en segundo plano, **entonces** la animación del líquido se detiene.
17. **Dado** el botón con el líquido a cualquier altura, **entonces** su título y su subtítulo se leen bien (sombra suave, P13), en los 9 idiomas y en vertical y horizontal.

## 10. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `GoldProgress` (Dart puro, reloj inyectado): porcentaje dorado a partir de los mejores resultados (R2) y `applyDecay(progress, now)` que devuelve el progreso con las estrellas perdidas (R7, R8, R13, R14). Sirve para los juegos futuros |
| Estado | `MemoryLadderCubit.start()` aplica la pérdida y la guarda antes de repartir el primer tablero (R13). Respeta «Mantener las estrellas» de HU-016 |
| Presentación | `LiquidGoldFill` (`CustomPainter` con un solo `AnimationController`): ola, tonos de volumen y burbujas; `TickerMode` y `MediaQuery.disableAnimations` para R17. El botón «Memoria» del menú lo lleva de fondo; `GameIcon` lo usa en la cabecera |
| Persistencia | Ninguna nueva: ya se guardan los mejores resultados, sus fechas y la última partida (HU-001) |
| Catálogo | Etiqueta del botón para el lector de pantalla (R6) en los 9 idiomas |
| Tests | Dominio con reloj (gracia de 7 días, una estrella cada 3, orden por antigüedad, insignia intacta, días de más), cubit (pérdida al empezar, no en el menú), widget del líquido (altura, sin animación con «reducir movimiento», se detiene con otra pantalla encima), layout del menú con el líquido en 9 idiomas |

## 11. Fuera de alcance

- El diseño del icono de cada juego (HU-013).
- Las estrellas de los juegos 2 y 3: cada uno define su regla al refinarse (HU-007, HU-008).
- Mostrar las estrellas de cada nivel en el menú (posible mejora futura).

## 12. Desarrollo

Rama `feature/hu-002-016-gold-stars`, 2026-11-06, junto con HU-016.

| Área | Qué se hizo |
|---|---|
| Dominio | `StarDecay` (`domain/progress/`, para todos los juegos): 7 días de gracia y una estrella cada 3 días; la fecha de partida es la más reciente entre la última partida y la reactivación de HU-016. `MemoryProgress`: estrellas, `goldFraction` (sobre 15), `loseStars` (vacía primero el logro más antiguo, sin tocar fechas ni insignia) y `playedAt` |
| Estado | `MemoryLadderCubit.start` aplica la pérdida y la guarda al abrir el juego (D-037), salvo con «Mantener las estrellas»; si el progreso no se pudo leer, no guarda nada. El estado lleva el dorado para la cabecera |
| Presentación | `LiquidGold`: ola suave, tonos de volumen (ámbar arriba, dorado abajo), brillo en la superficie y 6 burbujas que suben despacio; una sola animación de 6 s que no corre al 0 %, con «reducir movimiento» ni con la pantalla tapada. En el menú llena todo el botón «Memoria», con sombra en el texto; en la cabecera del juego, solo el icono y quieto. El botón anuncia «60 % dorado, 9 de 15 estrellas» (R6) |
| Catálogo | 3 claves en los 9 idiomas (la etiqueta del botón y el interruptor de HU-016) |

**Decisión de desarrollo:** abrir el juego cuenta como jugar (R13): al empezar se aplica la pérdida y se guarda la fecha de la partida. Así la pérdida no se cuenta dos veces si el niño abre el juego y sale sin terminar un tablero.

**Visto en el moto g55 (2026-11-06):** el botón «Memoria» se llena con el líquido, la ola y las burbujas se mueven (entre dos capturas solo cambia el botón) y el texto se lee bien con la sombra. En la cabecera, el dorado salía como un rectángulo sobre todo el icono: el motor gráfico del teléfono (Impeller) no respeta `srcATop`. Corregido: el líquido ocupa el cuadro y la transparencia del propio icono lo recorta (`ShaderMask` con `dstIn`), más translúcido para que se vea la ilustración.

Decidido el 2026-11-09: el dorado va solo en el botón del menú (R16). Pendiente: ver el interruptor «Mantener las estrellas» en el teléfono.
