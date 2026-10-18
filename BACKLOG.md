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
| **E3 · Premium y monetización** | Contenido premium, pago único y restauración |
| **E4 · Nuevos juegos** | Módulos 2 y 3 del MVP |
| **E5 · Plataforma y calidad** | Cierre de la beta técnica y preparación para publicar |
| **E6 · Publicación y distribución** | Identidad de la app (icono, ficha), primera publicación y llegada a otras tiendas |

## Historias de usuario

| ID | Título | Épica | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|---|
| [HU-001](docs/hu/HU-001-memoria-progresiva.md) | Memoria progresiva con tiempo e insignia dorada | E1 | Lista | P1 | L (5 entregas) | Refinamiento cerrado el 2026-10-16 y supuestos confirmados el 2026-10-17; decisiones D-020 a D-025. |
| HU-002 | Mostrar el progreso del niño en el menú | E1 | Idea | P3 | S | HU-001 ya cubre el dorado por juego superado (D-023). Revisar si hace falta algo más, por ejemplo el nivel actual en el menú. |
| HU-003 | Temática Dinosaurios (Premium) con candado | E1, E3 | Idea | P3 | M | Con HU-001 sería una temática más del catálogo aleatorio, disponible solo con Premium. Depende de HU-006. |
| HU-004 | Gatekeeper de la Zona de Padres | E2 | Idea | P2 | M | Desafío lógico o matemático para adultos. Requisito previo de HU-005, HU-006 y HU-009. |
| HU-005 | Ajustes: sonido y dificultad | E2 | Idea | P3 | M | La app todavía no tiene audio. `isSoundEnabled` ya se persiste. |
| HU-006 | Pago único con Google Play Billing y restauración | E3 | Idea | P3 | L | Añadirá el permiso `BILLING` (D-017). Requiere HU-004 y TD-003. Diseñar las compras detrás de una interfaz, para poder añadir los sistemas de pago de otras tiendas (HU-015). |
| HU-007 | Shadow Matching (arrastrar a la silueta) | E4 | Idea | P3 | L | Módulo 2 del MVP. |
| HU-008 | Clasificación por tamaño | E4 | Idea | P3 | L | Módulo 3 del MVP. |
| HU-009 | Control de tiempo diario y límite de sesiones | E2 | Idea | P3 | M | Del dominio «Gestión Parental» del README. Incluir «Fijar pantalla» de Android: primero como instrucciones para los padres y más adelante, si se quiere, un botón que la inicie (Android siempre pide confirmación; requiere código nativo). |
| HU-010 | Configurar el tablero y los tiempos de inicio del juego de memoria | E2 | Idea | P3 | S | Desde la Zona de Padres, una vez superado el juego (insignia de HU-001). Depende de HU-001 y HU-004. Por refinar: si se configura por juego y qué rangos se permiten. |
| [HU-011](docs/hu/HU-011-multiidioma.md) | Multiidioma: textos desde un catálogo e idioma del sistema en el primer arranque | E5 | En refinamiento | P1 | M | **Antes de HU-001**, para que sus textos nuevos nazcan en el catálogo. Sustituye D-015. Preguntas abiertas: idiomas iniciales, idioma por defecto y si se traduce la marca. |
| HU-012 | Selector de idioma en la Zona de Padres | E2 | Idea | P2 | S | Depende de HU-004 y HU-011. Evaluar también la preferencia de idioma por app de Android 13. |
| HU-013 | Identidad visual: icono de la app, mascota e iconos de los juegos | E6 | Idea | P2 | M | Icono adaptativo de Android (fondo + primer plano; con `minSdk` 26 basta con el adaptativo), versión monocroma para los iconos temáticos de Android 13 e icono de 512 × 512 para la tienda. Incluye la mascota del menú y el icono de cada juego (retirados en TD-006); todo emoji que se use debe ser de Emoji 5.0 o anterior (D-026). Requiere un diseño. |
| HU-014 | Primera publicación en Google Play | E6 | Idea | P2 | L | Requisitos previos: TD-003 (firma), HU-013 (icono), política de privacidad publicada (obligatoria para apps infantiles), formularios de Seguridad de los datos y clasificación de contenido, programa «Diseñado para familias», ficha con capturas por idioma (HU-011) y formato AAB. Las cuentas **personales** nuevas deben pasar una **prueba cerrada con al menos 12 testers durante 14 días seguidos** antes de producción (si bajan de 12, se reinicia); las cuentas de **organización** están exentas pero requieren número D-U-N-S. Por decidir: tipo de cuenta, y si se publica gratis antes de tener Premium (HU-006). |
| HU-015 | Publicación en otras tiendas Android | E6 | Idea | P3 | L | Candidatas: Huawei AppGallery, Samsung Galaxy Store y Amazon Appstore (desde agosto de 2025 solo en tablets Fire y Fire TV; interesante por Amazon Kids). Más adelante, Apple App Store (requiere TD-005, un Mac o CI en la nube y una cuota anual). La app no usa servicios de Google, así que funciona en todas; el **pago** es lo que cambia, porque cada tienda tiene su propio sistema de compras. Requiere abstraer las compras por tienda en HU-006. |

## Deuda técnica y plataforma

| ID | Título | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|
| [TD-001](docs/td/TD-001-ci-github-actions.md) | CI con GitHub Actions (checklist de la sección 5) | Hecha | P1 | S | Hace automáticas las reglas de la especificación (D-016). Incluye la regla de protección de ramas, que el dueño del repo configura a mano en GitHub. |
| [TD-002](docs/td/TD-002-migracion-hive-ce.md) | Migrar `hive`/`hive_generator` a `hive_ce` | En refinamiento | P1 | S | Conviene hacerla **antes** que HU-001, porque HU-001 añade un tipo nuevo a Hive (typeId 2) (D-014). |
| TD-003 | Keystore de release y firma | Idea | P2 | S | Bloquea la publicación en Google Play (D-019). |
| TD-004 | Separar los modelos de persistencia del dominio | Idea | P3 | M | Deuda aceptada D-012; antes de la 1.0. |
| TD-005 | Generar la plataforma iOS | Idea | P3 | S | Cuando se decida publicar en iOS. |
| TD-006 | Retirar los iconos del menú hasta definir la identidad visual | En curso (falta verificar en dispositivo) | P1 | S | Decisión del 2026-10-18: la mascota 🧸 (Emoji 11.0, no se ve en Android 8, D-026) y los iconos de los juegos (🚜, 🌴) se deciden más adelante junto con el icono de la app (HU-013). **Por ahora el menú no usa iconos.** Se hace después de TD-001, en su propio PR. |

## Orden propuesto

1. **TD-001**, **TD-002** y **TD-006**: dejan la base estable antes de añadir persistencia y textos nuevos.
2. **HU-011** (multiidioma): antes de HU-001, para no traducir dos veces.
3. **HU-001**: ya está `Lista`. Se desarrolla en 5 entregas; la 2 (persistencia) después de TD-002.
4. **HU-004** y HU-012; luego HU-013, TD-003 y **HU-014** (primera publicación).
5. Después: HU-002 y HU-005, E3 (HU-006, HU-003), HU-015 (otras tiendas) y E4 (HU-007, HU-008).
