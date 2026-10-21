# Revisión de traducciones

Estado de revisión de cada idioma del catálogo (`lib/l10n/`, HU-011). Las traducciones las redactó un asistente como **borrador**; un revisor externo nativo debe revisarlas todas antes de anunciar el idioma en la tienda (HU-014).

**Estados:** `borrador` → `en revisión` → `revisado`.

| Idioma | Archivo | Estado | Revisor | Fecha | Notas |
|---|---|---|---|---|---|
| Inglés (EE. UU.) | `app_en.arb` | borrador | — | — | Plantilla: cada clave tiene `description` con el contexto |
| Español neutro | `app_es.arb` | borrador | — | — | Textos originales de la app; revisar el tono neutro para Latinoamérica y España |
| Portugués (Brasil) | `app_pt.arb` | borrador | — | — | Archivo base `pt`; también lo ven los teléfonos en portugués de Portugal |
| Alemán | `app_de.arb` | borrador | — | — | Textos más largos: revisar que sigan siendo breves |
| Japonés | `app_ja.arb` | borrador | — | — | Escrito con muchos hiragana para lectura infantil; confirmar el término del juego (神経衰弱) |
| Francés | `app_fr.arb` | borrador | — | — | Tuteo («tu») dirigido al niño |
| Italiano | `app_it.arb` | borrador | — | — | — |
| Coreano | `app_ko.arb` | borrador | — | — | — |
| Árabe | `app_ar.arb` | borrador | — | — | RTL; revisar las 6 formas plurales de `victoryMovesSummary` |

## Qué recibe un revisor

1. El archivo ARB de su idioma (JSON legible) y `app_en.arb`, que contiene la descripción de cada texto: dónde aparece, si lo lee un niño o un adulto y la longitud recomendada.
2. Reglas: no traducir `appTitle` («ToddlerLogic», es la marca); conservar los marcadores `{count}` y `{symbol}`; completar todas las formas plurales de su idioma; tono cálido y simple para niños de 3 años.

## Cómo vuelven las correcciones

Por PR que modifique solo `lib/l10n/app_<idioma>.arb` y la fila de esta tabla. El CI comprueba la paridad de claves, marcadores y plurales (`test/l10n/arb_parity_test.dart`) y que nada se desborde en pantalla en ese idioma (`test/presentation/responsive_layout_test.dart`).
