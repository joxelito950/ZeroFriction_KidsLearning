# HU-013 · Identidad visual: icono de la app, logo e iconos de los juegos

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-26; la integración empieza cuando estén los vectores del diseño, P7) |
| **Épica** | E6 · Publicación y distribución |
| **Prioridad** | P2 |
| **Tamaño** | M (2–3 días de integración), sin contar el tiempo de diseño, que hace el dueño del producto (P1) |
| **Desbloquea** | HU-002 (aspecto del dorado del icono del juego) y HU-014 (icono de la tienda) |

## 1. Historia

**Como** familia que busca una app para su hijo,
**quiero** que ToddlerLogic tenga un icono, un logo y unos iconos de juego propios y reconocibles,
**para** encontrarla con facilidad en el teléfono y en la tienda, y para que el niño reconozca cada juego sin saber leer.

## 2. Situación actual

- **Icono de la app:** el de Flutter por defecto, solo en PNG (`mipmap-*/ic_launcher.png`), sin versión adaptativa ni monocroma.
- **Menú:** sin imagen ni iconos de juego desde TD-006 (la mascota 🧸 era Emoji 11.0 y no se ve en Android 8, D-026). Encima del título queda un hueco vacío y el botón «Memoria» es solo texto.
- **Juego de memoria:** la cabecera usa el icono de Material `child_care_rounded` como marcador de posición.
- **HU-002** está `Lista` y espera a esta historia para tener el icono del juego sobre el que se dibuja el dorado.

## 3. Entregables

| # | Pieza | Formato | Uso |
|---|---|---|---|
| 1 | Icono adaptativo de la app | Capa de fondo + capa de primer plano, 108 × 108 dp con zona segura de 66 dp (vector drawable o PNG por densidad) | Launcher de Android 8+ (`minSdk` 26) |
| 2 | Icono monocromo | Una capa de un color, misma silueta | Iconos temáticos de Android 13+ |
| 3 | Icono de la tienda | PNG 512 × 512, 32 bits, sin transparencia en los bordes ni sombras añadidas | Ficha de Google Play (HU-014) |
| 4 | Logo | Vector (SVG): el mismo símbolo del icono de la app, sin el fondo | Encima del título del menú |
| 5 | Icono del juego de memoria | Vector (SVG), con silueta cerrada para el dorado de HU-002 | Botón «Memoria» del menú y cabecera del juego |
| 6 | Guía mínima | Paleta (con contraste AA sobre el fondo), tipografía y el estilo de trazo, en `docs/` | Que los juegos de HU-007 y HU-008 sigan el mismo estilo |

### Dónde va cada pieza

```
 Vertical                     Horizontal
┌──────────────────┐   ┌───────────────────────────────┐
│      [logo]      │   │    [logo]   │  ┌───────────┐  │
│   ToddlerLogic   │   │ ToddlerLogic│  │[ic]Memoria│  │
│ Juegos de lógica │   │  Juegos de… │  └───────────┘  │
│ ┌──────────────┐ │   │             │  Zona  · Salir  │
│ │ [ic] Memoria>│ │   └───────────────────────────────┘
│ └──────────────┘ │
│  Zona  ·  Salir  │   [ic] = icono del juego, con el dorado de HU-002
└──────────────────┘
```

## 4. Reglas

| # | Regla |
|---|---|
| R1 | **Sin emojis en la identidad:** el icono de la app, el logo y los iconos de los juegos son ilustraciones propias en vector, no emojis. Así no dependen de la versión de Emoji del teléfono (D-026) ni de cómo dibuja cada fabricante. Los emojis siguen siendo el contenido de las cartas (HU-001, R17). |
| R2 | **Legibles sin leer:** cada icono de juego se reconoce a 48 dp y a simple vista por un niño de 3 años; un concepto, una silueta clara, sin texto dentro. |
| R3 | **Diseño original**, sin elementos de marcas de terceros ni parecido con personajes conocidos. Si se usa algún recurso de terceros (por ejemplo, una tipografía), su licencia debe permitir el uso comercial y queda anotada en la guía. |
| R4 | **Coherente con los principios del README:** colores suaves y alegres, sin rojo de alarma. |
| R5 | **El icono del juego admite el dorado** con el llenado de abajo arriba (P5, opción A de HU-002): se entrega con una **silueta cerrada** sobre la que la app aplica un `ShaderMask`. La silueta debe reconocerse con cualquier porcentaje, del 0 % al 100 %. |
| R6 | El menú muestra el logo encima del título y el icono en el botón «Memoria»; la cabecera del juego sustituye `child_care_rounded` por el icono del juego. Ningún diseño nuevo desborda los tests de layout (9 idiomas × 4 teléfonos × orientaciones). |
| R7 | El icono de la app se ve bien en las máscaras habituales (círculo, ardilla, cuadrado redondeado) y en tema claro y oscuro del launcher. |
| R8 | **Sin mascota** en esta historia (P2). Las celebraciones siguen con las estrellas y el trofeo actuales. |

