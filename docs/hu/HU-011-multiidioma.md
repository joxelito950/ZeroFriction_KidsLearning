# HU-011 · Multiidioma: textos desde un catálogo e idioma del sistema

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-19; se desarrolla después de los pendientes técnicos) |
| **Épica** | E5 · Plataforma y calidad (habilita la publicación en varios mercados) |
| **Prioridad** | P1: **antes de HU-001**, para que los textos nuevos nazcan ya en el catálogo |
| **Tamaño** | L (~1 semana: 9 idiomas, RTL y tests de layout por idioma) |
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

## 6. Idiomas soportados (decisión del 2026-10-19)

| # | Idioma | Locale | Archivo | Notas |
|---|---|---|---|---|
| 1 | **Inglés (EE. UU.)** | `en` (`en_US`) | `app_en.arb` (**plantilla** del catálogo) | **Idioma por defecto** si el del teléfono no está soportado o no se puede leer |
| 2 | Español (Latinoamérica y España) | `es` | `app_es.arb` | Un solo español neutro para ambos (P4). Si algún día hace falta una variante, se añade `app_es_ES.arb` solo con las diferencias |
| 3 | Portugués (Brasil) | `pt_BR` | `app_pt_BR.arb` | — |
| 4 | Alemán | `de` | `app_de.arb` | Los textos suelen ser **~30 % más largos**: mayor riesgo de overflow |
| 5 | Japonés | `ja` | `app_ja.arb` | Fuente CJK del sistema (Noto); sin espacios entre palabras: los saltos de línea los gestiona Flutter |
| 6 | Francés | `fr` | `app_fr.arb` | Espacios de no separación antes de «?» y «!» |
| 7 | Italiano | `it` | `app_it.arb` | — |
| 8 | Coreano | `ko` | `app_ko.arb` | Fuente CJK del sistema (Noto) |
| 9 | Árabe | `ar` | `app_ar.arb` | **RTL**: se mantiene; ver sección 7 |

- **Tamaño:** ninguna fuente se incluye en la app; Android aporta las de japonés, coreano y árabe. Los ARB pesan unos pocos KB.
- **Orden de resolución en el primer arranque:** el primer idioma de la lista de preferencias del teléfono que coincida, primero por idioma y país y después solo por idioma (un teléfono `pt_PT` caería en `pt_BR`; `es_MX` y `es_ES` en `es`). Si no hay coincidencia, inglés.

## 7. Árabe y escritura de derecha a izquierda (RTL): análisis

**Conclusión: es viable y se mantiene.** El código actual no tiene ningún elemento que corregir para RTL, y el coste es bajo si se adoptan ahora las reglas RTL de esta sección.

### Qué hace Flutter automáticamente

Con el locale `ar`, Flutter activa `TextDirection.rtl` en toda la app: las filas (`Row`) se invierten, `start`/`end` pasan a la derecha/izquierda, los widgets de Material se reflejan y el texto árabe se dibuja con la fuente del sistema (Noto Naskh/Sans Arabic). La marca «ToddlerLogic», en caracteres latinos, se muestra bien dentro del texto árabe (texto bidireccional).

### Estado del código actual (revisado el 2026-10-19)

| Elemento | Archivo | ¿Afecta en RTL? |
|---|---|---|
| `EdgeInsets.fromLTRB(20, 18, 20, 20)` y `(24, 24, 24, 20)` | `memory_game_screen.dart`, `memory_victory_dialog.dart` | No: mismos márgenes a izquierda y derecha |
| `rotateY` del volteo de cartas | `memory_card_widget.dart` | No: el sentido del giro es indiferente |
| Degradados `topLeft → bottomRight` | `memory_card_widget.dart` | No: decorativo |
| Flecha `chevron_right_rounded` en los botones del menú | `main_menu_screen.dart` | No: el icono está definido con `matchTextDirection: true` y Flutter lo invierte solo en RTL (comprobado en el SDK 3.47.5) |

### Impactos

| Área | Impacto | Medida |
|---|---|---|
| Layout | Bajo: la app usa `Row`, `Column` y `CrossAxisAlignment.start`, que ya se adaptan | Reglas RTL (abajo) y tests de layout con `ar` |
| HU-001 | La barra de tiempo, los puntos de nivel y las transiciones automáticas tienen sentido de lectura | La barra se vacía hacia el **inicio** del sentido de lectura; los puntos de nivel se ordenan de inicio a fin; las transiciones se deslizan según la dirección |
| Plurales | El árabe tiene **6 formas** (cero, uno, dos, pocos, muchos, otros) frente a 2 en español | El formato ICU de los ARB las admite; el traductor debe completarlas todas |
| Números | Se podrían mostrar con cifras arábigo-índicas | Con HU-001 casi no se muestran números (la barra de tiempo no lleva cifras); se usan las cifras del locale |
| Traducción | Necesita una persona nativa que revise el tono infantil | Igual que el resto de idiomas (P5) |
| Tienda | Ficha en árabe, capturas en RTL | En HU-014 |

### Reglas RTL (pasan a la sección 4 de la especificación al implementar)

