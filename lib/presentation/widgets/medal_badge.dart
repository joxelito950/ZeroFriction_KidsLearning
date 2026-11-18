import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Forma de la medalla: los metales son un disco con estrellas; las gemas, una
/// piedra facetada; el diamante, además, con destellos (HU-051 3.4).
enum MedalShape { disc, gem, diamond }

/// Cómo se ve una medalla (HU-048, HU-051): forma, relleno, borde y estrellas
/// o facetas. Se distinguen por varias señales a la vez, no solo por el color:
/// el oro es claro y el bronce oscuro (luminosidad), los metales llevan 1, 2 o
/// 3 estrellas y las gemas tienen otra forma.
@immutable
final class MedalStyle {
  const MedalStyle({
    required this.fill,
    required this.rim,
    required this.stars,
    required this.starColor,
    this.shape = MedalShape.disc,
  });

  final Color fill;
  final Color rim;

  /// Estrellas grabadas en los metales: 1 bronce, 2 plata, 3 oro. Las gemas no
  /// llevan (0).
  final int stars;

  /// Color de las estrellas, o de las facetas en las gemas.
  final Color starColor;
  final MedalShape shape;

  /// Borde de bronce y plata: teal profundo al 45 %, más oscuro que el relleno
  /// usando solo transparencia (C2).
  static final Color _darkRim = AppPalette.deepTeal.withValues(alpha: 0.45);

  static final MedalStyle bronze = MedalStyle(
    fill: AppPalette.medalBronze,
    rim: _darkRim,
    stars: 1,
    starColor: AppPalette.warmCream,
  );

  static final MedalStyle silver = MedalStyle(
    fill: AppPalette.medalSilver,
    rim: _darkRim,
    stars: 2,
    starColor: AppPalette.warmCream,
  );

  /// Claro y luminoso: ámbar con borde y estrellas en dorado.
  static const MedalStyle gold = MedalStyle(
    fill: AppPalette.amber,
    rim: AppPalette.gold,
    stars: 3,
    starColor: AppPalette.gold,
  );

  /// Rubí y esmeralda: los dos colores exclusivos de las medallas (HU-051).
  static final MedalStyle ruby = MedalStyle(
    fill: AppPalette.medalRuby,
    rim: _darkRim,
    stars: 0,
    starColor: AppPalette.warmCream,
    shape: MedalShape.gem,
  );

  static final MedalStyle emerald = MedalStyle(
    fill: AppPalette.medalEmerald,
    rim: _darkRim,
    stars: 0,
    starColor: AppPalette.warmCream,
    shape: MedalShape.gem,
  );

  static final MedalStyle sapphire = MedalStyle(
    fill: AppPalette.petrolBlue,
    rim: _darkRim,
    stars: 0,
    starColor: AppPalette.warmCream,
    shape: MedalShape.gem,
  );

  /// Casi negra, con reflejos crema.
  static const MedalStyle obsidian = MedalStyle(
    fill: AppPalette.deepTeal,
    rim: AppPalette.deepTeal,
    stars: 0,
    starColor: AppPalette.warmCream,
    shape: MedalShape.gem,
  );

  /// Blanco y crema con destellos ámbar; el borde teal la separa del fondo.
  static final MedalStyle diamond = MedalStyle(
    fill: AppPalette.white,
    rim: AppPalette.deepTeal.withValues(alpha: 0.35),
    stars: 0,
    starColor: AppPalette.amber,
    shape: MedalShape.diamond,
  );

  @override
  bool operator ==(Object other) =>
      other is MedalStyle &&
      other.fill == fill &&
      other.rim == rim &&
      other.stars == stars &&
      other.starColor == starColor &&
      other.shape == shape;

  @override
  int get hashCode => Object.hash(fill, rim, stars, starColor, shape);
}

/// La medalla dibujada por la app (HU-048 P1): un disco con sus estrellas o
/// una gema, que llena el cuadrado de [size] (centro [discCenter], radio
/// [discRadius], en fracciones del lado). Sin cinta: en el menú y en la Zona de
/// Padres aprovecha todo el círculo; en la celebración, la cinta la dibuja
/// [MedalRibbonPainter], que la cuelga del cuello del niño (HU-049).
class MedalBadge extends StatelessWidget {
  const MedalBadge({super.key, required this.style, required this.size, this.semanticLabel});

  final MedalStyle style;
  final double size;

  /// «Medalla de bronce», etc. Sin él, la medalla es decorativa.
  final String? semanticLabel;

  static const Offset discCenter = Offset(0.5, 0.5);
  static const double discRadius = 0.5;

  @override
  Widget build(BuildContext context) {
    final Widget paint = CustomPaint(size: Size.square(size), painter: MedalPainter(style));
    final String? label = semanticLabel;
    return label == null ? ExcludeSemantics(child: paint) : Semantics(label: label, image: true, child: paint);
  }
}

/// Pinta [MedalBadge]. Pública para poder probar lo que dibuja.
class MedalPainter extends CustomPainter {
  const MedalPainter(this.style);

  final MedalStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Offset center = Offset(MedalBadge.discCenter.dx * s, MedalBadge.discCenter.dy * s);
    final double radius = MedalBadge.discRadius * s;

    if (style.shape != MedalShape.disc) {
      _paintGem(canvas, s, center);
      return;
    }

    // Disco con su borde.
    canvas.drawCircle(center, radius, Paint()..color = style.fill);
    canvas.drawCircle(
      center,
      radius - s * 0.045,
      Paint()
        ..color = style.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.09,
    );

