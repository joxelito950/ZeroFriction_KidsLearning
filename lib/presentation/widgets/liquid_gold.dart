import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Dorado líquido del progreso de un juego (HU-002 R15–R17): sube de abajo
/// arriba hasta [fraction], con una ola suave que se mece y burbujas que suben
/// despacio. Es decorativo: el porcentaje lo anuncia quien lo usa (R6).
///
/// Sin [child], pinta el líquido en todo su espacio (el fondo del botón del
/// juego en el menú). Con [child], lo pinta **solo sobre la silueta** del hijo
/// (el icono del juego), como un líquido dentro de un recipiente.
///
/// Una sola animación lenta, que no corre con «reducir movimiento», al 0 % ni
/// cuando la pantalla no está a la vista (`TickerMode`): con muchos juegos en
/// el menú no debe pesar en un teléfono de gama baja (R17).
class LiquidGold extends StatefulWidget {
  const LiquidGold({super.key, required this.fraction, this.animate = true, this.child})
      : assert(fraction >= 0 && fraction <= 1);

  /// Una vuelta completa de la ola y de las burbujas.
  static const Duration period = Duration(seconds: 6);

  final double fraction;
  final bool animate;
  final Widget? child;

  @override
  State<LiquidGold> createState() => _LiquidGoldState();
}

class _LiquidGoldState extends State<LiquidGold> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: LiquidGold.period);

  bool get _moving => widget.animate && widget.fraction > 0 && !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(LiquidGold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (_moving) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = LiquidGoldPainter(
      fraction: widget.fraction,
      animation: _controller,
      moving: _moving,
      onlyOverChild: widget.child != null,
    );
    final Widget? child = widget.child;
    if (child == null) {
      return CustomPaint(key: const ValueKey<String>('liquid-gold'), painter: painter, size: Size.infinite);
    }
    // Capa propia: así el líquido solo se pinta donde ya hay icono (srcATop).
    return RepaintBoundary(
      child: CustomPaint(key: const ValueKey<String>('liquid-gold'), foregroundPainter: painter, child: child),
    );
  }
}

/// Pinta el líquido. Público para poder probar su geometría.
class LiquidGoldPainter extends CustomPainter {
  LiquidGoldPainter({
    required this.fraction,
    required this.animation,
    required this.moving,
    this.onlyOverChild = false,
  }) : super(repaint: animation);

  final double fraction;
  final Animation<double> animation;
  final bool moving;
  final bool onlyOverChild;

  /// Burbujas: posición horizontal (fracción del ancho), radio y desfase.
  static const List<(double, double, double)> bubbles = [
    (0.14, 2.5, 0.00),
    (0.31, 3.5, 0.37),
    (0.48, 2.0, 0.71),
    (0.63, 3.0, 0.18),
    (0.79, 2.5, 0.55),
    (0.90, 2.0, 0.86),
  ];

  /// Altura de la superficie, de arriba abajo: 0 lleno, [height] vacío.
  static double surfaceY(double height, double fraction) => height * (1 - fraction);

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0 || size.isEmpty) return;
    final double t = moving ? animation.value : 0;
    final double level = surfaceY(size.height, fraction);
    final double amplitude = moving ? math.min(4.0, size.height * 0.04) : 0;
    final double wavelength = size.width / 1.5;
    double waveAt(double x) => level + amplitude * math.sin(2 * math.pi * (x / wavelength + t));

    final Path surface = Path()..moveTo(0, waveAt(0));
    for (double x = 4; x <= size.width; x += 4) {
      surface.lineTo(x, waveAt(x));
    }
    surface.lineTo(size.width, waveAt(size.width));
    final Path body = Path.from(surface)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final BlendMode blend = onlyOverChild ? BlendMode.srcATop : BlendMode.srcOver;
    final Rect liquid = Rect.fromLTRB(0, level - amplitude, size.width, size.height);
    canvas.drawPath(
      body,
      Paint()
        ..blendMode = blend
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Ámbar en la superficie y dorado en el fondo: volumen, no un color plano.
          colors: [AppPalette.amber.withValues(alpha: 0.9), AppPalette.gold.withValues(alpha: 0.92)],
        ).createShader(liquid),
    );
    // Brillo de la superficie.
    canvas.drawPath(
      surface,
      Paint()
        ..blendMode = blend
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppPalette.amber,
    );
    if (!moving) return;
    for (final (double x, double radius, double offset) in bubbles) {
      final double progress = (t + offset) % 1;
      final double y = size.height - progress * (size.height - level);
      if (y - radius <= level + amplitude) continue;
      canvas.drawCircle(
        Offset(x * size.width, y),
        radius,
        Paint()
          ..blendMode = blend
          ..color = AppPalette.white.withValues(alpha: 0.45 * (1 - progress)),
      );
    }
  }

  @override
  bool shouldRepaint(LiquidGoldPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.moving != moving || oldDelegate.onlyOverChild != onlyOverChild;
}