- Usar **APIs direccionales**: `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`, `TextAlign.start`/`end`. Nunca `left`/`right` para elementos con sentido de lectura.
- Los iconos con dirección (flechas, «siguiente») DEBEN invertirse en RTL.
- Cada pantalla tiene un test de layout en `ar` (RTL) además de los de LTR.

**Si en la implementación apareciera un bloqueo** (por ejemplo, un comportamiento que no se pueda invertir), el árabe se aplaza a un hito posterior sin afectar al resto de idiomas, y se deja la nota aquí.

## 8. Preguntas abiertas

| # | Pregunta | Estado |
|---|---|---|
| P1 | Idiomas iniciales | ✅ Decidido: los 9 de la sección 6 |
| P2 | Idioma por defecto | ✅ Decidido: inglés (EE. UU.) |
| P3 | ¿El nombre «ToddlerLogic» se traduce? | ✅ Decidido: **no**. Es una marca y se muestra igual en todos los idiomas (sección 5) |
| P4 | Español neutro o con variantes | ✅ Confirmado: un solo español neutro; la app tiene pocos textos y la mayoría serán de configuración |
| P5 | ¿Quién traduce? | ✅ Decidido: esta historia crea **la base de los 9 idiomas** (catálogo completo con borradores de traducción) y **revisores externos** revisan todas las traducciones. Cada ARB se marca como «borrador» hasta su revisión (sección 12) |

## 9. Criterios de aceptación (borrador)

1. **Dado** el código de `lib/`, **entonces** ningún widget muestra un texto literal; un test o una revisión automática lo comprueba (herramienta a definir al implementar).
2. **Dado** un teléfono en cualquiera de los 9 idiomas que abre la app por primera vez, **entonces** toda la app está en ese idioma y el idioma queda guardado.
3. **Dado** un teléfono en un idioma no soportado, **entonces** la app se muestra en inglés.
4. **Dado** un teléfono en `pt_PT`, `es_MX` o `es_ES`, **entonces** la app usa `pt_BR` o `es` respectivamente.
5. **Dado** que el idioma quedó guardado, **cuando** cambio el idioma del teléfono y reabro la app, **entonces** la app mantiene el idioma guardado.
6. **Dado** cada idioma soportado, **entonces** todas las claves del catálogo tienen traducción, incluidas todas las formas plurales (test de paridad).
7. **Dado** cada idioma soportado, **entonces** el menú y el juego se ven sin overflow en vertical y horizontal en los tamaños de referencia.
8. **Dado** el árabe, **entonces** la app se muestra de derecha a izquierda, las flechas apuntan en el sentido de lectura y no hay overflow.
9. **Dado** el lector de pantalla activado, **entonces** las etiquetas de las cartas se leen en el idioma de la app.
10. **Dado** el icono de la app en el teléfono, **entonces** muestra el nombre definido en los recursos de Android del idioma del sistema.

## 10. Impacto técnico

| Área | Cambio |
|---|---|
| Dependencias | `flutter_localizations` (SDK) e `intl`; `generate: true` en `pubspec.yaml`; `l10n.yaml` con `app_en.arb` como plantilla |
| Dominio y datos | `UserProfile.languageCode` (`@HiveField(2)`, opcional) y regla de resolución del idioma (lógica pura y testeable) |
| Presentación | `MaterialApp` con `localizationsDelegates`, `supportedLocales`, `locale` y `onGenerateTitle`; los 22 textos y las 2 etiquetas pasan al catálogo |
| Android | `res/values*/strings.xml` con `app_name` para los 9 idiomas; el manifiesto usa `@string/app_name` |
| Tests | Los tests que buscan textos fijan el idioma explícitamente; tests de resolución del idioma, de paridad del catálogo y de layout por idioma (incluido `ar` en RTL) |
| Especificación | D-015 sustituida por una decisión nueva de multiidioma; reglas «sin textos fijos» y «RTL» en la sección 4 |

## 11. Fuera de alcance

- El selector de idioma en la Zona de Padres (HU-012).
- Traducir la ficha de la tienda (HU-014).
- La preferencia de idioma por app de Android 13 (*per-app language*): se evaluará en HU-012.
- Hebreo y otros idiomas RTL: la base RTL que deja esta historia los facilitará, pero no se incluyen.

## 12. Base de traducciones y revisión externa

- **Base completa:** los 9 ARB se crean con **todas** las claves. `app_en.arb` es la plantilla; el resto llevan borradores de traducción generados en el desarrollo.
- **Contexto para los revisores:** cada clave de la plantilla lleva su metadato `@clave` con `description` (dónde aparece y quién lo lee: niño o adulto) y, si aplica, la longitud máxima recomendada y los `placeholders` explicados. Sin contexto, un traductor externo no puede elegir bien el tono ni la longitud.
- **Seguimiento de la revisión:** `docs/i18n/REVISION.md` registra por idioma el estado (*borrador* → *en revisión* → *revisado*), el revisor y la fecha. Ningún idioma se anuncia en la ficha de la tienda (HU-014) hasta estar *revisado*.
- **Entrega a los revisores:** se les envían los ARB (JSON legible) o una exportación a hoja de cálculo con columnas clave, contexto, inglés, traducción. Sus correcciones vuelven por PR, y el CI comprueba la paridad de claves y plurales.
