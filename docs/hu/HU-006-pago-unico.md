# HU-006 · Pago único (Premium) con Google Play Billing y restauración

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-06; preguntas en la sección 8) |
| **Épica** | E3 · Premium y monetización |
| **Prioridad** | P2: sin ella, todo lo Premium queda bloqueado en la versión publicada |
| **Tamaño** | L (estimación: 1–1,5 semanas, sin contar la espera de Google para probar compras) |
| **Depende de** | HU-004 (Zona de Padres, hecha), TD-003 (firma, hecha) y HU-014 (la app tiene que estar subida a un canal de prueba para que Google Play deje probar compras) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** desbloquear Premium con un solo pago y recuperarlo si cambio de teléfono,
**para** que mi hijo tenga todo el contenido sin suscripciones, sin anuncios y sin que él pueda comprar nada.

## 2. Situación actual

- `UserProfile.isPremium` existe desde la versión 0.0.1, pero nada lo cambia: en las versiones publicadas es siempre `false`.
- Ya dependen de Premium: el ajuste «Jugar sin tiempo» (HU-030 R4, gratuito de ver, Premium para cambiar) y, cuando se desarrolle, Sombras: tiempo, nivel 8, 3.ª estrella, dorado al 100 % y medalla (HU-007, D-028).
- Al perder Premium, los ajustes Premium vuelven a su valor por defecto (HU-030 R11).
- El juego de memoria es 100 % gratuito (D-028).
- D-017 ya prevé Google Play Billing y el permiso `com.android.vending.BILLING`, la única excepción a «cero permisos» (SPECIFICATION 4.4).
- La política de privacidad dice que la app no tiene compras y que se actualizará antes de añadirlas.

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | **Un único producto** no consumible, «Premium» (P2), comprado una vez y para siempre. Sin suscripciones ni compras dentro de los juegos. |
| R2 | **La compra solo existe en la Zona de Padres**, tras el control para adultos (D-029, política de Familias). Ni el menú ni los juegos muestran precios, botones de compra ni invitaciones a comprar; el candado del nivel 8 de Sombras es solo informativo (HU-007 R11). |
| R3 | **Sección «Premium»** en la Zona de Padres: qué incluye (lista corta, P3), el **precio que da Google Play** en la moneda del teléfono, el botón «Desbloquear Premium» y «Restaurar compra». Con Premium, la sección dice «Premium activo» y no muestra el botón de compra. |
| R4 | **El pago lo gestiona Google Play** (su hoja de pago). La app no ve ni guarda datos de pago. |
| R5 | **Restaurar:** al abrir la app, y con el botón «Restaurar compra», se consulta a Google Play qué compras tiene la cuenta; si está Premium, se activa. Así funciona en un teléfono nuevo sin copia de seguridad (D-033). |
| R6 | **Sin conexión:** se usa el último estado guardado (`UserProfile.isPremium`). Se vuelve a comprobar cuando haya conexión. |
| R7 | **Reembolso o compra anulada:** si Google Play deja de devolver la compra, Premium se desactiva y los ajustes Premium vuelven a su valor por defecto (HU-030 R11). |
| R8 | **Compras pendientes** (pago en efectivo o tarjeta que tarda): la sección muestra «Compra pendiente» con un texto tranquilo; Premium se activa cuando Google la confirme. |
| R9 | La app **confirma** (`acknowledge`) cada compra al recibirla; si no, Google la reembolsa a los 3 días. |
| R10 | **Las compras van detrás de una interfaz** (`IPremiumStore`): la de Google Play ahora; otras tiendas después (HU-015) sin tocar el resto de la app. |
| R11 | **Solo en compilaciones de depuración**, un interruptor «Premium (depuración)» en la Zona de Padres permite probar todo lo Premium sin pagar (HU-007 P10). Un test de arquitectura impide que llegue al *release*. |
| R12 | Errores (sin conexión con Google Play, cancelación): mensaje breve y amable, sin rojo, y la sección sigue usable. Cancelar no es un error. |

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-017 | Se implementa: permiso `BILLING`, añadido a la lista permitida de `tool/check_release_permissions.dart` y justificado en la sección 8 |
| D-028 | Premium solo desbloquea contenido de los juegos siguientes y ajustes de padres; la memoria sigue gratis |
| D-029 | La compra queda tras el desafío para adultos (R2) |
| D-033 | Sin copia de seguridad: la restauración viene de Google Play (R5) |
| HU-030 R4, R11 | «Jugar sin tiempo» se puede cambiar con Premium; al perderlo se reinicia (R7) |
| HU-014 | La política de privacidad y el formulario de seguridad de los datos se actualizan antes de publicar las compras (P7). La ficha deja de decir «sin compras» |
| HU-015 | Las otras tiendas usan la misma interfaz (R10) |

