# HU-006 · Pago único (Premium) con Google Play Billing y restauración

| | |
|---|---|
| **Estado** | En refinamiento (P1 decidida el 2026-11-11: precio por escalones de 0,99 a 2,99 USD) (iniciado el 2026-11-06; preguntas en la sección 8) |
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
| P1 | ¿Precio? | ✅ Decidido (2026-11-11): **precio que sube con el contenido.** Las primeras versiones, con 1 o 2 juegos con parte Premium, a **1 USD** (en Google Play, 0,99 USD); sube por escalones a medida que lleguen juegos, **hasta 3 USD** (2,99). Quien compra antes **conserva Premium completo sin pagar más**, incluidos los juegos que lleguen: es el premio por apoyar pronto. Escalones en P11 | — |
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

## 10. Avance del refinamiento (2026-11-10, sin respuestas del dueño)

### 10.1 Depende de HU-037

HU-037 (rondas de dificultad y medallas) cambia **qué es Premium** (su P6): la recomendación allí es gratis la ronda Fácil completa, con su bronce, y Premium las rondas Normal e Imposible, con plata y oro. Esto sustituiría lo de P3 («tiempo, nivel 8, 3.ª estrella y medalla de Sombras»). **Propuesta:** cerrar HU-037 P6 antes que P3 de esta historia.

### 10.2 Lo que hay que preparar en Play Console (lo hace el dueño, una vez)

1. **Perfil de pagos** (cuenta de comerciante) en *Configuración › Perfil de pagos*: datos fiscales y cuenta bancaria. Sin él no se pueden crear productos de pago.
2. Cambiar en *Contenido de la app* y en la ficha: «Contiene compras en la aplicación» (Google lo marca solo al crear el producto) y repetir la **clasificación del contenido** (pregunta de compras digitales).
3. Crear el **producto** `premium` en *Monetizar › Productos › Productos de compra única* con su precio base (P1). El identificador no se puede cambiar después (P2).
4. Dar de alta a los **probadores de licencias** (los correos de los testers) en *Configuración › Prueba de licencias*: compran sin cobro real.

### 10.3 Lo que hay que comprobar al desarrollar

- **Permisos:** `in_app_purchase` añade `com.android.vending.BILLING`. Se mide en el PR si añade alguno más; `check_release_permissions` admitirá solo ese.
- **Seguridad de los datos:** la biblioteca de Google Play Billing comunica la compra a Google Play. Hay que revisar la guía de Google para esa biblioteca y, si lo pide, declarar «Historial de compras» como dato recogido para «Funcionalidad de la app». La app sigue sin servidor (P8).
- **Política de privacidad:** sección «Compras» con el texto definitivo (hoy dice que no hay compras).
- **Familias:** la compra solo tras el desafío de adultos (R2), sin mensajes que inviten al niño a comprar.

### 10.4 Entregas propuestas

| # | Entrega | Contenido |
|---|---|---|
| 1 | Dominio y tienda falsa | `IPremiumStore`, `PremiumState`, `FakePremiumStore`, `PremiumCubit` (compra, pendiente, cancelación, restauración, reembolso, sin conexión) y el interruptor de depuración (R11) con su test de arquitectura |
| 2 | Google Play | `GooglePlayPremiumStore` sobre `in_app_purchase`, confirmación (`acknowledge`), restauración al arrancar, permisos |
| 3 | Zona de Padres y textos | Sección «Premium» (R3), precio de Google Play, mensajes de error amables, 9 idiomas, política, ficha y formulario de datos |
| 4 | Prueba real | Versión en la prueba interna con probadores de licencias: comprar, cancelar, reembolsar y restaurar en el moto g55 |

### 10.5 Preguntas nuevas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P9 | ¿Se permite compartir Premium con la familia (Google Play Family Library)? | **Sí, más adelante:** es un interruptor en Play Console y encaja con hermanos (HU-033). No en la primera versión | No |
| P10 | ¿El precio se ajusta por país o se deja la conversión automática de Google? | **Automática** al principio; revisar después con los datos de la consola | No |

## 11. Cambio por la decisión de HU-037 P6 (2026-11-10)

Qué es Premium ya no es una lista fija: **cada juego decide** (HU-037 P6). Con eso, la respuesta a P3 queda casi hecha:

> **Premium incluye:** «Jugar sin tiempo» en todos los juegos; el nivel más difícil de cada ronda de Sombras; la mitad del juego «¿Cuál es diferente?»; y los juegos completos que lleguen (con ediciones especiales gratis por un tiempo, HU-042).

Lo único que falta decidir de P3 es **cómo se anuncia** en la Zona de Padres y en la ficha sin prometer juegos concretos con fecha. **Recomendación:** la frase de arriba sin nombres de juegos futuros («y los juegos nuevos que lleguen»). P1 (precio) sigue abierta.

## 12. Precio por escalones (decidido el 2026-11-11, P1)

### 12.1 ¿Se puede cambiar el precio después?

**Sí.** El precio de un producto de Google Play se cambia cuando se quiera en Play Console, sin publicar una versión nueva de la app. El cambio vale para las compras **nuevas**; quien ya compró **no paga nada más** y sigue teniendo el producto, porque Premium es un producto de **compra única**: queda asociado a su cuenta de Google para siempre y se restaura en otro teléfono (R5).

Lo que **no** se puede cambiar es el **identificador** del producto (`premium`, P2).

### 12.2 Cómo se cumple «quien compra pronto lo conserva todo»

Basta con **no crear nunca un segundo producto**: todo lo Premium presente y futuro cuelga del mismo `premium`. Si algún día se vendiera algo aparte (por ejemplo, un paquete de temporada, HU-042), sería un producto distinto y **nunca** quitaría nada a quien ya tiene `premium`. Se anota como decisión D-039.

### 12.3 Escalones propuestos

| Momento | Juegos con parte Premium | Precio base |
|---|---|---|
| Primera versión con compras | Sombras (nivel 8) y «Jugar sin tiempo» | **0,99 USD** |
| Con «¿Cuál es diferente?» (HU-025) | 2 | 0,99 USD |
| Con el primer juego 100 % Premium | 3 | **1,99 USD** |
| Con 5 o más juegos con parte Premium | 5+ | **2,99 USD** (tope) |

Google Play convierte el precio base a cada país; se puede ajustar país por país (P10).

### 12.4 Cuidados al comunicarlo

- **No prometer subidas con fecha** ni usar frases de urgencia («¡compra antes de que suba!»): la política de Familias y las normas de consumo las tratan como presión de venta, y más en una app infantil. Se puede decir, en la Zona de Padres y en la ficha, algo neutro: «Un único pago. Incluye los juegos Premium que lleguen después».
- Las **notas de la versión** que suban el precio no lo mencionan; el precio nuevo lo muestra Google Play.
- Antes de cada subida, comprobar que el contenido Premium de verdad ha crecido (el escalón va con los juegos, no con el calendario).

### 12.5 Preguntas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P11 | ¿Los escalones de la tabla 12.3? | **Sí**, 0,99 → 1,99 → 2,99 según los juegos | No |
| P12 | ¿Se dice en la app que el precio irá subiendo? | **No**, solo «Un único pago, incluye los juegos Premium que lleguen» (12.4) | No |

