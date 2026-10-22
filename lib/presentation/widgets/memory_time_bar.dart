import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Tiempo restante como una barra que se vacía (HU-001 R16, D-021): sin números,
/// sin rojo, sin parpadeos. Se vacía hacia el inicio del sentido de lectura, así
/// que en árabe (RTL) lo hace al revés.
class MemoryTimeBar extends StatelessWidget {
  const MemoryTimeBar({super.key, required this.fraction});

  /// 1 = tiempo completo, 0 = agotado.
  final double fraction;

  static const Color _fill = Color(0xFF38BDF8);
  static const Color _track = Color(0x3338BDF8);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).memoryTimeBarSemantics,
      child: Container(
        key: const ValueKey<String>('memory-time-bar'),
        height: 12,
        decoration: BoxDecoration(color: _track, borderRadius: BorderRadius.circular(6)),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AnimatedFractionallySizedBox(
            key: const ValueKey<String>('memory-time-bar-fill'),
            duration: const Duration(milliseconds: 100),
            widthFactor: fraction.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: _fill, borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
      ),
    );
  }
}
