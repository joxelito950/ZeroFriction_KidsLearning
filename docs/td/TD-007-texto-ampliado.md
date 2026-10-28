# TD-007 · La app con el texto ampliado del sistema

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-28) |
| **Prioridad** | P2: antes de las capturas y la prueba cerrada de HU-014 |
| **Tamaño** | S (1–2 días) |
| **Depende de** | Nada. Si HU-021 se hace antes, sus líneas de ayuda entran en estos tests; si se hace después, HU-021 las añade |

## 1. Objetivo

Que la app siga usable cuando el adulto tiene el **texto ampliado** en *Ajustes › Pantalla › Tamaño de fuente* (muchos adultos lo usan), y que el CI lo vigile.

## 2. Medición (2026-10-28)

Se ejecutaron los tests de diseño actuales (`responsive_layout_test.dart`: 9 idiomas × 4 teléfonos × 9 pantallas = 324 casos) con la escala de texto a 1,3 y a 2,0 (el máximo de Android 14 y posteriores):

| Pantalla | Escala 1,3 | Escala 2,0 |
|---|---|---|
| Menú principal | ✅ | ✅ (se desplaza) |
| Desafío de adultos | ✅ | ❌ 11 casos: en horizontal (y en vertical en el teléfono compacto en alemán y francés) **el recuadro de la respuesta o la tecla «borrar» quedan fuera de la vista**: el adulto teclea sin ver lo que escribe |
| Mensaje de respuesta incorrecta | ✅ | ✅ |
| Zona de Padres | ✅ | ✅ (se desplaza) |
| Tableros del juego (5 niveles) | ❌ 15 casos: teléfono compacto en vertical, en árabe, francés y portugués | ❌ 98 casos: casi todos los idiomas y teléfonos |

**Causa en el juego:** la cabecera (título, instrucciones, contador) y el pie crecen con el texto y no dejan alto para el tablero (`memory_game_screen.dart`, la columna principal se desborda hasta 158 px). Además, el **símbolo de cada carta** es un texto de 42 puntos que también crece: a 2,0 mide 84 y no cabe en las cartas del tablero de 16.

## 3. Propuesta

| # | Regla |
|---|---|
| A1 | **Pantallas de adultos** (menú, desafío, mensaje, Zona de Padres): respetan el texto del sistema **hasta 2,0** sin desbordes, desplazándose si hace falta |
| A2 | **Desafío:** el recuadro de la respuesta va **pegado al teclado** (encima de él), para que siempre se vea lo que se escribe; la pregunta puede desplazarse aparte. Las 12 teclas siguen midiendo al menos 48 dp |
| A3 | **Pantalla del juego:** los textos de la cabecera y el pie se limitan a **1,3** (`MediaQuery.withClampedTextScaling`). El niño de 3 años no los lee; el tablero es lo que importa. A 1,3 no se desborda en ningún teléfono ni idioma (se corrigen los 15 casos de hoy) |
| A4 | **Símbolos de las cartas:** no siguen el texto del sistema; son dibujos y se ajustan al tamaño de la carta (`TextScaler.noScaling` y tamaño relativo a la carta) |
| A5 | **Celebraciones y aviso de tiempo agotado:** como el juego, hasta 1,3 |
| A6 | Tests: `responsive_layout_test.dart` gana la escala como otra dimensión: **1,0 y 2,0** para las pantallas de adultos y **1,0 y 1,3** para el juego (con 2,0 debe comportarse igual que con 1,3). Un test comprueba que los símbolos de las cartas no cambian de tamaño con la escala |

## 4. Criterios de aceptación

1. **Dado** el texto del sistema a 2,0, **entonces** el menú, el desafío, el mensaje de fallo y la Zona de Padres no se desbordan en los 9 idiomas, en vertical y en horizontal, y todas sus acciones se pueden alcanzar.
2. **Dado** el desafío con el texto a 2,0, **cuando** tecleo, **entonces** veo el recuadro de la respuesta junto al teclado sin desplazar la pantalla.
3. **Dado** el texto del sistema a 1,3 o a 2,0, **entonces** los 5 tableros caben sin cortar cartas en los 4 teléfonos y los 9 idiomas, y la cabecera y el pie se ven como a 1,3.
4. **Dado** cualquier escala, **entonces** el símbolo de cada carta mide lo mismo que a 1,0.
5. El CI ejecuta estos casos en cada PR.

## 5. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿El juego limita su texto a 1,3 (A3) o debe crecer hasta 2,0 como el resto? | ✅ Decidido (2026-10-28): **limitar a 1,3.** Crecer hasta 2,0 obliga a encoger el tablero, que es lo que usa el niño; los textos del juego son para el adulto que lo acompaña y a 1,3 ya son grandes | — |
| P2 | ¿Las pantallas de adultos respetan el texto hasta 2,0 (el máximo de Android) o también se limitan? | ✅ Decidido (2026-10-28): **hasta 2,0.** Son las que lee el adulto; limitarlas va contra la accesibilidad, y hoy ya cumplen todas salvo el desafío | — |
| P3 | ¿Cuántas escalas prueba el CI? | ✅ Aceptada la recomendación: **1,0 y 2,0 en adultos, 1,0 y 1,3 en el juego** (A6). Probar también 1,3 en adultos o 1,5 añade casos sin encontrar más fallos en la medición | No |

## 6. Fuera de alcance

- Tablets y pantallas grandes (TD-010).
- Tamaño de visualización del sistema (*Tamaño de pantalla*), que cambia los dp y ya lo cubren en parte los dos teléfonos de referencia.