## 5. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-026 (Emoji 5.0) | Se cumple por construcción: la identidad no usa emojis (R1) |
| TD-006 | Esta historia es la que deshace la retirada de iconos del menú; el hueco de la mascota lo ocupa el logo |
| D-030 / HU-002 | El aspecto del dorado (P3 de HU-002) se cierra aquí, en P5 |
| HU-014 | El icono de 512 px es requisito previo de la ficha. Las capturas de la tienda se hacen ya con la identidad nueva |

## 6. Criterios de aceptación

1. **Dado** el teléfono con Android 8 o superior, **entonces** el launcher muestra el icono adaptativo nuevo y no el de Flutter, sin recortes en las máscaras circular, cuadrada y de ardilla.
2. **Dado** Android 13+ con iconos temáticos activados, **entonces** se ve la versión monocroma.
3. **Dado** el menú, **entonces** veo el logo encima del título y el botón «Memoria» con su icono, en vertical y en horizontal, en los 9 idiomas, sin desbordes.
4. **Dado** la pantalla del juego, **entonces** la cabecera muestra el icono del juego en lugar del marcador de posición.
5. **Dado** el lector de pantalla, **entonces** el logo se ignora (decorativo, el título ya dice el nombre) y el icono del juego no duplica el nombre del botón.
6. **Dado** el repositorio, **entonces** existe el PNG de 512 × 512 para la tienda y la guía mínima de estilo, con las licencias de los recursos de terceros que se usen.
7. **Dado** el test de emojis de D-026, **entonces** sigue en verde: no se añade ningún emoji fuera del catálogo de temáticas.

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Android | `mipmap-anydpi-v26/ic_launcher.xml` (adaptive-icon con `background`, `foreground` y `monochrome`) y las capas; se pueden generar con `flutter_launcher_icons` (dependencia de desarrollo) o a mano desde Android Studio |
| Dependencias | `flutter_svg` para el logo y los iconos en vector (P6) |
| Presentación | Logo en el menú, icono en el botón «Memoria» y en la cabecera del juego; un widget `GameIcon` preparado para recibir el porcentaje dorado de HU-002 |
| Assets | `assets/brand/` con los SVG; registrados en `pubspec.yaml` |
| Tests | Golden o de widget del menú y la cabecera; layout en los 9 idiomas; comprobación de que los assets existen y cargan |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Quién hace el diseño? | ✅ Decidido (2026-10-26): **el dueño del producto** prepara los vectores siguiendo las especificaciones de las secciones 3 y 4; la integración la hace el desarrollo | — |
| P2 | ¿Hay mascota? | ✅ Decidido (2026-10-26): **no en esta historia.** No es un requisito del producto (venía del 🧸 de la versión 0.0.1-beta) y es la pieza que más diseño exige. Su hueco en el menú lo ocupa el logo. Queda como idea en **HU-017** | — |
| P3 | ¿Qué símbolo tiene el icono de la app? | Lo decide el diseño. Mismo símbolo que el logo, sobre un fondo de color liso | No |
| P5 | ¿Cómo se ve el dorado del icono del juego (P3 de HU-002)? | ✅ Decidido (2026-10-26): **A, llenado de abajo arriba**. El porcentaje se entiende a simple vista y es un `ShaderMask` sobre la silueta, válido para cualquier icono futuro | — |
| P6 | ¿`flutter_svg` o convertir los vectores a código? | ✅ Asumida la recomendación: **`flutter_svg`**, la opción estándar, que deja cambiar el diseño sin tocar código | — |
| P7 | ¿Plazo del diseño? | ⏭️ Aplazada: lo marca el dueño del producto. La integración (2–3 días) empieza cuando estén los vectores | — |

## 9. Fuera de alcance

- Mascota (HU-017).
- Iconos de los juegos futuros (HU-007, HU-008): llegan con cada juego, siguiendo la guía del entregable 6.
- Capturas y gráfico de la ficha de la tienda (1024 × 500): HU-014.
- Cambiar el icono del launcher según el progreso (descartado en HU-001).
- Icono de iOS (TD-005, HU-015).
