# HU-013 · Identidad visual: icono de la app, logo e iconos de los juegos

| | |
|---|---|
| **Estado** | En curso (integración desarrollada el 2026-11-05 en `feature/hu-013-identity`; falta verla en el moto g55). Refinamiento cerrado el 2026-10-26, ampliado el 2026-10-27 (paleta) y el 2026-11-05 (personaje e ilustración PNG, D-036) |
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
| 1 | Icono adaptativo de la app | Fondo liso teal profundo + primer plano PNG por densidad dentro de la zona segura de 66 dp (generado con `flutter_launcher_icons`) | Launcher de Android 8+ (`minSdk` 26) |
| 2 | Icono monocromo | Silueta del niño, una capa (PNG por densidad; el sistema la tiñe) | Iconos temáticos de Android 13+ |
| 3 | Icono de la tienda | PNG 512 × 512, 32 bits, sin transparencia en los bordes ni sombras añadidas | Ficha de Google Play (HU-014) |
| 4 | Logo | Ilustración PNG con transparencia (D-036): el niño con el puzle | Encima del título del menú |
| 5 | Icono del juego de memoria | Ilustración PNG con transparencia (D-036): dos cartas; su silueta recibe el dorado de HU-002 | Botón «Memoria» del menú y cabecera del juego |
| 6 | Guía mínima | [docs/brand/GUIA.md](../brand/GUIA.md): personaje, estilo, colores, tipografía y cómo regenerar las piezas | Que los juegos de HU-007 y HU-008 sigan el mismo estilo |

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

### 4.1 Paleta de colores (decidida el 2026-10-27, D-032)

La identidad usa **solo** los 7 colores de [docs/brand/PALETA.md](../brand/PALETA.md) (referencia visual: [paleta-colores.jpg](../brand/paleta-colores.jpg)): **base cálida + acción fría**.

| Color | Hex | En la identidad |
|---|---|---|
| Teal profundo | `#00454D` | Marca: el símbolo del logo y del icono de la app, y el trazo de los iconos de los juegos |
| Crema cálido | `#FFF2E2` | Fondo del icono adaptativo y del icono de la tienda; fondo de las pantallas |
| Coral suave | `#D9735F` | Acentos cálidos dentro de las ilustraciones |
| Ámbar | `#ECA463` | Acentos alegres dentro de las ilustraciones |
| Dorado | `#A86B12` | **Llenado dorado** del icono del juego (HU-002, P5) y estrellas o insignia |
| Azul petróleo | `#176B78` | Botones y elementos que se tocan; no se usa en el símbolo de marca |
| Blanco | `#FFFFFF` | Texto sobre azul petróleo y superficies de tarjetas |

Solo se permiten transparencias de estos colores; los emojis de las cartas y el icono monocromo (lo tiñe el sistema) quedan fuera de la regla. Las combinaciones de texto válidas y el contraste de cada par están en PALETA.md. La paleta se aplica en el código y se impone con un test en **TD-009**, que no depende de los vectores y puede hacerse antes que esta historia.

### 4.2 Reglas de las piezas

