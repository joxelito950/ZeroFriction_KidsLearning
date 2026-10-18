# HU-011 · Multiidioma: textos desde un catálogo e idioma del sistema

| | |
|---|---|
| **Estado** | En refinamiento (análisis del 2026-10-18; el desarrollo **no** ha empezado) |
| **Épica** | E5 · Plataforma y calidad (habilita la publicación en varios mercados) |
| **Prioridad** | P1: **antes de HU-001**, para que los textos nuevos nazcan ya en el catálogo |
| **Tamaño** | M (3–4 días) |
| **Relacionadas** | HU-012 (selector de idioma en la Zona de Padres), HU-004 (Zona de Padres), HU-014 (ficha de la tienda en varios idiomas) |

## 1. Historia

**Como** familia que no habla español,
**quiero** que la app aparezca en el idioma de mi teléfono desde el primer arranque y que un adulto pueda cambiarlo,
**para** que el niño y yo entendamos todos los textos.

## 2. Situación actual

- **22 textos visibles fijos en el código**, en 5 archivos: el menú, la pantalla del juego, la carta (2 etiquetas de accesibilidad) y el diálogo de victoria. Uno lleva variable con plural («Completado en $moves movimientos»).
- El nombre de la app aparece fijo en 2 sitios: `android:label="ToddlerLogic"` en el manifiesto y `title: 'ToddlerLogic'` en `MaterialApp`.
- La decisión D-015 dice «solo español, con los textos en el código». Esta historia la sustituye.
- El contenido de los juegos son emojis: **no dependen del idioma**. Es una ventaja: solo hay que traducir la interfaz.

## 3. Viabilidad: sí, con las herramientas oficiales de Flutter

| Pieza | Herramienta | Nota |
|---|---|---|
| Catálogo de textos | Archivos **ARB** (`lib/l10n/app_es.arb`, `app_en.arb`, …) con la herramienta oficial `gen-l10n` | Genera la clase `AppLocalizations` con un método por texto. Si falta una traducción o una clave, el proyecto no compila |
| Plurales y variables | Formato ICU dentro del ARB | Ejemplo: `{count, plural, =1{1 movimiento} other{{count} movimientos}}` |
| Textos de Material (diálogos, accesibilidad del sistema) | `flutter_localizations` (incluido en el SDK) | Sin dependencias externas nuevas salvo `intl`, que es oficial de Dart |
| Idioma del sistema | `PlatformDispatcher.locales` | Se compara con los idiomas soportados |
| Idioma elegido | Nuevo campo en `UserProfile` (`@HiveField(2)`, opcional) | Ampliar un tipo existente con un índice nuevo es compatible con los datos guardados (sección 3.4 de la especificación) |

## 4. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | **Ningún texto visible para el usuario se escribe en el código**: todos salen del catálogo. Incluye las etiquetas de accesibilidad (`Semantics`). Los mensajes técnicos para desarrolladores (excepciones, logs) siguen en inglés y fuera del catálogo |
| R2 | **Primer arranque:** se toma el primer idioma del teléfono que la app soporte y se **guarda**. Si ninguno está soportado, se usa el idioma por defecto (P2) |
| R3 | **Arranques siguientes:** se usa el idioma guardado, **aunque cambie el del teléfono** (así lo pediste: se toma del sistema solo la primera vez) |
| R4 | Cambiarlo es una opción de adulto, en la Zona de Padres (HU-012). Hasta que exista, el idioma solo se fija en el primer arranque |
| R5 | Todos los idiomas soportados tienen **todas** las claves traducidas; un test lo comprueba |
| R6 | Las pantallas se prueban sin overflow en cada idioma soportado (los textos traducidos pueden ser más largos) |

## 5. El nombre de la app en varios idiomas

El nombre aparece en **tres sitios distintos**, y cada uno se gestiona de forma diferente:

