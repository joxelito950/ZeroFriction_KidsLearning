# Backlog · ToddlerLogic

Fuente de verdad del trabajo pendiente. El **qué** del producto está en [README.md](README.md) y el **cómo** en [SPECIFICATION.md](SPECIFICATION.md).

## Cómo se usa

- **IDs:** `HU-###` para historias de usuario (valor de producto) y `TD-###` para deuda técnica y plataforma. Un ID no se reutiliza nunca.
- **Estados:** `Idea` → `En refinamiento` → `Lista` → `En curso` → `Hecha` (o `Descartada`, con el motivo).
- **Prioridad:** `P1` es lo siguiente que se trabaja; `P2` va después; `P3` queda para más adelante.
- **Tamaño:** S (≤ 1 día), M (2–3 días), L (≥ 1 semana), según la estimación al refinar.
- Cada elemento que pase a `En refinamiento` tiene su ficha: las historias en `docs/hu/` y la deuda técnica en `docs/td/`. La rama de trabajo usa el ID: `feature/hu-001-...`.

### Definición de «Lista» (puede empezar a desarrollarse)

- [ ] Ficha en `docs/hu/` con la historia, reglas y criterios de aceptación verificables.
- [ ] Preguntas abiertas resueltas o aplazadas de forma explícita.
- [ ] Conflictos con README o SPECIFICATION resueltos: si cambia una regla, la decisión está redactada para la sección 8 de la especificación.
- [ ] Impacto técnico identificado (archivos, persistencia, tests de layout necesarios).
- [ ] Si la historia tiene interfaz, indica qué colores de la **paleta** usa ([docs/brand/PALETA.md](docs/brand/PALETA.md), D-032). No se aceptan colores nuevos: si hiciera falta uno, primero se cambia la paleta con su propia decisión.
- [ ] Tamaño estimado.

### Definición de «Hecha»

- [ ] Todos los criterios de aceptación tienen test automatizado o, si no es posible, verificación manual documentada en el PR.
- [ ] Checklist de la sección 5 de la especificación en verde: `analyze` con 0 incidencias, todos los tests pasan y `tool/coverage_check.dart` OK.
- [ ] Probado en un dispositivo real o un emulador, en vertical y en horizontal.
- [ ] SPECIFICATION.md actualizada si cambió arquitectura, persistencia (typeIds) o alguna decisión.
- [ ] PR fusionado en `develop` y estado actualizado en este backlog.

---

## Épicas

| Épica | Objetivo |
|---|---|
| **E1 · Juego de memoria** | Módulo 1 del MVP completo, con progresión y recompensas |
| **E2 · Zona de Padres** | Gatekeeper para adultos, ajustes y control de uso |
| **E3 · Premium y monetización** | Pago único, restauración y contenido Premium de los juegos siguientes (el juego de memoria es gratuito, D-028) |
| **E4 · Nuevos juegos** | Módulos 2 y 3 del MVP |
| **E5 · Plataforma y calidad** | Cierre de la beta técnica y preparación para publicar |
| **E6 · Publicación y distribución** | Identidad de la app (icono, ficha), primera publicación y llegada a otras tiendas |

## Historias de usuario

