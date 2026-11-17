import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Cómo se ve una medalla (HU-048): relleno, borde y estrellas grabadas. Se
/// distinguen por tres señales a la vez, no solo por el color: el oro es claro
/// y el bronce oscuro (luminosidad), y llevan 1, 2 o 3 estrellas (sin color).
/// Preparado para las medallas de gema de HU-051.
@immutable
final class MedalStyle {
  const MedalStyle({required this.fill, required this.rim, required this.stars, required this.starColor});

  final Color fill;
  final Color rim;

  /// Estrellas grabadas: 1 bronce, 2 plata, 3 oro.
  final int stars;
  final Color starColor;

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

  @override
  bool operator ==(Object other) =>
      other is MedalStyle &&
      other.fill == fill &&
      other.rim == rim &&
      other.stars == stars &&
      other.starColor == starColor;

  @override
  int get hashCode => Object.hash(fill, rim, stars, starColor);
}

/// La medalla dibujada por la app (HU-048 P1): una cinta y un disco con sus
/// estrellas. Ocupa un cuadrado de [size]; el disco tiene su centro en
/// [discCenter] y su radio es [discRadius], en fracciones del lado, para poder
/// colocarla sobre el pecho del niño (HU-049).
class MedalBadge extends StatelessWidget {
  const MedalBadge({super.key, required this.style, required this.size, this.semanticLabel});

  final MedalStyle style;
  final double size;

  /// «Medalla de bronce», etc. Sin él, la medalla es decorativa.
  final String? semanticLabel;

  static const Offset discCenter = Offset(0.5, 0.62);
  static const double discRadius = 0.36;

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

    // Cinta: dos tiras que bajan hasta el disco.
    final Paint ribbon = Paint()..color = AppPalette.softCoral;
    final Paint ribbonShade = Paint()..color = AppPalette.deepTeal.withValues(alpha: 0.55);
    canvas.drawPath(_strip(s, from: 0.30, to: 0.46), ribbon);
    canvas.drawPath(_strip(s, from: 0.70, to: 0.54), ribbonShade);

    // Disco con su borde.
    canvas.drawCircle(center, radius, Paint()..color = style.fill);
    canvas.drawCircle(
      center,
      radius - s * 0.035,
      Paint()
        ..color = style.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.07,
    );

    // Estrellas grabadas, centradas en fila.
    final int count = style.stars.clamp(1, 3);
    final double starRadius = s * (count == 1 ? 0.15 : 0.1);
    final double step = starRadius * 2.05;
    final Paint star = Paint()..color = style.starColor;
    for (var index = 0; index < count; index++) {
      final double dx = (index - (count - 1) / 2) * step;
      canvas.drawPath(_star(center + Offset(dx, 0), starRadius), star);
    }
  }

  /// Una tira de la cinta, de arriba ([from], fracción del ancho) al disco ([to]).
  static Path _strip(double s, {required double from, required double to}) {
    final double width = s * 0.16;
    return Path()
      ..moveTo(s * from - width / 2, 0)
      ..lineTo(s * from + width / 2, 0)
      ..lineTo(s * to + width / 2, s * 0.36)
      ..lineTo(s * to - width / 2, s * 0.36)
      ..close();
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
