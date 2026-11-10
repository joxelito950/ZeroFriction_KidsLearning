import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../brand/brand_assets.dart';
import 'liquid_gold.dart';

/// Icono de un juego (HU-013 entregable 5). Es decorativo: el nombre del juego ya
/// lo dice el botón o la cabecera, así que el lector de pantalla lo ignora.
///
/// [goldFraction] es el dorado de HU-002 (D-030): la silueta se llena de un
/// líquido dorado de abajo arriba, del 0 al 1. Con [animateGold], la ola se
/// mece y suben burbujas (R15); en la cabecera del juego va quieto.
class GameIcon extends StatefulWidget {
  const GameIcon({
    super.key,
    required this.asset,
    required this.size,
    this.goldFraction = 0,
    this.animateGold = false,
  }) : assert(goldFraction >= 0 && goldFraction <= 1);

  /// Icono del juego de memoria.
  const GameIcon.memory({Key? key, required double size, double goldFraction = 0, bool animateGold = false})
      : this(key: key, asset: BrandAssets.memoryIcon, size: size, goldFraction: goldFraction, animateGold: animateGold);

  /// Icono del juego Sombras (HU-007).
  const GameIcon.shadows({Key? key, required double size, double goldFraction = 0, bool animateGold = false})
      : this(key: key, asset: BrandAssets.shadowsIcon, size: size, goldFraction: goldFraction, animateGold: animateGold);

  final String asset;
  final double size;
  final double goldFraction;
  final bool animateGold;

  /// Coloca [image] dentro de [bounds] como `BoxFit.contain`, igual que el icono:
  /// es la máscara del líquido.
  static Matrix4 containTransform(Size bounds, ui.Image image) {
    final double scale = (bounds.width / image.width) < (bounds.height / image.height)
        ? bounds.width / image.width
        : bounds.height / image.height;
    return Matrix4.identity()
      ..translateByDouble((bounds.width - image.width * scale) / 2, (bounds.height - image.height * scale) / 2, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  State<GameIcon> createState() => _GameIconState();
}

class _GameIconState extends State<GameIcon> {
  /// La imagen decodificada, para usar su transparencia como máscara del líquido.
  ui.Image? _mask;
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    if (mounted) setState(() => _mask = info.image);
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(GameIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  void _resolve() {
    final ImageStream stream = AssetImage(widget.asset).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final Widget image = Image.asset(
      widget.asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      // Sin la imagen (no debería pasar), queda el hueco: nunca un error a la vista.
      errorBuilder: (context, error, stackTrace) => SizedBox.square(dimension: size),
    );
    final ui.Image? mask = _mask;
    if (widget.goldFraction == 0 || mask == null) return ExcludeSemantics(child: image);

    // Dorado líquido solo sobre la silueta (HU-002 R15, R16): el líquido ocupa
    // todo el cuadro y la transparencia del propio icono lo recorta (dstIn).
    // Probado en el moto g55: con srcATop, el motor gráfico (Impeller) pintaba
    // un rectángulo entero.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            ShaderMask(
              key: const ValueKey<String>('game-icon-gold'),
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => ImageShader(
                mask,
                TileMode.decal,
                TileMode.decal,
                GameIcon.containTransform(bounds.size, mask).storage,
              ),
              child: LiquidGold(fraction: widget.goldFraction, animate: widget.animateGold, translucent: true),
            ),
          ],
        ),
      ),
    );
  }
}