| ID | Título | Épica | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|---|
| [HU-001](docs/hu/HU-001-memoria-progresiva.md) | Memoria progresiva con tiempo e insignia dorada | E1 | Hecha | P1 | L (5 entregas) | Refinamiento cerrado el 2026-10-16 y supuestos confirmados el 2026-10-17; decisiones D-020 a D-025. **100 % gratuito** (D-028). Incluye el cálculo y guardado de estrellas por nivel (D-030, para HU-002). |
| [HU-002](docs/hu/HU-002-progreso-dorado-y-estrellas.md) | Icono dorado progresivo y pérdida de logros | E1 | Lista | P3 | M | Refinamiento cerrado el 2026-10-21 (D-030, D-031): el icono se vuelve dorado según las estrellas y los logros se pierden poco a poco tras 7 días sin jugar. Las estrellas se calculan y guardan ya en HU-001. Dorado por llenado de abajo arriba (decidido en HU-013 el 2026-10-26); se desarrolla con HU-013 o después, porque necesita el icono del juego. |
| HU-003 | Temática Dinosaurios (Premium) con candado | E1, E3 | Descartada | — | — | 2026-10-20: el juego de memoria es 100 % gratuito (D-028). El contenido Premium llegará con los juegos siguientes. |
| [HU-004](docs/hu/HU-004-zona-de-padres.md) | Gatekeeper de la Zona de Padres | E2 | Hecha | P2 | M (3 entregas) | Fusionada el 2026-10-27 y verificada en el moto g55. Refinamiento cerrado el 2026-10-21 (D-029): doble toque, multiplicación en palabras con teclado barajado, sin penalizaciones, mínima exposición. Contenido básico: estructura e instrucciones de «Fijar pantalla». Requisito previo de HU-005, HU-006, HU-009, HU-010 y HU-012. |
| [HU-005](docs/hu/HU-005-sonido.md) | Sonidos suaves y ajuste de sonido | E2 | Lista | P3 | M | Refinamiento cerrado el 2026-10-27. Sonidos al voltear, al encontrar pareja y al completar un tablero; **nunca** ante un error ni con el tiempo agotado. Activado por defecto, interruptor en la Zona de Padres (`isSoundEnabled`). Sin música. Sonidos CC0 que propone el desarrollo y aprueba el dueño. Se retira la «dificultad» (la cubren HU-001 y HU-010). |
| HU-006 | Pago único con Google Play Billing y restauración | E3 | Idea | P3 | L | Añadirá el permiso `BILLING` (D-017). Requiere HU-004 y TD-003. Diseñar las compras detrás de una interfaz, para poder añadir los sistemas de pago de otras tiendas (HU-015). El candado y el contenido Premium aplican solo a los juegos siguientes (HU-007, HU-008), nunca al de memoria (D-028). |
| HU-007 | Shadow Matching: arrastrar objetos a su silueta | E4 | Idea | P3 | L | Módulo 2 del README (emparejamiento). Al refinar se decide su modelo de acceso: niveles gratis y Premium, o 100 % Premium (D-028). Depende de HU-006 si tiene contenido Premium. |
| HU-008 | Clasificación por tamaño: grande, mediano y pequeño | E4 | Idea | P3 | L | Módulo 3 del README (lógica): clasificar objetos en tres cestas. Al refinar se decide su modelo de acceso: niveles gratis y Premium, o 100 % Premium (D-028). Depende de HU-006 si tiene contenido Premium. |
| [HU-009](docs/hu/HU-009-tiempo-diario.md) | Tiempo de juego diario y descanso | E2 | Lista | P3 | M | Refinamiento cerrado el 2026-10-27. Primero recomienda los controles parentales del sistema (Bienestar digital, Family Link); para reforzarlos, leyenda de la OMS y límite diario: sin límite, 15–120 min o personalizado (5 min a 12 h). Termina el tablero en curso y muestra una pantalla de descanso; un adulto puede dar 15 min más. Entidad nueva `ParentalSettings` (typeId 3). El botón de «Fijar pantalla» pasa a HU-020. |
| [HU-010](docs/hu/HU-010-inicio-juego-memoria.md) | Configurar el punto de partida del juego de memoria | E2 | Lista | P3 | S | Refinamiento cerrado el 2026-10-27. Desde la Zona de Padres, **siempre disponible**: se elige uno de los 5 tableros y el tiempo sale de la tabla de HU-001. Se aplica en la próxima partida y tras cada insignia. Campo nuevo índice 5 en `MemoryProgressHiveModel`. |
| [HU-011](docs/hu/HU-011-multiidioma.md) | Multiidioma: textos desde un catálogo e idioma del sistema en el primer arranque | E5 | Hecha | P1 | L | Después de los pendientes técnicos y **antes de HU-001**. Sustituye D-015. 9 idiomas (inglés EE. UU. por defecto, español neutro, portugués de Brasil, alemán, japonés, francés, italiano, coreano y árabe RTL). La marca no se traduce. Se crea la base de los 9 idiomas; revisores externos revisan todas las traducciones. |
| [HU-012](docs/hu/HU-012-selector-de-idioma.md) | Selector de idioma en la Zona de Padres | E2 | Hecha | P2 | S | Desarrollada y verificada en el moto g55 el 2026-10-27. Refinamiento cerrado el 2026-10-26. Depende de HU-004 y HU-011. Cambio en caliente (incluido LTR ↔ RTL), nombres de cada idioma en su propio idioma y sin banderas. Sin opción «Idioma del teléfono» (D-027 se mantiene). El idioma por app de Android 13 se aplaza. |
| [HU-013](docs/hu/HU-013-identidad-visual.md) | Identidad visual: icono de la app, logo e iconos de los juegos | E6 | Lista | P2 | M | Refinamiento cerrado el 2026-10-26. Icono adaptativo de Android (fondo + primer plano; con `minSdk` 26 basta con el adaptativo), versión monocroma para los iconos temáticos de Android 13, icono de 512 × 512 para la tienda, logo encima del título del menú e icono del juego de memoria (retirados en TD-006). Identidad sin emojis, en vector (D-026). **Diseña el dueño del producto**; la integración empieza cuando estén los vectores. Dorado de HU-002 por llenado de abajo arriba. Sin mascota (HU-017).  **Paleta de colores fijada el 2026-10-27** (D-032, [PALETA.md](docs/brand/PALETA.md)): la identidad solo usa sus 7 colores. |
| [HU-014](docs/hu/HU-014-primera-publicacion-google-play.md) | Primera publicación en Google Play | E6 | Lista | P2 | L (5 entregas) | Refinamiento cerrado el 2026-10-27. Cuenta personal: prueba cerrada de 12 testers durante 14 días (el dueño reúne 15). `targetSdk` 36 ya cumple el requisito de agosto de 2026. Público «5 o menos» y «6–8», gratis (Premium después con HU-006), todos los países, ficha en español e inglés, política de privacidad en la app y en GitHub Pages. Las entregas 1 (preparación técnica) y 2 (privacidad) pueden empezar ya; las demás esperan a TD-003, HU-013 y los testers. |
| HU-015 | Publicación en otras tiendas Android | E6 | Idea | P3 | L | Candidatas: Huawei AppGallery, Samsung Galaxy Store y Amazon Appstore (desde agosto de 2025 solo en tablets Fire y Fire TV; interesante por Amazon Kids). Más adelante, Apple App Store (requiere TD-005, un Mac o CI en la nube y una cuota anual). La app no usa servicios de Google, así que funciona en todas; el **pago** es lo que cambia, porque cada tienda tiene su propio sistema de compras. Requiere abstraer las compras por tienda en HU-006. |
| [HU-016](docs/hu/HU-016-pausar-perdida-logros.md) | Activar o desactivar la pérdida de logros desde la Zona de Padres | E2 | Lista | P3 | S | Refinamiento cerrado el 2026-10-27. Interruptor **general** «Mantener las estrellas» (D-031 sigue activa por defecto); al volver a desactivarlo, la gracia de 7 días empieza de nuevo. Se desarrolla **junto con HU-002**. Comparte `ParentalSettings` con HU-009. |
| HU-017 | Mascota de la app | E6 | Idea | P3 | M | Separada de HU-013 el 2026-10-26: no es un requisito del producto (venía del 🧸 de la versión 0.0.1-beta) y es la pieza que más diseño exige. Si se hace: personaje original en vector, sin emojis (D-026), para el hueco del logo en el menú y las celebraciones; podría pasar a ser el icono de la app. Depende de HU-013 (guía de estilo). |
| HU-018 | Narración por voz de las instrucciones | E1 | Descartada | — | — | 2026-10-28 (D-034): la app es principalmente visual; los sonidos (HU-005) solo acompañan logros e interacciones, no guían al niño paso a paso. La accesibilidad para limitación visual la cubre el lector de pantalla del sistema (TalkBack). |
| HU-019 | Idioma por app de Android 13 | E2 | Idea | P3 | S | Aplazado al refinar HU-012 (P1): declarar `localeConfig` para que ToddlerLogic aparezca en *Ajustes › Idiomas de las apps*, sincronizando con el selector de la Zona de Padres mediante `LocaleManager` (código nativo). Retomar si la revisión de Google Play o los usuarios lo piden. |
| HU-020 | Botón para fijar la pantalla desde la Zona de Padres | E2 | Idea | P3 | M | Sacado de HU-009 (P6): iniciar «Fijar aplicaciones» desde la app (`startLockTask`, código nativo). Android siempre pide confirmación. Las instrucciones ya están en la Zona de Padres (HU-004). |
| [HU-021](docs/hu/HU-021-desafio-en-segundo-idioma.md) | El desafío de adultos también en un segundo idioma | E2 | Hecha | P2 | S | Desarrollada el 2026-10-28 y verificada en el moto g55 el 2026-10-29. Refinamiento cerrado el 2026-10-27. Detectado el mismo día: si la app está en un idioma que el adulto no lee, no entiende la pregunta del desafío y no puede entrar a cambiar el idioma (HU-012). Propuesta: debajo de la pregunta, la misma pregunta (números con palabras) en el primer idioma del teléfono distinto del de la app o, si no está entre los 9, en inglés; **siempre visible**; también en el aviso del menú y en el mensaje de fallo, e iconos en sus botones. Sin textos nuevos ni cambio de idioma automático (D-027). Conviene antes de la prueba cerrada de HU-014. |

