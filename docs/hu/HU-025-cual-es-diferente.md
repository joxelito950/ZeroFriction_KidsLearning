# HU-025 · Juego: ¿Cuál es diferente?

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-09; preguntas en la sección 8) |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: candidato a tercer juego, el más barato de hacer después de Sombras |
| **Tamaño** | M (estimación: 3–4 días) |
| **Depende de** | HU-023 (menú para varios juegos), que hace falta antes del tercer juego. Reutiliza la escalera, las estrellas, el dorado, la dificultad, el tutorial y la celebración de la memoria |

## 1. Historia

**Como** niño de 2 a 5 años,
**quiero** encontrar el objeto que no pertenece al grupo,
**para** aprender a agrupar las cosas por lo que tienen en común.

## 2. Por qué este juego ahora

- **Un solo toque**, como la memoria: se entiende mirando (D-034) y la mano de HU-022 lo enseña sin cambios.
- **Solo emojis** de las temáticas que ya existen (D-024, D-026): no necesita ilustraciones.
- Desarrolla la **categorización**, una habilidad distinta de la memoria (HU-001) y de la forma (HU-007).
- Reutiliza casi todo: escalera con tiempo opcional (HU-001, HU-030), estrellas por fallos (como HU-007 R9), dorado (HU-002), pérdida de logros (D-031), celebración, salida protegida y tiempo diario (HU-009).

## 3. Cómo se juega

- En pantalla, **4 a 6 objetos grandes**: todos de un grupo menos uno.
- El niño **toca el diferente**. Si acierta, el objeto da un saltito de alegría y llega el siguiente tablero. Si falla, el objeto tocado se mueve un poco «no» (sin rojo ni sonido de error) y puede seguir intentándolo.
- Al completar unos tableros (P3), el nivel se supera con la celebración de siempre.

## 4. Escalera propuesta (P2)

| Nivel | Objetos | Qué los hace diferentes | Ejemplo |
|---|---|---|---|
| 1 | 3 | Grupos muy distintos | 🐶 🐱 🚗 |
| 2 | 4 | Grupos muy distintos | 🍎 🍌 🍐 ⚽ |
| 3 | 4 | Grupos cercanos | 🐶 🐮 🐷 🦁 (granja frente a salvaje) |
| 4 | 5 | Grupos cercanos | 🚗 🚌 🚲 🚂 ✈️ (tierra frente a aire) |
| 5 | 6 | Por una característica | 🍓 🍎 🍒 🌶️ 🍅 🍋 (rojos frente a uno amarillo) |

El tiempo, como en la memoria: el nivel 1 sin tiempo y después una serie por dificultad (HU-030). Las ayudas (por ejemplo, que el diferente brille un instante al empezar) solo en Fácil y Normal (HU-030 R10).

## 5. Reglas propuestas

| # | Regla |
|---|---|
| R1 | Botón «¿Cuál es diferente?» en el menú (HU-023), con su icono (HU-013, guía de estilo). |
| R2 | Cada tablero tiene exactamente un objeto diferente, en una posición al azar. |
| R3 | **Acierto:** el objeto salta y se pasa al siguiente tablero. **Fallo:** el objeto tocado hace un pequeño «no», cuenta como fallo y se puede seguir. Sin rojo, sin vibración, sin sonido de error. |
| R4 | Estrellas por nivel según los fallos (como HU-007 R9); el mejor resultado se guarda con su fecha (D-030). |
| R5 | Progreso propio con el formato de la memoria (typeId nuevo), o el modelo común si HU-023 lo decide (HU-007 P8). |
| R6 | Lector de pantalla: cada objeto se anuncia con su nombre; se elige con doble toque. |
| R7 | Sin pantallas ni textos nuevos para el niño: todo se entiende mirando. |

## 6. Encaje

| Decisión | Impacto |
|---|---|
| D-022, D-025 | Sin botones dentro del juego; salida protegida |
| D-024, D-026 | Solo emojis de Emoji 5.0 o anterior; los grupos se validan con un test como las temáticas de la memoria |
| D-028 | Modelo de acceso por decidir (P1) |
| D-030, D-031, D-037 | Estrellas, dorado y pérdida de logros iguales que en la memoria |
| HU-030 | Tiempo por dificultad y ayudas solo en Fácil y Normal |

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `domain/odd_one_out/`: catálogo de grupos (con la categoría de cada emoji), escalera, generador de tableros, estrellas |
| Estado | `OddOneOutCubit` (como `MemoryLadderCubit`) |
| Presentación | Pantalla del juego y su icono; reutiliza encabezado, barra de tiempo, celebración y `GestureHint` |
| Persistencia | Progreso del juego (typeId nuevo o modelo común, P5) |
| Tests | Catálogo (un diferente por tablero, Emoji 5.0), escalera, cubit, widgets, diseño en 9 idiomas |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Modelo de acceso? | **Gratis los niveles 1–4 y Premium el 5 y el tiempo**, como Sombras (D-028). Mantiene la coherencia entre juegos | Sí |
| P2 | ¿Cuántos niveles y objetos? | La tabla de la sección 4 (5 niveles, de 3 a 6 objetos) | Sí |
| P3 | ¿Cuántos tableros por nivel? | **3 tableros por nivel**: uno solo es muy corto para un nivel | No |
| P4 | ¿Las categorías se basan en significado (granja/salvaje) o en rasgos visibles (color, forma)? | **Las dos**, pero los rasgos visibles solo en niveles altos: a los 3 años, el significado se aprende antes | No |
| P5 | ¿Progreso propio o modelo común? | Decidirlo en HU-023, antes del tercer juego | No |

## 9. Fuera de alcance

- Narración que diga el nombre de los objetos (D-034).
- Grupos con imágenes propias (solo emojis).
