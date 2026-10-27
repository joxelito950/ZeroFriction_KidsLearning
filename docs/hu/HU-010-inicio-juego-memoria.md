# HU-010 · Configurar el punto de partida del juego de memoria

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-27; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | S (1 día) |
| **Depende de** | HU-001 (escalera e insignia) y HU-004 (Zona de Padres), ambas hechas |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** elegir desde qué tablero empieza el juego,
**para** que mi hijo no tenga que empezar o volver siempre al 2×2 sin tiempo si ya domina los primeros niveles.

## 2. Situación actual

- HU-001 R8: tras conseguir la insignia, el juego **vuelve a empezar en el 2×2 sin tiempo**. Elegir otro inicio quedó para esta historia.
- HU-001 R12: solo se guarda el **nivel** actual; al volver a entrar, el límite de tiempo es el de llegada a ese nivel (tabla 4.1: sin tiempo → 90 → 60 → 45 → 30 s). No se guarda el tiempo.
- La Zona de Padres (HU-004) tiene estructura de secciones y queda protegida por el desafío y `AdultSessionGuard`.

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | La Zona de Padres muestra una sección **«Juego de memoria»** con el **punto de partida**: los 5 tableros de la escalera (2×2, 2×3, 2×4, 3×4 y 4×4), con el elegido marcado. Por defecto, el 2×2. |
| R2 | Solo se elige el **tablero**; el tiempo es el de llegada a ese nivel (tabla 4.1 de HU-001). Así se mantiene R12: el límite siempre se deduce del nivel. |
| R3 | La sección está **siempre disponible**, haya o no insignia (P1): los padres de un niño que ya domina los primeros tableros pueden saltárselos desde el principio. |
| R4 | Al elegir un tablero se aplica **en la próxima partida**: el juego empieza en ese nivel con su tiempo de llegada (P3). |
| R5 | Tras conseguir de nuevo la insignia, el juego vuelve al **punto de partida elegido**, no al 2×2 (sustituye a la parte de HU-001 R8 que dice «vuelve a empezar en el 2×2 sin tiempo»). |
| R6 | Las reglas de la escalera no cambian: al perder se baja un nivel aunque quede por debajo del punto de partida, y perder en el 2×2 cronometrado reinicia al 2×2 sin tiempo (HU-001 R5, R6). El punto de partida solo indica dónde se empieza (P4). |
| R7 | Cada tablero se muestra con su dibujo de cartas (una cuadrícula pequeña) y su tiempo, sin texto técnico. El lector de pantalla lee, por ejemplo, «3 por 4, 45 segundos». |
| R8 | Cambiar el punto de partida no afecta a las estrellas, a la insignia ni a la fecha de la última partida. |

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| HU-001 R8 | Se matiza: el reinicio tras la insignia va al punto de partida (R5). Requiere una nota en la ficha de HU-001 y, si se aprueba, una decisión nueva en la sección 8 de la especificación |
| HU-001 R12 | Se mantiene (R2) |
| D-031 (pérdida de logros) y HU-002 | Sin impacto: las estrellas siguen por nivel |
| HU-004 R7 | Elegir un tablero cuenta como actividad para el minuto de inactividad (lo hace ya `AdultSessionGuard`) |

## 5. Criterios de aceptación (borrador)

1. **Dado** un juego con o sin insignia, **cuando** entro en la Zona de Padres, **entonces** veo la sección «Juego de memoria» con los 5 tableros y el punto de partida actual marcado (2×2 si nunca se cambió).
2. **Dado** un juego que nunca se ha jugado, **cuando** elijo el 2×4, **entonces** la primera partida es en el 2×4 con 60 s.
3. **Dado** que elijo el 3×4, **cuando** vuelvo al menú y abro el juego, **entonces** empieza en el 3×4 con 45 s.
4. **Dado** que el punto de partida es el 3×4, **cuando** consigo de nuevo la insignia, **entonces** el siguiente tablero es el 3×4 con 45 s.
5. **Dado** que el punto de partida es el 3×4, **cuando** pierdo en el 3×4, **entonces** bajo al 2×4 con el mismo límite (HU-001 R5).
6. **Dado** que cambio el punto de partida, **entonces** las estrellas, la insignia y la fecha de la última partida no cambian.
7. **Dado** los datos guardados antes de esta historia, **cuando** se actualiza la app, **entonces** el punto de partida es el 2×2 y el progreso se conserva.
8. **Dado** los 9 idiomas, **entonces** la sección no se desborda en vertical ni en horizontal y el lector de pantalla lee cada tablero.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `MemoryProgress.startLevel` (1 por defecto) y `withStartLevel`; `MemoryLadder` usa el punto de partida al ganar el último nivel en lugar del 2×2 (R5) |
| Persistencia | `MemoryProgressHiveModel`: campo nuevo **índice 5** `startLevel` (opcional; los datos anteriores lo leen como `null` → 1). Sin typeId nuevo. Actualizar la sección 3.4 de la especificación |
| Presentación | Sección «Juego de memoria» en `ParentsZoneScreen`, siempre visible, que lee y guarda el progreso |
| Catálogo | 3–4 claves nuevas en los 9 idiomas (título de la sección, explicación, etiqueta de cada tablero para el lector de pantalla) |
| Tests | Dominio (reinicio tras la insignia al punto de partida, pérdidas sin cambios), compatibilidad con los datos anteriores (fixtures de `test/fixtures/`), widget de la sección y layout en los 9 idiomas |

## 7. Ejemplo

Punto de partida 3×4. Partida: 3×4 con 45 s → gana → 4×4 con 30 s → gana (insignia ya conseguida) → **3×4 con 45 s**. Si en el 3×4 se le acaba el tiempo → 2×4 con 45 s.

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Se puede configurar sin haber conseguido la insignia? | ✅ Decidido (2026-10-27): **sí, siempre disponible** (cambia la nota del backlog, que lo limitaba a después de la insignia) | — |
| P2 | ¿Se elige también el tiempo, por separado del tablero? | ✅ Asumida la recomendación: **no**: solo el tablero, con su tiempo de llegada (R2). Elegir el tiempo aparte rompería HU-001 R12 y obligaría a guardar el tiempo | — |
| P3 | ¿El cambio se aplica ya o solo tras la próxima insignia? | ✅ Asumida la recomendación: **ya, en la próxima partida** (R4): es lo que espera un adulto que lo cambia | — |
| P4 | ¿Se puede bajar por debajo del punto de partida al perder? | ✅ Asumida la recomendación: **sí**, la escalera no cambia (R6): así un niño que no lo consigue no se queda atascado en un tablero difícil | — |
| P5 | ¿El ajuste es por juego o general? | ✅ Asumida la recomendación: **por juego** (se guarda en `MemoryProgress`); cada juego futuro tendrá el suyo si lo necesita | — |

## 9. Fuera de alcance

- Configurar el tiempo por separado (P2).
- Tableros distintos de los 5 de la escalera.
- Configurar las temáticas del juego.
- Ajustes de otros juegos (HU-007, HU-008).
