# Backlog · ToddlerLogic

Fuente de verdad del trabajo pendiente. El **qué** del producto está en [README.md](README.md) y el **cómo** en [SPECIFICATION.md](SPECIFICATION.md).

## Cómo se usa

- **IDs:** `HU-###` para historias de usuario (valor de producto) y `TD-###` para deuda técnica y plataforma. Un ID no se reutiliza nunca.
- **Estados:** `Idea` → `En refinamiento` → `Lista` → `En curso` → `Hecha` (o `Descartada`, con el motivo).
- **Prioridad:** `P1` es lo siguiente que se trabaja; `P2` va después; `P3` queda para más adelante.
- **Tamaño:** S (≤ 1 día), M (2–3 días), L (≥ 1 semana), según la estimación al refinar.
- Cada historia que pase a `En refinamiento` tiene su ficha en `docs/hu/`. La rama de trabajo usa el ID: `feature/hu-001-...`.

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

## Historias de usuario

| ID | Título | Épica | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|---|
| [HU-001](docs/hu/HU-001-memoria-progresiva.md) | Memoria progresiva con tiempo e insignia dorada | E1 | Lista | P1 | L (5 entregas) | Refinamiento cerrado el 2026-10-16 y supuestos confirmados el 2026-10-17; decisiones D-020 a D-025. |
| HU-002 | Mostrar el progreso del niño en el menú | E1 | Idea | P3 | S | HU-001 ya cubre el dorado por juego superado (D-023). Revisar si hace falta algo más, por ejemplo el nivel actual en el menú. |
| HU-003 | Temática Dinosaurios (Premium) con candado | E1, E3 | Idea | P3 | M | Con HU-001 sería una temática más del catálogo aleatorio, disponible solo con Premium. Depende de HU-006. |
| HU-004 | Gatekeeper de la Zona de Padres | E2 | Idea | P2 | M | Desafío lógico o matemático para adultos. Requisito previo de HU-005, HU-006 y HU-009. |
| HU-005 | Ajustes: sonido y dificultad | E2 | Idea | P3 | M | La app todavía no tiene audio. `isSoundEnabled` ya se persiste. |
| HU-006 | Pago único con Google Play Billing y restauración | E3 | Idea | P3 | L | Añadirá el permiso `BILLING` (D-017). Requiere HU-004 y TD-003. |
| HU-007 | Shadow Matching (arrastrar a la silueta) | E4 | Idea | P3 | L | Módulo 2 del MVP. |
| HU-008 | Clasificación por tamaño | E4 | Idea | P3 | L | Módulo 3 del MVP. |
| HU-009 | Control de tiempo diario y límite de sesiones | E2 | Idea | P3 | M | Del dominio «Gestión Parental» del README. Podría incluir activar «Fijar pantalla» de Android (los gestos de inicio y recientes no se pueden bloquear desde la app). |
| HU-010 | Configurar el tablero y los tiempos de inicio del juego de memoria | E2 | Idea | P3 | S | Desde la Zona de Padres, una vez superado el juego (insignia de HU-001). Depende de HU-001 y HU-004. Por refinar: si se configura por juego y qué rangos se permiten. |

## Deuda técnica y plataforma

| ID | Título | Estado | Prio | Tamaño | Notas |
|---|---|---|---|---|---|
| TD-001 | CI con GitHub Actions (checklist de la sección 5) | Idea | P1 | S | Hace automáticas las reglas de la especificación (D-016). |
| TD-002 | Migrar `hive`/`hive_generator` a `hive_ce` | Idea | P1 | S | Conviene hacerla **antes** que HU-001, porque HU-001 añade un tipo nuevo a Hive (typeId 2) (D-014). |
| TD-003 | Keystore de release y firma | Idea | P2 | S | Bloquea la publicación en Google Play (D-019). |
| TD-004 | Separar los modelos de persistencia del dominio | Idea | P3 | M | Deuda aceptada D-012; antes de la 1.0. |
| TD-005 | Generar la plataforma iOS | Idea | P3 | S | Cuando se decida publicar en iOS. |

## Orden propuesto

1. **TD-002** (y si es posible **TD-001**): dejan la base estable antes de añadir persistencia nueva.
2. **HU-001**: ya está `Lista`. Se desarrolla en 5 entregas; la 2 (persistencia) después de TD-002.
3. **HU-004**, luego HU-002 y HU-005, luego E3 (HU-006, HU-003) y E4 (HU-007, HU-008).
