# TD-009 · Aplicar la paleta de colores e impedir colores fuera de ella

| | |
|---|---|
| **Estado** | Hecha (2026-10-27). Revisada en el emulador; queda la revisión en el moto g55 (A5) |
| **Prioridad** | P1: conviene antes de las capturas de la tienda (HU-014) y de cualquier historia con interfaz nueva (HU-005, HU-009, HU-010) |
| **Tamaño** | M (1–2 días) |
| **Decisión que aplica** | D-032 (paleta cerrada, [docs/brand/PALETA.md](../brand/PALETA.md)); sustituye a D-005 (semilla `#98FFD9`) |
| **Depende de** | Nada: no necesita los vectores de HU-013 |

## 1. Objetivo

Que toda la app use **solo** los 7 colores de la paleta y que el CI **impida** que nadie añada otro.

## 2. Situación actual (inventario del 2026-10-27)

- **36 colores literales distintos** (`Color(0x…)`) y `Colors.white`, `Colors.black`, `Colors.blueGrey[500/600/800]` y `Colors.transparent`, repartidos en 11 archivos: `main.dart`, `main_menu_screen.dart`, `memory_game_screen.dart`, `parental_gate_screen.dart`, `parents_zone_screen.dart`, `memory_card_widget.dart`, `memory_level_indicator.dart`, `memory_round_overlay.dart`, `memory_time_bar.dart`, `parental_gate_message.dart` y `quiet_hint.dart`.
- El tema se genera con `ColorScheme.fromSeed(seedColor: Color(0xFF98FFD9))` (D-005): Material deriva de esa semilla tonos que no están en la paleta (botones, interruptores, tarjetas).

## 3. Alcance

| # | Requisito |
|---|---|
| A1 | `lib/presentation/theme/app_palette.dart`: los 7 colores como constantes (`deepTeal`, `warmCream`, `softCoral`, `amber`, `gold`, `petrolBlue`, `white`) y el `ThemeData` de la app con un `ColorScheme` construido **color a color** con ellos (primario azul petróleo sobre blanco, superficie crema o blanco, texto teal profundo…), sin `fromSeed`. |
| A2 | Sustituir cada color de los 11 archivos por su equivalente de la paleta según la tabla «Asignación propuesta por elemento» de PALETA.md. Las sombras y velos usan teal profundo con transparencia. |
| A3 | `test/architecture/palette_test.dart`, que falla si en `lib/` (salvo `app_palette.dart` y el código generado) aparece `Color(0x`, `Color.fromARGB`, `Color.fromRGBO`, `Colors.` distinto de `Colors.transparent` o `fromSeed`. Mismo estilo que `no_hardcoded_texts_test.dart`. |
| A4 | El mismo test comprueba que `AppPalette` tiene **exactamente** los 7 valores de PALETA.md, y que las parejas de texto del tema (`onPrimary` sobre `primary`, `onSurface` sobre `surface`…) cumplen 4,5:1. |
| A5 | Los tests de layout y de pantalla siguen en verde; se revisan en el teléfono el menú, el juego (los 5 niveles), las celebraciones, el desafío y la Zona de Padres, en vertical y en horizontal. |
| A6 | Se actualiza la sección 3.2 de la especificación (carpeta `theme/`) y se marca D-005 como sustituida (ya hecho en el PR de la paleta). |

## 4. Criterios de aceptación

1. **Dado** `lib/`, **cuando** alguien añade `Colors.red` o `Color(0xFF123456)` fuera de `app_palette.dart`, **entonces** el CI falla con el archivo y la línea.
2. **Dado** `AppPalette`, **entonces** sus valores son los de PALETA.md y el test lo comprueba.
3. **Dado** el tema, **entonces** todas las parejas de texto cumplen 4,5:1.
4. **Dado** la app en el teléfono, **entonces** todas las pantallas usan la paleta y siguen sin desbordes en los 9 idiomas.

## 5. Riesgos

- **Cambio visual grande:** todo el aspecto cambia de golpe (de los pasteles azul y amarillo actuales a la base cálida). Se acepta: es la identidad decidida. Conviene una revisión del dueño del producto con capturas antes de fusionar.
- **Componentes de Material** que usan roles del `ColorScheme` no asignados explícitamente (por ejemplo, `surfaceContainerHighest`): A1 los asigna todos para que no aparezcan tonos derivados.

## 6. Resultado (2026-10-27)

- `lib/presentation/theme/app_palette.dart` (los 7 colores, único archivo con literales) y `app_theme.dart` (`AppTheme.colorScheme`, con **todos** los roles asignados a mano; `error` es teal profundo porque la paleta no tiene rojo, C7).
- Los 11 archivos usan solo `AppPalette` y sus transparencias; los degradados se sustituyen por colores lisos (un degradado entre dos colores crea tonos intermedios).
- `test/architecture/palette_test.dart`: un test por archivo de `lib/` (falla con archivo, línea y regla), los valores leídos de la tabla de PALETA.md, los 7 literales como máximo y el contraste ≥ 4,5:1 de 15 parejas de texto del tema. Comprobado que falla al introducir `Colors.red`.
- Ajustes respecto a la asignación propuesta, ya reflejados en PALETA.md: la **barra de tiempo** y el **contador de movimientos** van en teal profundo (no se tocan, C6); la **medalla** del menú va en dorado sobre un círculo blanco (el dorado sobre azul petróleo da 1,40:1); las **teclas** del desafío son blancas con borde y número en azul petróleo.
- 669 tests en verde, cobertura 99,6 %.

## 7. Fuera de alcance

- Los vectores de la identidad (HU-013).
- Modo oscuro (no está previsto; si se quisiera, la paleta tendría que ampliarse con su propia decisión).