## Deuda técnica y plataforma

| ID | Título | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|
| [TD-001](docs/td/TD-001-ci-github-actions.md) | CI con GitHub Actions (checklist de la sección 5) | Hecha | P1 | S | Hace automáticas las reglas de la especificación (D-016). Incluye la regla de protección de ramas, que el dueño del repo configura a mano en GitHub. |
| [TD-002](docs/td/TD-002-migracion-hive-ce.md) | Migrar `hive`/`hive_generator` a `hive_ce` | Hecha | P1 | S | Conviene hacerla **antes** que HU-001, porque HU-001 añade un tipo nuevo a Hive (typeId 2) (D-014). |
| [TD-003](docs/td/TD-003-firma-release.md) | Keystore de release y firma | Lista | P1 | S | Bloquea la publicación en Google Play (D-019). Cuenta **personal**; el keystore lo genera el dueño siguiendo la guía paso a paso de la ficha, fuera del repo, con Play App Signing. |
| [TD-004](docs/td/TD-004-separar-modelos-persistencia.md) | Separar los modelos de persistencia del dominio | Hecha | P1 | M | Deuda aceptada D-012. Decisión del 2026-10-19: todos los pendientes técnicos se terminan antes de empezar las historias de usuario. |
| TD-005 | Generar la plataforma iOS | Idea | P3 | S | Cuando se decida publicar en iOS. |
| TD-006 | Retirar los iconos del menú hasta definir la identidad visual | Hecha | P1 | S | Decisión del 2026-10-18: la mascota 🧸 (Emoji 11.0, no se ve en Android 8, D-026) y los iconos de los juegos (🚜, 🌴) se deciden más adelante junto con el icono de la app (HU-013). **Por ahora el menú no usa iconos.** Se hace después de TD-001, en su propio PR. |
| [TD-007](docs/td/TD-007-texto-ampliado.md) | La app con el texto ampliado del sistema | Lista | P2 | S | Refinamiento cerrado el 2026-10-28. Medido el mismo día con los tests de diseño a escala 1,3 y 2,0: a 1,3 solo fallan los tableros en el teléfono compacto en vertical (árabe, francés, portugués); a 2,0 fallan casi todos los tableros y, en el desafío, el recuadro de la respuesta queda fuera de la vista. Propuesta: pantallas de adultos hasta 2,0, el juego limitado a 1,3 y los símbolos de las cartas sin escalar. Conviene antes de HU-014 (capturas y revisión). |
| [TD-008](docs/td/TD-008-sin-copia-de-seguridad.md) | Desactivar la copia de seguridad automática de Android | Hecha | P1 | S | Decidido el 2026-10-28 (D-033): sin copia en la nube ni transferencia entre teléfonos (`allowBackup="false"` y `dataExtractionRules` que lo excluyen todo). La copia depende del fabricante (Google, Huawei, Samsung), no de la tienda, y no se puede garantizar igual en todos. El progreso se queda solo en el teléfono, como dirán la política de privacidad y el formulario de HU-014. Lo vigila un test de arquitectura. |
| [TD-009](docs/td/TD-009-aplicar-paleta.md) | Aplicar la paleta de colores e impedir colores fuera de ella | Hecha | P1 | M | Desarrollada el 2026-10-27 (revisada en el emulador; falta el moto g55). D-032. Sustituye los 36 colores literales, los `Colors.*` y el tema generado desde la semilla `#98FFD9` (D-005) por `AppPalette`, y añade `test/architecture/palette_test.dart` para que el CI rechace cualquier color fuera de la paleta. No depende de HU-013. Conviene antes de las capturas de HU-014 y de las historias con interfaz nueva. |
| TD-010 | Diseño en tablets y pantallas grandes | Idea | P2 | M | Detectado el 2026-10-28: los tests de diseño solo cubren dos teléfonos. Muchos niños juegan en tablets (y Amazon Appstore, HU-015, hoy solo llega a tablets Fire). Añadir tamaños de tablet de 7" y 10" en vertical y horizontal, revisar que las cartas no se vuelvan enormes ni el menú quede perdido en el centro, y decidir si se suben capturas de tablet a Google Play (HU-014). |

