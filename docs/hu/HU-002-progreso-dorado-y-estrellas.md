# HU-002 · Icono dorado progresivo y estrellas por nivel

| | |
|---|---|
| **Estado** | En refinamiento (reabierta el 2026-10-20 con un alcance nuevo; el desarrollo **no** ha empezado) |
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

### Umbrales propuestos (calibrados)

La referencia para 3★ es lo que logra alguien con **buena memoria** (aproximadamente 1,5 · *m*). Así, las 3★ son exigentes pero alcanzables, y el resto de franjas distingue jugar con poca memoria de jugar al azar.

| Estrellas | Regla | 2×2 | 2×3 | 2×4 | 3×4 | 4×4 |
|---|---|---|---|---|---|---|
| ★★★ | ≤ ⌊1,5 · *m*⌋ + 1 | ≤ 4 | ≤ 5 | ≤ 7 | ≤ 10 | ≤ 13 |
| ★★ | ≤ ⌊2,5 · *m*⌋ | ≤ 5 | ≤ 7 | ≤ 10 | ≤ 15 | ≤ 20 |
| ★ | ≤ 4 · *m* | ≤ 8 | ≤ 12 | ≤ 16 | ≤ 24 | ≤ 32 |
| — | > 4 · *m* | > 8 | > 12 | > 16 | > 24 | > 32 |

**Resultado esperado:** memoria perfecta, 3★ en el 90 % o más de las partidas de todos los tableros; memoria del 50 %, 3★ en los tableros pequeños y 2★ en los grandes; jugar al azar, 0–1★ en los tableros grandes. Los umbrales se guardan en una **tabla por tablero** fácil de ajustar, y conviene revisarlos con los testers de la prueba cerrada de HU-014 (la app no recoge datos, así que la calibración real es con familias).

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

## 6. Conflictos con lo ya decidido

| Decisión | Conflicto | Resolución propuesta |
|---|---|---|
| D-009 | «Siempre 3 estrellas: se celebra el logro, no la eficiencia» | Sustituirla por las estrellas calculadas, conservando su espíritu con R5 (celebración siempre igual) |
| D-023 / HU-001 R9 | El botón se pone dorado **de golpe** al superar el 4×4 | El botón pasa a dorado **progresivo** (R2). La **insignia** de superar el 4×4 se mantiene como logro aparte (P2) |
| README, «sin penalizaciones» | Ver menos estrellas podría sentirse como castigo | R5 |
| HU-001, entrega 2 | `MemoryProgress` guarda nivel e insignia, no estrellas | Guardar ya el **mejor resultado en estrellas de cada nivel** en HU-001 (coste bajo) y evitar una migración de datos después (P4) |

## 7. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Usamos los umbrales calibrados de la sección 4? | Sí: los de la petición hacen el 100 % dorado casi imposible y dejan vacía la franja de 2★ en 2×2 | Sí |
| P2 | ¿Qué pasa con la insignia de superar el 4×4 (HU-001)? | Se mantiene como logro aparte (una medalla junto al botón). El dorado del icono mide las estrellas | Sí |
| P3 | ¿Cómo se ve el dorado? | Opción B (pecas), si el diseño de HU-013 lo permite; si no, A. Decidirlo junto con el diseñador del icono | No (se decide en HU-013) |
| P4 | ¿HU-001 guarda ya las estrellas por nivel, aunque se muestren en HU-002? | Sí: un campo más en `MemoryProgress` evita migrar los datos después | Sí (afecta a HU-001) |
| P5 | Hasta que llegue HU-002, ¿qué muestra el diálogo de victoria de HU-001? | Las estrellas calculadas desde HU-001: la regla es lógica de dominio sencilla y ya sustituye a D-009. HU-002 queda solo con el icono dorado | No (hay recomendación) |
| P6 | ¿Cuenta el nivel 1 (2×2 sin tiempo) para el dorado? | Sí, son 5 niveles × 3 estrellas | No (hay recomendación) |

## 8. Criterios de aceptación (borrador)

1. **Dado** que gano un nivel del juego de memoria, **entonces** recibo 3, 2, 1 o 0 estrellas según la tabla de umbrales de su tablero.
2. **Dado** que vuelvo a ganar un nivel con más estrellas, **entonces** se guarda el nuevo mejor resultado; con menos estrellas, el mejor no cambia.
3. **Dado** que pierdo por tiempo, **entonces** no gano estrellas y el mejor resultado no cambia.
4. **Dado** que tengo 9 de las 15 estrellas posibles, **entonces** el icono del juego está dorado en un 60 %.
5. **Dado** que tengo 3★ en los 5 niveles, **entonces** el icono está dorado al 100 %.
6. **Dado** cualquier número de estrellas, **entonces** la celebración es igual de alegre y no hay mensajes negativos.
7. **Dado** el lector de pantalla, **entonces** el botón del juego anuncia su porcentaje dorado y sus estrellas.
8. **Dado** que cierro y abro la app, **entonces** el dorado y las estrellas se conservan.

## 9. Fuera de alcance

- El diseño del icono de cada juego (HU-013).
- Las estrellas de los juegos 2 y 3: cada uno define su regla al refinarse (HU-007, HU-008).
- Mostrar las estrellas de cada nivel en el menú (posible mejora futura).
