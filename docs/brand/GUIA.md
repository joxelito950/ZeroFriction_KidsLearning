# Guía de la identidad visual (HU-013)

Mínimo para que los juegos nuevos sigan el mismo estilo. La paleta está en [PALETA.md](PALETA.md) (D-032).

## Personaje

El **niño** de la imagen base es el personaje de identidad de la app (decidido el 2026-11-05): pelo castaño rizado, ojos grandes, sonrisa abierta, camiseta coral. Aparece en el icono de la app, en el de la tienda y en el logo. Sus usos dentro de la app (descanso, celebraciones) son de HU-017.

## Estilo

- **Ilustración 3D suave, de plastilina mate** (D-036): volumen y sombras suaves, sin brillos metálicos ni texturas.
- Formas grandes y redondeadas, que se entiendan a 48 dp. Un concepto por icono, sin texto.
- Colores: los de la paleta con su volumen; la piel y el pelo, con su tono natural. Sin rojo intenso, cian ni neón.
- Sin emojis, sin marcas ni personajes conocidos (R1, R3).

## Piezas y formatos

| Pieza | Formato | Dónde |
|---|---|---|
| Fuentes | PNG de 1024 px o más, con transparencia | `docs/brand/fuentes/` |
| Icono del launcher | Primer plano + monocromo (PNG por densidad) y fondo `#00454D` | `android/app/src/main/res/` (generado) |
| Icono de la tienda | PNG 512 × 512 sin transparencia | `docs/store/icon-512.png` (generado) |
| Logo e iconos de juego | PNG con transparencia | `assets/brand/` (generado) |

**Icono de un juego nuevo:** un PNG con transparencia, compacto y con una silueta cerrada (recibe el dorado de HU-002), del mismo estilo; se añade a `tool/brand/prepare_brand_images.py` y a `lib/brand/brand_assets.dart`.

## Tipografía

La de Material (Roboto en Android), que ya trae el sistema: sin tipografías de terceros ni licencias que anotar.

## Regenerar

```powershell
python tool/brand/prepare_brand_images.py   # necesita Pillow: pip install pillow
dart run flutter_launcher_icons
```

Los textos para pedir nuevas versiones a la herramienta de imágenes están en [PROMPTS-identidad.md](PROMPTS-identidad.md).

## Origen

Las imágenes las generó el dueño del producto con IA (ChatGPT); los archivos llevan sus credenciales de contenido (C2PA). Google Play las acepta. La protección por derechos de autor de una imagen generada por IA puede ser limitada: si se quiere proteger la marca, la vía es registrarla.