## Orden propuesto

1. **Pendientes técnicos primero** (decisión del 2026-10-19): TD-001, TD-002, TD-004 y TD-006 ✅ hechas; queda **TD-003** (firma; la clave la genera el dueño con la guía de la ficha). TD-005 (iOS) queda para cuando se decida publicar en iOS.
2. **HU-011** (multiidioma) ✅ hecha; traducciones pendientes de revisión externa (`docs/i18n/REVISION.md`).
3. **HU-001** ✅ hecha (5 entregas, verificada en vertical y horizontal el 2026-10-26).
4. **HU-004** ✅ hecha (verificada en el moto g55 el 2026-10-27). **HU-012** (idioma) ✅ hecha. **TD-009** (aplicar la paleta, D-032) ✅ hecha: el CI rechaza cualquier color fuera de la paleta. **TD-008** ✅ hecha (sin copia de seguridad, D-033). Antes de las entregas 1 y 2 de **HU-014**, hacer **TD-007** (texto ampliado); después, HU-014 entregas 1 y 2, que no esperan a nadie; en paralelo, HU-013 en cuanto estén los vectores (y con ella HU-002); el resto de HU-014 cuando estén TD-003, HU-013 y los 15 testers. HU-010 (P3, S) puede colarse cuando convenga.
5. Después, ya refinadas: HU-010, HU-005 y HU-009 (en este orden propuesto: de menor a mayor tamaño), y HU-002 con HU-016 cuando esté HU-013. Luego E3 (HU-006), HU-015 (otras tiendas) y E4 (HU-007, HU-008), cada juego con su modelo de acceso (D-028). Ideas sin refinar: HU-017, HU-019 y HU-020 (HU-018 descartada, D-034). **HU-021** (desafío en un segundo idioma) ✅ hecha.
