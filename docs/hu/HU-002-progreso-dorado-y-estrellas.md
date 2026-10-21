# HU-002 · Icono dorado progresivo y estrellas por nivel

| | |
|---|---|
| **Estado** | En refinamiento (reabierta el 2026-10-20; regla por nivel y análisis de pérdida de logros añadidos el mismo día; el desarrollo **no** ha empezado) |
| **Épica** | E1 · Juego de memoria (la regla del dorado aplica también a los juegos futuros) |
| **Prioridad** | P3 |
| **Tamaño** | M (3–4 días), por confirmar |
| **Depende de** | HU-001 (niveles del juego de memoria) y HU-013 (icono de cada juego). Se desarrolla junto con HU-013 o después |

## 1. Historia

**Como** niño o niña que juega,
**quiero** ver cómo el icono de mi juego se va volviendo dorado a medida que gano estrellas,
**para** saber cuánto he avanzado y tener ganas de mejorar.

## 2. Petición original

> El icono del juego va tomando tono dorado en un porcentaje según los niveles alcanzados; el 100 % de los niveles sería el dorado completo y el 50 % de los niveles, un 50 % de dorado. Puede ir en degradado o en parches o pecas doradas que lo van cubriendo. Las 3 estrellas, que hoy siempre salen llenas, se pueden calcular según cada juego. En el juego de memoria: 3 estrellas si lo logra en el mínimo de movimientos + 2; 2 estrellas entre el mínimo + 2 y el doble del mínimo; 1 estrella entre el doble y el triple del mínimo; sin estrellas si supera el triple. Para llegar al 100 % dorado hay que tener el 100 % de los niveles con 3 estrellas.

## 3. Situación actual

- El diálogo de victoria muestra **siempre 3 estrellas** (D-009: «a los 3 años se celebra el logro, no la eficiencia»).
- HU-001 (lista, sin implementar) define 5 niveles (2×2 → 4×4) y que el botón del juego quede **dorado de golpe** al superar el 4×4 (D-023).
- Los iconos de los juegos se retiraron (TD-006) hasta definir la identidad visual (HU-013).

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
| P1 | ¿Qué regla de estrellas usamos? | ✅ Propuesta del product owner: 3★ si ≤ mínimo + número de nivel; 2★ hasta el doble y 1★ hasta el triple del mínimo. La simulación la respalda (sección 4). Confirmar | Sí |
| P2 | ¿Qué pasa con la insignia de superar el 4×4 (HU-001)? | Se mantiene como logro aparte (una medalla junto al botón). El dorado del icono mide las estrellas | Sí |
| P3 | ¿Cómo se ve el dorado? | Opción B (pecas), si el diseño de HU-013 lo permite; si no, A. Decidirlo junto con el diseñador del icono | No (se decide en HU-013) |
| P4 | ¿HU-001 guarda ya las estrellas por nivel, aunque se muestren en HU-002? | Sí: el mejor resultado de cada nivel **y su fecha**, más la fecha de la última partida. Un campo más en `MemoryProgress` evita migrar los datos después | Sí (afecta a HU-001) |
| P5 | Hasta que llegue HU-002, ¿qué muestra el diálogo de victoria de HU-001? | Las estrellas calculadas desde HU-001: la regla es lógica de dominio sencilla y ya sustituye a D-009. HU-002 queda solo con el icono dorado | No (hay recomendación) |
| P6 | ¿Cuenta el nivel 1 (2×2 sin tiempo) para el dorado? | Sí, son 5 niveles × 3 estrellas | No (hay recomendación) |
| P7 | ¿Se pierden los logros si no se juega? | **D2: el brillo se apaga, pero no se pierde ninguna estrella** (sección 6). Si prefieres D1, propongo 7 días de gracia y una estrella menos cada 3 días, empezando por el logro más antiguo (el 100 % dorado se perdería del todo en unos 50 días) | Sí |

## 9. Criterios de aceptación (borrador)

1. **Dado** que gano el nivel *N* del juego de memoria, **entonces** recibo 3★ si usé como mucho mínimo + *N* movimientos, 2★ hasta el doble del mínimo, 1★ hasta el triple y ninguna si lo supero.
2. **Dado** que vuelvo a ganar un nivel con más estrellas, **entonces** se guarda el nuevo mejor resultado; con menos estrellas, el mejor no cambia.
3. **Dado** que pierdo por tiempo, **entonces** no gano estrellas y el mejor resultado no cambia.
4. **Dado** que tengo 9 de las 15 estrellas posibles, **entonces** el icono del juego está dorado en un 60 %.
5. **Dado** que tengo 3★ en los 5 niveles, **entonces** el icono está dorado al 100 %.
6. **Dado** cualquier número de estrellas, **entonces** la celebración es igual de alegre y no hay mensajes negativos.
7. **Dado** el lector de pantalla, **entonces** el botón del juego anuncia su porcentaje dorado y sus estrellas.
8. **Dado** que cierro y abro la app, **entonces** el dorado y las estrellas se conservan.
9. **Dado** que no juego durante más de 7 días, **entonces** el dorado se apaga poco a poco según la opción elegida en P7; **cuando** vuelvo a jugar, **entonces** recupero el brillo (D2) o puedo recuperar las estrellas ganando de nuevo los niveles (D1).

## 10. Fuera de alcance

- El diseño del icono de cada juego (HU-013).
- Las estrellas de los juegos 2 y 3: cada uno define su regla al refinarse (HU-007, HU-008).
- Mostrar las estrellas de cada nivel en el menú (posible mejora futura).