| Dónde se ve | Cómo se traduce | Qué idioma usa | Limitación |
|---|---|---|---|
| **Icono en el teléfono** (launcher) | Recursos de Android: `res/values/strings.xml` (por defecto) y `res/values-en/strings.xml`, etc.; el manifiesto pasa a `android:label="@string/app_name"` | **El del sistema**, no el elegido dentro de la app | Si un padre elige inglés en un teléfono en español, el icono seguirá mostrando el nombre en español |
| **Dentro de la app** y en «recientes» | `MaterialApp.onGenerateTitle`, desde el catálogo | El elegido en la app | Ninguna |
| **Ficha de la tienda** | En Google Play Console, una ficha por idioma (nombre de hasta 30 caracteres, descripciones y capturas) | El del usuario de la tienda | Se gestiona en la consola, no en el código (HU-014) |

**Recomendación:** que **«ToddlerLogic» sea una marca y no se traduzca** (igual en todos los idiomas). Así la limitación del icono desaparece y la marca es reconocible en todos los mercados. Lo que sí se traduce es el lema («Juegos de lógica y atención») y la ficha de la tienda. Igualmente se crean los `strings.xml` por idioma, para poder cambiarlo en el futuro sin tocar el código.

## 6. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Con qué idiomas empezamos? | **Español** (base) e **inglés**. Opcional: **portugués de Brasil**, por el mercado latinoamericano. Cada idioma nuevo después solo requiere un ARB | Sí |
| P2 | Si el idioma del teléfono no está soportado, ¿cuál usamos? | Inglés, el más comprendido internacionalmente. Alternativa: español, el mercado inicial | Sí |
| P3 | ¿El nombre «ToddlerLogic» se traduce? | No: es una marca (sección 5) | Sí |
| P4 | ¿El español base es neutro o con variantes (es-ES, es-CO)? | Neutro: un solo `app_es.arb`, con vocabulario sin regionalismos | No (hay recomendación) |
| P5 | ¿Quién traduce? | Borrador generado y revisado por una persona nativa antes de publicar; para un público infantil, el tono importa | No |

## 7. Criterios de aceptación (borrador)

1. **Dado** el código de `lib/`, **entonces** ningún widget muestra un texto literal; un test o una revisión automática lo comprueba (P: herramienta a definir al implementar).
2. **Dado** un teléfono en inglés que abre la app por primera vez, **entonces** toda la app está en inglés y el idioma queda guardado.
3. **Dado** un teléfono en un idioma no soportado, **entonces** la app usa el idioma por defecto (P2).
4. **Dado** que el idioma quedó guardado, **cuando** cambio el idioma del teléfono y reabro la app, **entonces** la app mantiene el idioma guardado.
5. **Dado** cada idioma soportado, **entonces** todas las claves del catálogo tienen traducción (test de paridad).
6. **Dado** cada idioma soportado, **entonces** el menú y el juego se ven sin overflow en vertical y horizontal en los tamaños de referencia.
7. **Dado** el lector de pantalla activado, **entonces** las etiquetas de las cartas se leen en el idioma de la app.
8. **Dado** el icono de la app en el teléfono, **entonces** muestra el nombre definido en los recursos de Android del idioma del sistema.

## 8. Impacto técnico

| Área | Cambio |
|---|---|
| Dependencias | `flutter_localizations` (SDK) e `intl`; `generate: true` en `pubspec.yaml`; `l10n.yaml` |
| Dominio y datos | `UserProfile.languageCode` (`@HiveField(2)`, opcional) y regla de resolución del idioma (lógica pura y testeable) |
| Presentación | `MaterialApp` con `localizationsDelegates`, `supportedLocales`, `locale` y `onGenerateTitle`; los 22 textos y las 2 etiquetas pasan al catálogo |
| Android | `res/values*/strings.xml` con `app_name`; el manifiesto usa `@string/app_name` |
| Tests | Los tests que buscan textos en español fijan el idioma `es` explícitamente; tests de resolución del idioma, de paridad del catálogo y de layout por idioma |
| Especificación | D-015 sustituida por una decisión nueva de multiidioma; regla «sin textos fijos» en la sección 4.1 |

## 9. Fuera de alcance

- El selector de idioma en la Zona de Padres (HU-012).
- Traducir la ficha de la tienda (HU-014).
- La preferencia de idioma por app de Android 13 (*per-app language*): permitiría elegir el idioma desde los ajustes del sistema; se evaluará en HU-012.
- Idiomas de derecha a izquierda (árabe, hebreo).
