# HU-022 · Tutorial visual: una mano animada enseña el gesto

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-03) |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: va antes de HU-007 (decidido el 2026-10-29, HU-007 P1) |
| **Tamaño** | M (estimación previa) |
| **Depende de** | Nada. La usan el juego de memoria (desde esta historia) y Sombras (HU-007) |

## 1. Historia

**Como** niño o niña de 3 años que todavía no lee,
**quiero** ver una mano que me enseña qué tengo que hacer,
**para** poder jugar sin que un adulto me lo explique.

## 2. Situación actual

- La app es visual y sin narración (D-034): ninguna voz explica los juegos.
- El juego de memoria se entiende casi solo (tocar cartas), pero muestra instrucciones **escritas** en la cabecera, que el niño no lee.
- Sombras (HU-007) introduce un gesto nuevo, **arrastrar**, que un niño de 3 años no descubre solo con facilidad.

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | Un **componente común**: una mano dibujada que repite el gesto del juego sobre el tablero. Cada juego le dice qué gesto y dónde: tocar una carta (memoria) o llevar un objeto hasta su sombra (Sombras). |
| R2 | **Cuándo aparece:** al empezar un tablero, si el niño no ha tocado nada en **4 s**; se repite cada **8 s** mientras siga sin tocar (P1). |
| R3 | **Cuándo desaparece:** al primer toque en cualquier parte, con un fundido corto. Después de ese toque **no vuelve** en ese tablero: si el niño ya juega, está pensando, no perdido (P2). |
| R4 | **No interfiere:** la mano no captura toques (`IgnorePointer`), no tapa el elemento que señala y **no cambia el juego**: en la memoria toca una carta **sin darle la vuelta**; en Sombras lleva una copia transparente del objeto, que vuelve a su sitio. |
| R5 | **Sin tiempo:** en los tableros con tiempo, el cronómetro sigue arrancando con el primer toque del niño (HU-001 R10), así que la mano nunca le quita tiempo. |
| R6 | **Sin texto ni sonido.** Solo la mano y un círculo que marca el toque. |
| R7 | **Movimiento reducido:** si el sistema pide reducir las animaciones (`MediaQuery.disableAnimations`), la mano aparece quieta sobre el objetivo, sin desplazarse. |
| R8 | **Colores:** mano en teal profundo con contorno blanco y círculo del toque en ámbar, con transparencia (paleta, D-032). |
| R9 | **Sin guardar nada:** no hace falta recordar si el tutorial ya se vio, porque solo aparece cuando el niño no toca nada (P3). |

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-034 | Es la forma de enseñar sin narración |
| D-022 | Sin botones: la mano no se toca ni se cierra; se va sola |
| D-021, HU-001 R10 | El tiempo no corre mientras se muestra (R5) |
| D-032 | Solo colores de la paleta (R8) |
| HU-007 | Sombras la usa desde su primera versión |
| TD-007 | No tiene texto, así que el texto ampliado no la afecta |

## 5. Criterios de aceptación (borrador)

1. **Dado** un tablero nuevo, **cuando** pasan 4 s sin tocar, **entonces** aparece la mano haciendo el gesto del juego y se repite cada 8 s.
2. **Dado** que la mano está visible, **cuando** el niño toca cualquier parte, **entonces** la mano desaparece y el toque llega al juego como si no estuviera.
3. **Dado** que el niño ya tocó en este tablero, **entonces** la mano no vuelve a aparecer hasta el siguiente tablero.
4. **Dado** el juego de memoria, **entonces** la mano toca una carta sin darle la vuelta, y en los tableros con tiempo la barra no empieza a vaciarse.
5. **Dado** el sistema con las animaciones reducidas, **entonces** la mano aparece quieta.
6. **Dado** el código, **entonces** solo usa colores de la paleta y ningún texto.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Presentación | `GestureHint` (widget común): recibe el gesto (`tap` o `drag`), el origen y el destino; gestiona los temporizadores de R2–R3 y la animación |
| Juego de memoria | Superpone `GestureHint` sobre el tablero, apuntando a una carta al azar |
| Recursos | La mano: icono de Material (`Icons.touch_app`) o un vector propio (P4) |
| Tests | Temporizadores (aparece a los 4 s, se repite, desaparece y no vuelve), toques que pasan a través, cronómetro sin arrancar, movimiento reducido, paleta |

## 7. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Cuánto esperar antes de mostrar la mano y cada cuánto repetirla? | 4 s y 8 s; se ajustan viendo jugar al niño en el moto g55 | No |
| P2 | ¿Vuelve la mano si el niño se queda quieto **después** de empezar a jugar? | **No:** a mitad de tablero suele estar pensando; una mano señalando una carta le daría la respuesta en la memoria | Sí |
| P3 | ¿Se recuerda que el tutorial ya se vio, para no mostrarlo nunca más? | **No:** solo aparece si el niño no toca nada, así que a quien ya sabe jugar no le molesta, y no hay que añadir datos guardados | Sí |
| P4 | ¿La mano es el icono de Material o un dibujo propio? | **El icono de Material** por ahora; se sustituye por el de la identidad cuando HU-013 tenga su guía de estilo | No |
| P5 | ¿Se aplica también al juego de memoria? | **Sí:** el componente se prueba con un juego que ya existe antes de llegar a Sombras | Sí |

## 8. Fuera de alcance

- Narración o textos explicativos (D-034).
- Tutoriales para la Zona de Padres (es para adultos).
- Sombras en sí (HU-007).
