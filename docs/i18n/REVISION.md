# Revisión de traducciones

Estado de revisión de cada idioma del catálogo (`lib/l10n/`, HU-011). Las traducciones las redactó un asistente como **borrador**; un revisor externo nativo debe revisarlas todas antes de anunciar el idioma en la tienda (HU-014).

**Estados:** `borrador` → `en revisión` → `revisado`.

| Idioma | Archivo | Estado | Revisor | Fecha | Notas |
|---|---|---|---|---|---|
| Inglés (EE. UU.) | `app_en.arb` | revisado | Dueño (`app_en_reviewed.arb` y `_v2`) | 2026-11-16 | Revisión aplicada. Un ajuste del desarrollo: la pista tras un fallo habla de las dos cartas («the cards are flipping back»), porque se dan la vuelta las dos. **v2 (4 textos):** «Play without a time limit», «an easier challenge» y la ayuda de las rondas. Antes de anunciar la app en países de habla inglesa conviene una lectura de un hablante nativo |
| Español neutro | `app_es.arb` | revisado | Dueño (`app_es_reviewed.arb` y `_v2`) | 2026-11-16 | Revisión aplicada (40 textos). Ajustes del desarrollo: «Las cartas se están volteando» (son dos), «sin prisa» en lugar de «sin afán» (regional). La dificultad más alta se llama «Reto máximo». **v2 (9 textos):** «Medalla dorada», «Añadir 15 minutos» (sustituye a «Agregar»), «un reto más sencillo», «¡Encontraste el objeto diferente en cada tablero!» y las ayudas de sonido, rondas y «Jugar sin tiempo» |
| Portugués (Brasil) | `app_pt.arb` | borrador | — | — | Archivo base `pt`; también lo ven los teléfonos en portugués de Portugal |
| Alemán | `app_de.arb` | borrador | — | — | Textos más largos: revisar que sigan siendo breves |
| Japonés | `app_ja.arb` | en revisión | Dueño (`app_ja_reviewed_v2.arb`) | 2026-11-16 | **v2 aplicada (24 textos).** Cambia de criterio: textos que ve el niño pasan de hiragana a kanji (時間切れ, 銅メダル, 金メダル). Falta un hablante nativo que confirme ese criterio y el término del juego (神経衰弱) |
| Francés | `app_fr.arb` | en revisión | Dueño (`app_fr_reviewed_v2.arb`) | 2026-11-16 | Tuteo («tu») dirigido al niño. **v2 aplicada (22 textos):** apóstrofo tipográfico (’), «application» en lugar de «appli», «Défi ultime» para la dificultad más alta, «indices» por «aides». Falta un hablante nativo |
| Italiano | `app_it.arb` | en revisión | Dueño (`app_it_reviewed_v2.arb`) | 2026-11-16 | **v2 aplicada (23 textos):** «Qual è diverso?», «Fase» en lugar de «Round», «Sfida estrema», «suggerimenti» por «aiuti». Falta un hablante nativo |
| Coreano | `app_ko.arb` | en revisión | Dueño (`app_ko_reviewed_v2.arb`) | 2026-11-16 | **v2 aplicada (22 textos):** «어느 그림이 다를까요?», «매우 어려움» para la dificultad más alta, «힌트» por «도움». Falta un hablante nativo |
| Árabe | `app_ar.arb` | borrador | — | — | RTL; revisar las 6 formas plurales de `victoryMovesSummary` |

## Qué recibe un revisor

1. El archivo ARB de su idioma (JSON legible) y `app_en.arb`, que contiene la descripción de cada texto: dónde aparece, si lo lee un niño o un adulto y la longitud recomendada.
2. Reglas: no traducir `appTitle` («ToddlerLogic», es la marca); conservar los marcadores `{count}` y `{symbol}`; completar todas las formas plurales de su idioma; tono cálido y simple para niños de 3 años.

## Cómo vuelven las correcciones

Por PR que modifique solo `lib/l10n/app_<idioma>.arb` y la fila de esta tabla. El CI comprueba la paridad de claves, marcadores y plurales (`test/l10n/arb_parity_test.dart`) y que nada se desborde en pantalla en ese idioma, incluidos los avisos sobre el tablero (`test/presentation/responsive_layout_test.dart`).