## 5. Criterios de aceptación (borrador)

1. **Dado** el menú y los juegos, **entonces** no hay precios, botones ni enlaces de compra.
2. **Dado** la Zona de Padres sin Premium, **entonces** veo qué incluye Premium, su precio en mi moneda y «Desbloquear Premium».
3. **Dado** que compro y Google Play confirma, **entonces** Premium se activa al instante, se guarda y la sección dice «Premium activo».
4. **Dado** que cancelo la hoja de pago, **entonces** no pasa nada y no veo ningún error.
5. **Dado** un teléfono nuevo con la misma cuenta de Google, **cuando** abro la app o toco «Restaurar compra», **entonces** Premium se activa.
6. **Dado** que la compra se reembolsa, **cuando** abro la app con conexión, **entonces** Premium se desactiva y «Jugar sin tiempo» vuelve a su valor por defecto.
7. **Dado** que no hay conexión, **entonces** la app usa el último estado guardado.
8. **Dado** una compra pendiente, **entonces** la sección lo dice y Premium se activa cuando se confirme.
9. **Dado** el *release*, **entonces** solo declara el permiso `BILLING` (CI) y no incluye el interruptor de depuración (test de arquitectura).

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dependencias | `in_app_purchase` (plugin oficial de Flutter para Google Play Billing) |
| Dominio | `IPremiumStore` (consultar productos, comprar, restaurar, flujo de compras) y `PremiumState` (no comprado, pendiente, activo) |
| Datos | `GooglePlayPremiumStore` sobre `in_app_purchase`; un `FakePremiumStore` para tests y para depuración |
| Estado | `PremiumCubit` en la raíz de la app: escucha las compras, confirma, guarda `isPremium` y aplica HU-030 R11 al perderlo |
| Presentación | Sección «Premium» en la Zona de Padres; interruptor de depuración (R11) |
| Android | Permiso `BILLING` en el manifiesto fusionado; `check_release_permissions` lo admite |
| Catálogo | Unas 12 claves en los 9 idiomas |
| Documentación | Política de privacidad (pagos por Google Play), formulario de seguridad de los datos, ficha |
| Tests | Cubit con la tienda falsa (compra, pendiente, cancelación, restauración, reembolso, sin conexión), sección, permisos, arquitectura |

## 7. Cómo se prueba de verdad

Google Play solo deja probar compras con una versión subida a un canal (la prueba cerrada de HU-014 sirve) y con **probadores de licencias** dados de alta en Play Console: compran con tarjetas de prueba sin cobro real. Hasta entonces, todo se prueba con la tienda falsa y el interruptor de depuración.

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Precio? | **2,99 USD** como precio base; Google Play lo convierte a cada país (se puede ajustar por país). Es un rango habitual para apps infantiles sin anuncios de pago único | Sí |
| P2 | ¿Identificador del producto? | `premium` (no se puede cambiar una vez creado en Play Console) | No |
| P3 | ¿Qué se anuncia que incluye? | Hoy: «Jugar sin tiempo»; con HU-007, Sombras completo (tiempo, nivel 8, 3.ª estrella, medalla). Y «los juegos que lleguen, con su contenido Premium». No prometer juegos concretos con fecha | Sí |
| P4 | ¿Prueba gratis de Premium? Google Play no tiene pruebas para pagos únicos; la idea anterior de desbloquear Premium viendo anuncios se aparcó (anuncios en una app infantil complican la política de Familias) | **No en esta historia.** Lo gratis ya es una muestra completa (D-028) | No |
| P5 | ¿Se desarrolla antes de abrir la prueba cerrada? | **No:** la prueba cerrada empieza con la app gratis; HU-006 llega como actualización durante la prueba o después. Así no se retrasan los 14 días | No |
| P6 | ¿Interruptor de depuración (R11) aquí o en HU-007? | **Aquí**, como parte de la interfaz `IPremiumStore` (tienda falsa); HU-007 lo usa | No |
| P7 | ¿Cuándo se actualizan la política y el formulario de datos? | En el mismo PR, antes de subir la versión con compras | No |
| P8 | ¿Verificación de compras en un servidor? | **No:** la app no tiene servidor (local-first). Se acepta el riesgo de piratería; la verificación la hace Google Play en el teléfono | No |

## 9. Fuera de alcance

- Suscripciones, compras consumibles y anuncios.
- Pagos fuera de Google Play (HU-015).
- Un servidor propio para verificar compras.
- Compartir Premium con la familia (Google Play Family Library) — se puede valorar después.