| # | Regla |
|---|---|
| R1 | **Sin emojis en la identidad:** el icono de la app, el logo y los iconos de los juegos son ilustraciones propias, no emojis. Así no dependen de la versión de Emoji del teléfono (D-026) ni de cómo dibuja cada fabricante. **Cambiado el 2026-11-05 (P9, D-036):** pueden ser ilustraciones en PNG con transparencia en lugar de vectores. Los emojis siguen siendo el contenido de las cartas (HU-001, R17). |
| R2 | **Legibles sin leer:** cada icono de juego se reconoce a 48 dp y a simple vista por un niño de 3 años; un concepto, una silueta clara, sin texto dentro. |
| R3 | **Diseño original**, sin elementos de marcas de terceros ni parecido con personajes conocidos. Si se usa algún recurso de terceros (por ejemplo, una tipografía), su licencia debe permitir el uso comercial y queda anotada en la guía. |
| R4 | **Colores de la paleta** (4.1). **Cambiado el 2026-11-05 (P9, D-036):** las ilustraciones usan los tonos de la paleta con su volumen y sus sombras suaves (estilo 3D de plastilina mate); la piel y el pelo del personaje mantienen su tono natural. Lo que no es ilustración (el fondo del icono adaptativo, la interfaz) usa solo los 7 colores. Sin rojo de alarma. |
| R5 | **El icono del juego admite el dorado** con el llenado de abajo arriba (P5, opción A de HU-002): se entrega con una **silueta cerrada** sobre la que la app aplica un `ShaderMask`. La silueta debe reconocerse con cualquier porcentaje, del 0 % al 100 %. |
| R6 | El menú muestra el logo encima del título y el icono en el botón «Memoria»; la cabecera del juego sustituye `child_care_rounded` por el icono del juego. Ningún diseño nuevo desborda los tests de layout (9 idiomas × 4 teléfonos × orientaciones). |
| R7 | El icono de la app se ve bien en las máscaras habituales (círculo, ardilla, cuadrado redondeado) y en tema claro y oscuro del launcher. |
| R8 | **Personaje de identidad** (cambiado el 2026-11-05, P2): el niño de la imagen base es el personaje de la app y aparece en el icono y en el logo. Las celebraciones siguen con las estrellas y el trofeo actuales; usarlo en otras pantallas (descanso, celebraciones) queda para HU-017. |

## 5. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-026 (Emoji 5.0) | Se cumple por construcción: la identidad no usa emojis (R1) |
| D-032 (paleta) | Fija los colores de la identidad (4.1); TD-009 los aplica a toda la app |
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
8. **Dado** el icono adaptativo, **entonces** su fondo es el teal profundo de la paleta (test que lee `colors.xml`). Las ilustraciones PNG no pasan por un test de colores (D-036); se revisan a ojo con la guía.
9. **Dado** el icono de la tienda y el adaptativo, **entonces** el símbolo en teal profundo sobre crema cálido tiene un contraste de al menos 3:1 (9,73:1 con esos dos colores).

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Android | `mipmap-anydpi-v26/ic_launcher.xml` (adaptive-icon con `background`, `foreground` y `monochrome`) y las capas; se pueden generar con `flutter_launcher_icons` (dependencia de desarrollo) o a mano desde Android Studio |
| Dependencias | `flutter_launcher_icons` (solo de desarrollo) para el icono adaptativo y el monocromo. **Sin** `flutter_svg`: las piezas son PNG (D-036) |
| Presentación | Logo en el menú, icono en el botón «Memoria» y en la cabecera del juego; un widget `GameIcon` preparado para recibir el porcentaje dorado de HU-002 |
| Assets | `assets/brand/` con los SVG; registrados en `pubspec.yaml` |
| Tests | Golden o de widget del menú y la cabecera; layout en los 9 idiomas; comprobación de que los assets existen y cargan; colores de los SVG dentro de la paleta (criterio 8) |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Quién hace el diseño? | ✅ Decidido (2026-10-26): **el dueño del producto** prepara los vectores siguiendo las especificaciones de las secciones 3 y 4; la integración la hace el desarrollo | — |
| P2 | ¿Hay mascota? | ✅ Decidido (2026-10-26): no en esta historia. **Cambiado el 2026-11-05:** el dueño aporta una imagen base con un niño, que **se queda como personaje de identidad** de la app (icono y logo). Sus usos dentro de la app siguen en **HU-017** | — |
| P3 | ¿Qué símbolo tiene el icono de la app? | ✅ Decidido (2026-11-05): **el niño detrás de una mesa curva con varios juegos de la app** (carta de memoria, pieza de puzle, forma con su sombra), no solo un rompecabezas. Imagen base del dueño, generada con IA; las capas definitivas se piden con los textos de [PROMPTS-identidad.md](../brand/PROMPTS-identidad.md) | — |
| P9 | La base es una ilustración 3D en imagen (PNG), no un vector, y usa degradados y tonos fuera de la paleta (piel, pelo). ¿Se aceptan en el icono, el logo y el icono del juego? | ✅ Decidido (2026-11-05): **sí** (R1, R4, D-036). El dorado de HU-002 funciona igual sobre un PNG con transparencia (`GameIcon`, `ShaderMask`) | — |
| P5 | ¿Cómo se ve el dorado del icono del juego (P3 de HU-002)? | ✅ Decidido (2026-10-26): **A, llenado de abajo arriba**. El porcentaje se entiende a simple vista y es un `ShaderMask` sobre la silueta, válido para cualquier icono futuro | — |
| P6 | ¿`flutter_svg` o convertir los vectores a código? | ✅ Asumida la recomendación: `flutter_svg`. **Sustituida el 2026-11-05 por P9:** las piezas son PNG y no hace falta | — |
| P8 | ¿Qué paleta usa la identidad? | ✅ Decidido (2026-10-27): la de [PALETA.md](../brand/PALETA.md) (D-032), aportada por el dueño del producto. Es obligatoria para toda la app, no solo para esta historia | — |
| P7 | ¿Plazo del diseño? | ⏭️ Aplazada: lo marca el dueño del producto. La integración (2–3 días) empieza cuando estén los vectores | — |