    // Estrellas grabadas, centradas en fila.
    final int count = style.stars.clamp(1, 3);
    final double starRadius = s * (count == 1 ? 0.21 : 0.13);
    final double step = starRadius * 2.05;
    final Paint star = Paint()..color = style.starColor;
    for (var index = 0; index < count; index++) {
      final double dx = (index - (count - 1) / 2) * step;
      canvas.drawPath(_star(center + Offset(dx, 0), starRadius), star);
    }
  }

  /// Una gema facetada (HU-051 3.4) engastada en un disco claro de su color,
  /// con un borde del color de la gema: tan redonda como los metales, para
  /// llenar el círculo del menú y tapar el pecho del niño (HU-049).
  void _paintGem(Canvas canvas, double s, Offset discCenter) {
    final double radius = MedalBadge.discRadius * s;
    final Color setting = style.shape == MedalShape.diamond ? style.rim : style.fill;
    canvas.drawCircle(discCenter, radius, Paint()..color = Color.alphaBlend(setting.withValues(alpha: 0.18), AppPalette.white));
    canvas.drawCircle(
      discCenter,
      radius - s * 0.045,
      Paint()
        ..color = setting
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.09,
    );

    final double r = s * 0.31;
    final Offset center = discCenter + Offset(0, s * 0.03);
    // Corona plana arriba, pabellón en punta abajo.
    final List<Offset> outline = [
      center + Offset(-r * 0.55, -r * 0.75),
      center + Offset(r * 0.55, -r * 0.75),
      center + Offset(r, -r * 0.2),
      center + Offset(0, r),
      center + Offset(-r, -r * 0.2),
    ];
    final Path gem = Path()..addPolygon(outline, true);
    canvas.drawPath(gem, Paint()..color = style.fill);

    // Facetas: la línea de la cintura y los cortes hacia la punta.
    final Paint facet = Paint()
      ..color = style.starColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.025;
    final Offset waistLeft = outline[4];
    final Offset waistRight = outline[2];
    canvas.drawLine(waistLeft, waistRight, facet);
    canvas.drawLine(outline[0], center + Offset(-r * 0.25, -r * 0.2), facet);
    canvas.drawLine(outline[1], center + Offset(r * 0.25, -r * 0.2), facet);
    canvas.drawLine(center + Offset(-r * 0.25, -r * 0.2), outline[3], facet);
    canvas.drawLine(center + Offset(r * 0.25, -r * 0.2), outline[3], facet);

    canvas.drawPath(
      gem,
      Paint()
        ..color = style.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeJoin = StrokeJoin.round,
    );

    if (style.shape == MedalShape.diamond) {
      final Paint sparkle = Paint()..color = style.starColor;
      canvas.drawPath(_star(center + Offset(-r * 0.85, -r * 0.8), s * 0.07), sparkle);
      canvas.drawPath(_star(center + Offset(r * 0.9, -r * 0.6), s * 0.05), sparkle);
    }
  }

  static Path _star(Offset center, double radius) {
    final Path path = Path();
    for (var point = 0; point < 10; point++) {
      final double r = point.isEven ? radius : radius * 0.45;
      final double angle = -math.pi / 2 + point * math.pi / 5;
      final Offset p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (point == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(MedalPainter oldDelegate) => oldDelegate.style != style;
}

/// La cinta de la medalla que lleva el niño en la celebración (HU-049): dos
/// tiras que bajan desde los lados del cuello ([neckLeft], [neckRight]) hasta
/// el disco ([discCenter], [discRadius]), como si colgara de sus hombros. Se
/// pinta debajo de la medalla, que tapa sus extremos. Todo en píxeles del
/// lienzo.
class MedalRibbonPainter extends CustomPainter {
  const MedalRibbonPainter({
    required this.neckLeft,
    required this.neckRight,
    required this.discCenter,
    required this.discRadius,
  });

  final Offset neckLeft;
  final Offset neckRight;
  final Offset discCenter;
  final double discRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = discRadius * 0.5;
    // Las tiras se juntan en V y acaban dentro del disco, que las tapa.
    final Offset leftEnd = discCenter + Offset(-discRadius * 0.15, -discRadius * 0.5);
    final Offset rightEnd = discCenter + Offset(discRadius * 0.15, -discRadius * 0.5);
    canvas.drawPath(_strip(neckLeft, leftEnd, width), Paint()..color = AppPalette.softCoral);
    canvas.drawPath(
      _strip(neckRight, rightEnd, width),
      Paint()..color = Color.alphaBlend(AppPalette.deepTeal.withValues(alpha: 0.45), AppPalette.softCoral),
    );
  }

  /// Una tira recta de [from] a [to] con el ancho [width].
  static Path _strip(Offset from, Offset to, double width) {
    final Offset along = to - from;
    final Offset across = Offset(-along.dy, along.dx) / along.distance * (width / 2);
    return Path()
      ..moveTo((from + across).dx, (from + across).dy)
      ..lineTo((to + across).dx, (to + across).dy)
      ..lineTo((to - across).dx, (to - across).dy)
      ..lineTo((from - across).dx, (from - across).dy)
      ..close();
  }

  @override
  bool shouldRepaint(MedalRibbonPainter oldDelegate) =>
      oldDelegate.neckLeft != neckLeft ||
      oldDelegate.neckRight != neckRight ||
      oldDelegate.discCenter != discCenter ||
      oldDelegate.discRadius != discRadius;
}
