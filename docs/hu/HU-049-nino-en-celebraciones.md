# HU-049 · El niño de la identidad en las celebraciones y en la invitación a jugar

| | |
|---|---|
| **Estado** | **Desarrollada** (2026-11-17, rama `feature/hu-048-049-medals-and-child`); falta verla en el moto g55 |
| **Épica** | E6 · Identidad (HU-013, HU-017) |
| **Prioridad** | **P1** |
| **Tamaño** | S (1 día) |
| **Depende de** | Las ilustraciones ya están en la app (`assets/brand/child_*.png`, 2026-11-16). HU-048 (la medalla que se pinta sobre el pecho) |

## 1. Historia

**Como** niño o niña que juega,
**quiero** ver al niño de la app celebrando conmigo cuando gano una medalla, e invitándome a jugar cuando termino el tutorial,
**para** sentir que el juego me acompaña, en lugar de ver un icono genérico.

## 2. Problema (visto en el moto g55)

Las ilustraciones de PROMPTS §13 (celebrando) y §14 (invitando) **se añadieron a la app pero no se conectaron a ninguna pantalla** (se dejó para su historia):

- La **celebración de medalla** (`MemoryCelebration` con `medal`) muestra el icono del sistema `military_tech`.
- La **invitación a jugar** tras el tutorial (`PlayInvitation`, HU-037 R9) muestra la **mano del sistema** (`touch_app`).

## 3. Propuesta

### 3.1 Celebración de medalla (Fácil, Normal, Reto máximo)

- La tarjeta de celebración muestra al **niño celebrando entre confeti** (`BrandAssets.childCelebrating`) en lugar del icono.
- **La medalla de la ronda** (`MedalBadge`, HU-048) se pinta **sobre el hueco del pecho** del niño (la ilustración lo trae transparente para eso), con su color y sus estrellas.
- Entrada suave: el niño aparece con un pequeño salto y la medalla «cae» en su sitio (unos 600 ms, sin bucles, D-022).
- Las celebraciones de nivel sin medalla siguen como hoy (copa y estrellas): el niño se reserva para las medallas, para que sean especiales.

### 3.2 Invitación a jugar (después del tutorial)

- `PlayInvitation` muestra al **niño invitando** (`BrandAssets.childInviting`) en lugar de la mano del sistema, con el título «¡Ahora, a jugar!» debajo.
- En árabe (RTL) la imagen se **refleja**, para que señale hacia el lado del contenido.

### 3.3 Tamaño

- La imagen ocupa hasta 180 dp y se reduce con la tarjeta si no cabe (la tarjeta ya se reduce en horizontal, revisión v2 del 2026-11-16).

## 4. Criterios de aceptación

1. Al ganar la medalla de bronce, plata u oro, se ve el niño celebrando con la medalla del color de la ronda sobre el pecho.
2. Al superar el tutorial, se ve el niño invitando; no aparece el icono `touch_app`.
3. El hueco del pecho queda cubierto por la medalla en los tres tamaños de tarjeta (test de posición: la medalla cubre el hueco medido en la ilustración).
4. Los avisos siguen cabiendo en 9 idiomas × 4 teléfonos × texto 1,0 y 2,0 (test de diseño de avisos).
5. Visto en el moto g55 en vertical y en horizontal.

## 5. Impacto técnico

| Capa | Cambio |
|---|---|
| Presentación | `memory_round_overlay.dart`: `MemoryCelebration` con medalla usa la ilustración y `MedalBadge` en una `Stack` (posición del hueco en fracciones del lienzo, medida en la fuente); `PlayInvitation` usa `childInviting` con `Transform.flip` en RTL |
| Tests | Imagen y medalla en la celebración, imagen en la invitación, posición de la medalla, diseño de avisos |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿El niño también en las celebraciones de nivel (sin medalla)? | ✅ Decidido (2026-11-17): **no**: se reserva para las medallas, que así se sienten más especiales |
| P2 | ¿Se usa al niño durmiendo (§12) ya, en la pantalla de descanso de noche? | ✅ Decidido (2026-11-17): **no**: llega con HU-038 (hora de dormir) |

## 7. Desarrollo (2026-11-17)

- `CelebratingChild`: la ilustración del niño celebrando (180 dp de alto) con la `MedalBadge` de la ronda colocada sobre el hueco del pecho. El hueco se midió en la imagen (centro en el 53,9 % del ancho y el 53,4 % del alto; radio del 9,5 % del ancho) y el disco de la medalla lo tapa con un 15 % de margen.
- Solo en las celebraciones de medalla; las de nivel siguen con la copa (P1). Sin la animación de entrada de la sección 3.1, que queda para cuando se vea en el teléfono.
- `PlayInvitation` muestra al niño invitando en lugar de `touch_app`, reflejado en árabe.
- Tests: imagen y medalla por ronda, la medalla cubre el hueco, la copa en las celebraciones de nivel, el niño en la invitación y su reflejo en RTL.