## 9. Fuera de alcance

- Mascota (HU-017).
- Iconos de los juegos futuros (HU-007, HU-008): llegan con cada juego, siguiendo la guía del entregable 6.
- Capturas y gráfico de la ficha de la tienda (1024 × 500): HU-014.
- Cambiar el icono del launcher según el progreso (descartado en HU-001).
- Icono de iOS (TD-005, HU-015).

## 10. Desarrollo

Rama `feature/hu-013-identity`, 2026-11-05. Imágenes del dueño, generadas con IA (ChatGPT, con sus credenciales de contenido C2PA), elegidas tras revisarlas: [fuentes](../brand/fuentes/).

| Pieza | Fuente | Resultado |
|---|---|---|
| Icono adaptativo | `icono-nino-rompecabezas.png` | Primer plano centrado en la zona segura (radio 0,30 del lienzo, compensando el margen del 16 % que añade `flutter_launcher_icons`) sobre el fondo `#00454D`. Probado en círculo, cuadrado redondeado y cuadrado |
| Monocromo | `monocromo-silueta-nino.png` | Solo el canal alfa, en negro; el sistema lo tiñe |
| Icono de Android 7 y anteriores | `icono-nino-rompecabezas.png` | Cuadrado teal con el niño (`minSdk` 26: solo de respaldo) |
| Icono de la tienda | `icono-nino-rompecabezas.png` | `docs/store/icon-512.png`, 512 × 512, sin transparencia (lo comprueba un test) |
| Logo | `logo-nino-piezas.png` | `assets/brand/logo.png` (480 px), encima del título del menú; hasta 160 dp y nunca más de un tercio del lado corto de la pantalla |
| Icono de memoria | `icono-memoria-cartas.png` | `assets/brand/memory_icon.png` (256 px): botón «Memoria» (52 dp) y cabecera del juego (48 dp), en lugar de `child_care_rounded` |

- Las piezas se regeneran con `python tool/brand/prepare_brand_images.py` (necesita Pillow) y `dart run flutter_launcher_icons`.
- `GameIcon` (`presentation/widgets/game_icon.dart`) ya acepta el porcentaje dorado de HU-002: llena la silueta de abajo arriba con `ShaderMask` en `srcATop`.
- Las rutas de las imágenes están en `lib/brand/brand_assets.dart`.
- Tests: imágenes incluidas en la app, icono adaptativo con monocromo en todas las densidades, fondo de la paleta, icono de la tienda sin transparencia, logo e icono en el menú y en la cabecera, ignorados por el lector de pantalla; los tests de diseño (9 idiomas, 4 teléfonos, 2 escalas de texto) siguen en verde con el logo.

Pendiente:
- Verlo en el moto g55: launcher (con y sin iconos temáticos), menú y cabecera del juego, en vertical y en horizontal.
- La escena con varios juegos (petición 1 de [PROMPTS-identidad.md](../brand/PROMPTS-identidad.md)) no se consiguió; el puzle queda como símbolo genérico de lógica. Si llega, se cambia regenerando las piezas, sin tocar código.
- La carta clara del icono de memoria tiene una esquina cortada que recuerda a un documento: se puede pedir con las cuatro esquinas redondeadas.
