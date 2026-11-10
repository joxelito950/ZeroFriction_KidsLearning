# HU-032 · Enviar comentarios desde la Zona de padres

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-09; preguntas en la sección 8) |
| **Épica** | E2 · Zona de padres |
| **Prioridad** | P2: conviene en la primera actualización de la prueba cerrada |
| **Tamaño** | S (estimación: 1 día) |
| **Depende de** | HU-004 (Zona de padres, hecha) y HU-014 (correo de contacto y política de privacidad, hechos) |

## 1. Historia

**Como** madre, padre o tester de la prueba cerrada,
**quiero** escribir al equipo desde la propia app, con los datos técnicos ya puestos,
**para** contar un fallo o una idea en un minuto, sin buscar la dirección ni saber qué versión tengo.

## 2. Situación actual

- La única forma de contactar es el correo `toddler.logic.app@outlook.com`, que aparece en la ficha de Google Play y en la política de privacidad. Desde la app no se llega a él.
- La app **no tiene red ni permisos** (`tool/check_release_permissions.dart`) y declara en Google Play que **no recopila ni comparte datos** (HU-014, sección «Seguridad de los datos»). Esta historia no puede cambiar eso.
- La Zona de padres ya tiene secciones en tarjetas (idioma, juegos, tiempo diario, fijar pantalla y privacidad) y está tras el control para adultos (D-029).
- En la prueba cerrada, Google Play deja que los testers envíen comentarios privados desde la ficha, pero sin datos técnicos y poca gente lo encuentra.

## 3. Comportamiento propuesto

- Nueva tarjeta **«Ayuda y comentarios»** en la Zona de padres, justo antes de «Privacidad» (P3).
- Un botón **«Enviar comentarios»** abre la app de correo del teléfono con un correo **ya preparado, sin enviar**:
  - **Para:** `toddler.logic.app@outlook.com`.
  - **Asunto:** «ToddlerLogic · Comentarios (1.0.0-rc.2+3)», en el idioma de la app.
  - **Cuerpo:** unas líneas guía («¿Qué pasó?», «¿Qué esperabas?») y, al final, los datos técnicos (P2): versión de la app, versión de Android, modelo del teléfono e idioma de la app.
- El adulto **lo lee, lo cambia o lo borra** y decide si lo manda. La app no envía nada por su cuenta: quien envía es la app de correo, por decisión del adulto.
- Si el teléfono no tiene app de correo, la tarjeta muestra la dirección con un botón **«Copiar»** y un aviso breve de que se copió (P5).

## 4. Reglas

| # | Regla |
|---|---|
| R1 | La tarjeta solo existe en la Zona de padres, tras el control para adultos. Nada del juego lleva a ella (D-029, política de Familias). |
| R2 | El botón abre la app de correo con un enlace `mailto:`. La app **no** pide el permiso de internet ni ningún otro: `check_release_permissions` lo sigue vigilando. |
| R3 | El correo sale **sin enviar** y el adulto ve todo lo que contiene antes de mandarlo. No se añade nada oculto ni adjuntos. |
| R4 | Los datos técnicos son solo los de P2. Nada del niño: ni progreso, ni estrellas, ni tiempo de juego. |
| R5 | Asunto y textos guía en el idioma de la app (9 idiomas). Los datos técnicos, siempre en el mismo formato, para leerlos rápido. |
| R6 | Sin app de correo: se ve la dirección y se puede copiar (P5). Nunca un error a la vista. |
| R7 | Abrir la app de correo cuenta como salir de la app: el tiempo diario (HU-009) se pausa y la sesión de adulto **se cierra**, como hoy en cualquier paso a segundo plano (`AdultSessionGuard`). Al volver, el adulto está fuera de la Zona de padres: así un niño nunca encuentra la zona abierta. |
| R8 | La política de privacidad (es y en) explica que, si el adulto escribe, el equipo recibe su dirección de correo y lo que escriba, solo para responder, y que la app no envía nada sola (P6). |

## 5. Criterios de aceptación

