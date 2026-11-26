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
- assets/brand/shadows_icon.png                 icono del juego Sombras (HU-007)
- assets/brand/odd_one_out_icon.png             icono del juego ¿Cuál es diferente? (HU-025)
- assets/brand/vehicles_icon.png                icono del juego «A su sitio» (PROMPTS §16, HU-052)
- assets/brand/counting_icon.png                icono del juego «¿Cuántos hay?» (PROMPTS §17, HU-026)
- assets/brand/sorting_icon.png                 icono del juego «Clasificar» (PROMPTS §18, HU-027)
- assets/brand/sorting_basket_back.png          la cesta de «Clasificar» entera, detrás de los objetos (PROMPTS §21, HU-027)
- assets/brand/sorting_basket_front.png         su pared delantera con los huecos transparentes, delante de los objetos
- assets/brand/hand_guide.png                   mano guía del tutorial (HU-022)
- assets/brand/child_resting.png                el niño descansando (PROMPTS §11, HU-009)
- assets/brand/child_sleeping.png               el niño durmiendo (PROMPTS §12, HU-038)
- assets/brand/child_celebrating.png            el niño celebrando (PROMPTS §13, HU-037)
- assets/brand/child_inviting.png               el niño invitando (PROMPTS §14, HU-034 y HU-041)
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


# La cesta de «Clasificar» (PROMPTS §21), en partes del lienzo, medidas en
# docs/brand/fuentes/cesta-clasificar.png. El borde de arriba de la cuerda
# delantera es la mitad de abajo de una elipse (centro, semiejes); por debajo
# de ella va la capa delantera. Las mismas medidas están en SortBasketArt.
BASKET_RIM_CENTER_Y = 0.471
BASKET_RIM_HALF_WIDTH = 0.37
BASKET_RIM_HALF_HEIGHT = 0.054
BASKET_CUT_MARGIN = 0.008
BASKET_SIZE = 480


def is_basket_hole(r: int, g: int, b: int) -> bool:
    """Marrón oscuro de los huecos de la rejilla: la herramienta pintó en ellos
    la pared del fondo. Ni el naranja de las tiras ni el teal de la placa."""
    return 60 < r < 150 and g < 75 and b < 35


def basket_layers(source: Image.Image) -> tuple[Image.Image, Image.Image]:
    """La cesta entera (detrás de lo colocado) y su parte delantera con los
    huecos transparentes (delante): así lo colocado asoma por encima del borde
    y se ve por los huecos. Sin recortar el lienzo: las medidas son fracciones."""
    back = source.convert('RGBA').resize((BASKET_SIZE, BASKET_SIZE), Image.LANCZOS)
    front = back.copy()
    px = front.load()
    for x in range(BASKET_SIZE):
        dx = (x + 0.5) / BASKET_SIZE - 0.5
        inside = max(0.0, 1 - (dx / BASKET_RIM_HALF_WIDTH) ** 2)
        cut = (BASKET_RIM_CENTER_Y + BASKET_RIM_HALF_HEIGHT * math.sqrt(inside) - BASKET_CUT_MARGIN) * BASKET_SIZE
        for y in range(BASKET_SIZE):
            r, g, b, a = px[x, y]
            if y < cut or is_basket_hole(r, g, b):
                px[x, y] = (0, 0, 0, 0)
    return back, front


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
    fit_box(Image.open(SRC / 'icono-sombras-elefante.png'), 256).save(
        ROOT / 'assets/brand/shadows_icon.png', optimize=True
    )
    fit_box(Image.open(SRC / 'icono-cual-es-diferente.png'), 256).save(
        ROOT / 'assets/brand/odd_one_out_icon.png', optimize=True
    )
    fit_box(Image.open(SRC / 'icono-a-su-sitio-camion.png'), 256).save(
        ROOT / 'assets/brand/vehicles_icon.png', optimize=True
    )
    fit_box(Image.open(SRC / 'icono-cuantos-hay.png'), 256).save(
        ROOT / 'assets/brand/counting_icon.png', optimize=True
    )
    fit_box(Image.open(SRC / 'icono-clasificar.png'), 256).save(
        ROOT / 'assets/brand/sorting_icon.png', optimize=True
    )
    back, front = basket_layers(Image.open(SRC / 'cesta-clasificar.png'))
    back.save(ROOT / 'assets/brand/sorting_basket_back.png', optimize=True)
    front.save(ROOT / 'assets/brand/sorting_basket_front.png', optimize=True)
    # La mano se recorta igual que los iconos: la punta del índice queda en el
    # 12 % del ancho y el 8 % del alto (GestureHint.fingertip).
    fit_box(Image.open(SRC / 'mano-guia.png'), 256).save(ROOT / 'assets/brand/hand_guide.png', optimize=True)
    # Ilustraciones del niño (PROMPTS §11 a §14): se muestran a unos 200 dp como
    # mucho; 480 px bastan para 2,4x sin pesar en la descarga (TD-012).
    for source, target in [
        ('nino-descansando.png', 'child_resting.png'),
        ('nino-durmiendo.png', 'child_sleeping.png'),
        ('nino-celebrando.png', 'child_celebrating.png'),
        ('nino-invitando.png', 'child_inviting.png'),
    ]:
        fit_box(Image.open(SRC / source), 480).save(ROOT / 'assets/brand' / target, optimize=True)


if __name__ == '__main__':
    main()
