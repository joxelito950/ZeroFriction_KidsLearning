"""Prepara las imágenes de la identidad (HU-013) a partir de las fuentes de
docs/brand/fuentes/. Requiere Pillow (pip install pillow).

    python tool/brand/prepare_brand_images.py

Genera:
- docs/brand/generados/launcher_foreground.png  primer plano del icono adaptativo
- docs/brand/generados/launcher_monochrome.png  icono monocromo (Android 13+)
- docs/brand/generados/launcher_full.png        icono cuadrado completo (Android < 8 y base del de la tienda)
- docs/store/icon-512.png                       icono de Google Play (512 x 512, sin transparencia)
- docs/store/feature-graphic.png                gráfico destacado de la ficha (1024 x 500, sin texto)
- assets/brand/logo.png                         logo del menú
- assets/brand/memory_icon.png                  icono del juego de memoria
Después: dart run flutter_launcher_icons
"""
import math
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / 'docs/brand/fuentes'
GEN = ROOT / 'docs/brand/generados'
DEEP_TEAL = (0x00, 0x45, 0x4D, 255)

# Zona segura del icono adaptativo: un círculo de 66 dp en un lienzo de 108 dp,
# es decir, un radio de 0,3056 del lado. Se deja un poco de margen.
SAFE_RADIUS = 0.30
# flutter_launcher_icons dibuja el primer plano y el monocromo con un margen
# (inset) del 16 % por lado, es decir, al 68 % del lienzo: se compensa aquí.
LAUNCHER_INSET_SCALE = 0.68
LAUNCHER_RADIUS = SAFE_RADIUS / LAUNCHER_INSET_SCALE
# En el icono cuadrado completo, Google aplica su máscara: margen de un 8 %.
FULL_RADIUS = 0.42


def trim(im: Image.Image) -> Image.Image:
    im = im.convert('RGBA')
    return im.crop(im.split()[3].point(lambda v: 255 if v > 20 else 0).getbbox())


def fit_in_circle(im: Image.Image, radius: float, size: int = 1024) -> Image.Image:
    """Centra [im] de modo que su píxel visible más lejano del centro quede a radius * size."""
    im = trim(im)
    alpha = im.split()[3].load()
    w, h = im.size
    far = max(
        math.hypot(x - w / 2, y - h / 2)
        for y in range(0, h, 2)
        for x in range(0, w, 2)
        if alpha[x, y] > 20
    )
    k = radius * size / far
    im = im.resize((round(w * k), round(h * k)), Image.LANCZOS)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(im, ((size - im.width) // 2, (size - im.height) // 2), im)
    return out


def on_teal(im: Image.Image) -> Image.Image:
    out = Image.new('RGBA', im.size, DEEP_TEAL)
    out.alpha_composite(im)
    return out


def fit_box(im: Image.Image, longest: int) -> Image.Image:
    im = trim(im)
    k = longest / max(im.size)
    return im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)


def feature_graphic() -> Image.Image:
    """Gráfico destacado de Google Play: 1024 x 500, sin transparencia y sin texto
    (vale para todos los idiomas). El niño a la derecha del centro y el icono de
    memoria a la izquierda, sobre un degradado de teal profundo a azul petróleo."""
    w, h = 1024, 500
    out = Image.new('RGBA', (w, h))
    top, bottom = DEEP_TEAL[:3], (0x17, 0x6B, 0x78)
    for y in range(h):
        t = y / (h - 1)
        row = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,)
        out.paste(row, (0, y, w, y + 1))
    # Google recorta los bordes en algunos usos: lo importante, en el centro.
    child = fit_box(Image.open(SRC / 'icono-nino-rompecabezas.png'), 450)
    out.alpha_composite(child, (w // 2 - 40, (h - child.height) // 2))
    cards = fit_box(Image.open(SRC / 'icono-memoria-cartas.png'), 250)
    out.alpha_composite(cards, (w // 2 - 40 - cards.width - 40, (h - cards.height) // 2 + 20))
    return out.convert('RGB')


def main() -> None:
    GEN.mkdir(parents=True, exist_ok=True)
    (ROOT / 'assets/brand').mkdir(parents=True, exist_ok=True)
    icon = Image.open(SRC / 'icono-nino-rompecabezas.png')

    fit_in_circle(icon, LAUNCHER_RADIUS).save(GEN / 'launcher_foreground.png', optimize=True)

    # El sistema solo usa el canal alfa del monocromo: se pinta todo en negro.
    mono = fit_in_circle(Image.open(SRC / 'monocromo-silueta-nino.png'), LAUNCHER_RADIUS)
    black = Image.new('RGBA', mono.size, (0, 0, 0, 255))
    black.putalpha(mono.split()[3])
    black.save(GEN / 'launcher_monochrome.png', optimize=True)

    full = on_teal(fit_in_circle(icon, FULL_RADIUS))
    full.save(GEN / 'launcher_full.png', optimize=True)
    # Google Play: PNG de 32 bits, 512 x 512, sin transparencia.
    full.resize((512, 512), Image.LANCZOS).save(ROOT / 'docs/store/icon-512.png', optimize=True)

    feature_graphic().save(ROOT / 'docs/store/feature-graphic.png', optimize=True)

    fit_box(Image.open(SRC / 'logo-nino-piezas.png'), 480).save(ROOT / 'assets/brand/logo.png', optimize=True)
    fit_box(Image.open(SRC / 'icono-memoria-cartas.png'), 256).save(
        ROOT / 'assets/brand/memory_icon.png', optimize=True
    )


if __name__ == '__main__':
    main()