1. **Dado** la Zona de padres, **entonces** veo la tarjeta «Ayuda y comentarios» antes de «Privacidad».
2. **Dado** un teléfono con app de correo, **cuando** toco «Enviar comentarios», **entonces** se abre un correo sin enviar a `toddler.logic.app@outlook.com` con el asunto, las líneas guía y los datos técnicos en el idioma de la app.
3. **Dado** un teléfono sin app de correo, **cuando** toco «Enviar comentarios», **entonces** veo la dirección y puedo copiarla, sin ningún error.
4. **Dado** el AAB de *release*, **entonces** no declara ningún permiso nuevo (`check_release_permissions`).
5. **Dado** el correo preparado, **entonces** no contiene nada del progreso del niño.
6. **Dado** los 9 idiomas, con el texto ampliado a 2,0 (TD-007), **entonces** la tarjeta se lee completa, sin recortes.
7. **Dado** el código, **entonces** no hay textos fijos (`no_hardcoded_texts_test`) ni colores fuera de la paleta (`palette_test`).
8. **Dado** la política de privacidad, **entonces** explica el correo de comentarios (R8) y el test de la política sigue pasando.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dependencias | `url_launcher` para abrir `mailto:`. Para los datos técnicos, `package_info_plus` (versión) y `device_info_plus` (modelo y Android), según P2. Ninguna añade permisos; se comprueba con `check_release_permissions` |
| Android | En `AndroidManifest.xml`, un bloque `<queries>` con `SENDTO` y `mailto` para saber si hay app de correo (Android 11+). No es un permiso |
| Dominio | `FeedbackEmail`: arma el `Uri` `mailto:` con asunto y cuerpo codificados, a partir de los datos técnicos y los textos traducidos. Dart puro y testeado |
| Presentación | `ParentsFeedbackSection` (tarjeta) y el respaldo de copiar la dirección |
| Catálogo | Título, descripción, botón, líneas guía, «Copiar» y «Dirección copiada» en los 9 idiomas |
| Documentos | Política de privacidad (es, en) y `docs/store/ficha.md` si cambia algo de la sección «Seguridad de los datos» |
| Tests | El `Uri` (codificación, idiomas, sin datos del niño), la tarjeta con y sin app de correo (lanzador simulado), diseño en 9 idiomas y la política |

## 7. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-029 (control para adultos) | La tarjeta queda dentro de la Zona de padres |
| D-033 (todo en el teléfono) | Sin cambios: la app sigue sin red. Lo que sale lo envía la app de correo, por decisión del adulto |
| HU-014 (Seguridad de los datos) | Se mantiene «No se recopilan datos» (P6). Se revisa al publicar esta versión |
| HU-009 (tiempo diario), HU-004 | Salir a la app de correo pausa el contador y cierra la sesión de adulto, como cualquier paso a segundo plano (R7) |

## 8. Preguntas y decisiones

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Correo preparado (`mailto:`) o un formulario dentro de la app? | **Correo preparado.** Un formulario necesitaría red, un servidor y declarar datos en Google Play. Con el correo, la app sigue sin red y el adulto ve lo que manda | Sí |
| P2 | ¿Qué datos técnicos se añaden? | **Versión de la app, versión de Android, modelo del teléfono e idioma de la app.** Son los que más ayudan a reproducir un fallo y no identifican a nadie. Alternativa mínima, sin `device_info_plus`: solo versión de la app y de Android | Sí |
| P3 | ¿Dónde va la tarjeta? | **Antes de «Privacidad»**, al final de la Zona de padres: es lo que se usa menos y no estorba a los ajustes | No |
| P4 | ¿Solo durante la prueba cerrada o para siempre? | **Para siempre.** En producción también sirve, y Google Play ya muestra el mismo correo en la ficha | No |
| P5 | ¿Qué pasa sin app de correo? | **Se ve la dirección con un botón «Copiar».** Pasa en teléfonos sin Gmail ni Outlook configurados | No |
| P6 | ¿Cambia la declaración de «Seguridad de los datos»? | **No debería**: según la guía de Google, recopilar es que *la app* envíe datos fuera del teléfono, y aquí los envía la app de correo cuando el adulto decide. Aun así, la política de privacidad lo explica (R8) para ser transparentes. Se vuelve a revisar el formulario al publicar | No |
| P7 | ¿Textos guía en el cuerpo del correo? | **Sí, dos líneas** («¿Qué pasó?», «¿Qué esperabas?»): los testers no saben qué contar y así llegan informes útiles | No |

## 9. Fuera de alcance

- Formularios, encuestas o valoraciones dentro de la app.
- Enviar registros, capturas o el progreso del niño.
- Pedir valoración en Google Play (sería otra historia, y en apps para niños tiene sus propias reglas).
