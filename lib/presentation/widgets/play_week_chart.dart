import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/parental/progress_summary.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

/// Gráfico de barras de la semana de «Su progreso» (HU-034 §4.3): 7 columnas en
/// el orden del idioma, hoy y los 5 días anteriores con su barra y el día
/// siguiente a hoy como hueco. Esta semana en teal profundo; la pasada, en teal
/// con transparencia (C2). Sin línea del límite ni colores de aviso. En árabe
/// la fila se invierte sola (R6).
class PlayWeekChart extends StatelessWidget {
  const PlayWeekChart({super.key, required this.slots});

  final List<WeekSlot> slots;

  /// Alto de la barra más larga.
  static const double barArea = 96;

  /// Duración legible: «12 min» o «1 h 10 min».
  static String duration(AppLocalizations l10n, Duration played) {
    final int minutes = played.inMinutes;
    if (minutes < 60) return l10n.parentsZonePlayTimeMinutes(minutes);
    return l10n.parentsProgressHoursMinutes(minutes ~/ 60, minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int most = slots.fold(1, (most, slot) => math.max(most, slot.played.inMinutes));
    return Row(
      key: const ValueKey<String>('play-week-chart'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (int index, WeekSlot slot) in slots.indexed)
          Expanded(child: _Column(key: ValueKey<String>('week-slot-$index'), slot: slot, most: most, l10n: l10n)),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({super.key, required this.slot, required this.most, required this.l10n});

  final WeekSlot slot;
  final int most;
  final AppLocalizations l10n;

  String _label(String locale) {
    final String day = DateFormat.EEEE(locale).format(slot.day);
    final String time = PlayWeekChart.duration(l10n, slot.played);
    if (slot.isToday) return l10n.parentsProgressBarToday(day, time);
    return slot.currentWeek ? l10n.parentsProgressBarThisWeek(day, time) : l10n.parentsProgressBarLastWeek(day, time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String locale = l10n.localeName;
    final int minutes = slot.played.inMinutes;
    final Color barColor = slot.currentWeek ? AppPalette.deepTeal : AppPalette.deepTeal.withValues(alpha: 0.4);
    final TextStyle? small = theme.textTheme.labelSmall?.copyWith(color: AppPalette.deepTeal);

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Los minutos encima de cada barra; el hueco no lleva nada.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(slot.isGap || minutes == 0 ? '' : '$minutes', style: small),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: PlayWeekChart.barArea,
          child: slot.isGap
              ? const Center(child: CustomPaint(size: Size(2, PlayWeekChart.barArea), painter: _DashedLine()))
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(
                      key: ValueKey<String>(slot.currentWeek ? 'week-bar-current' : 'week-bar-last'),
                      height: minutes == 0 ? 0 : math.max(3, PlayWeekChart.barArea * minutes / most),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            DateFormat.E(locale).format(slot.day),
            style: small?.copyWith(fontWeight: slot.isToday ? FontWeight.w900 : FontWeight.normal),
          ),
        ),
      ],
    );
    // El hueco no se lee (R5); cada barra se lee como una frase.
    if (slot.isGap) return ExcludeSemantics(child: column);
    return Semantics(container: true, label: _label(locale), excludeSemantics: true, child: column);
  }
}

/// Línea fina punteada del hueco.
class _DashedLine extends CustomPainter {
  const _DashedLine();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppPalette.deepTeal.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;
    const double dash = 4;
    for (double y = 0; y < size.height; y += dash * 2) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, math.min(y + dash, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLine oldDelegate) => false;
}
