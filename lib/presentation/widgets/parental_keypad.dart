import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Teclado numérico propio del desafío (HU-004 R3): las 10 cifras en el orden de
/// [digits], más «borrar» y «aceptar». Ocupa el espacio que se le da, con una
/// proporción fija para que las teclas sean grandes.
class ParentalKeypad extends StatelessWidget {
  const ParentalKeypad({
    super.key,
    required this.digits,
    required this.onDigit,
    required this.onDelete,
    required this.onAccept,
    required this.canAccept,
  });

  /// Las cifras del 0 al 9 en el orden en que se muestran.
  final List<int> digits;
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onAccept;
  final bool canAccept;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Widget> keys = [
      for (final digit in digits.take(9)) _digitKey(digit),
      _KeypadKey(
        key: const ValueKey<String>('parental-key-delete'),
        onTap: onDelete,
        child: Icon(Icons.backspace_outlined, semanticLabel: l10n.parentalGateDelete),
      ),
      _digitKey(digits[9]),
      _KeypadKey(
        key: const ValueKey<String>('parental-key-accept'),
        onTap: canAccept ? onAccept : null,
        filled: true,
        child: Text(l10n.parentalGateAccept),
      ),
    ];

    return AspectRatio(
      aspectRatio: 1.15,
      child: Column(
        children: [
          for (var row = 0; row < 4; row++) ...[
            if (row > 0) const SizedBox(height: _gap),
            Expanded(
              child: Row(
                children: [
                  for (var column = 0; column < 3; column++) ...[
                    if (column > 0) const SizedBox(width: _gap),
                    Expanded(child: keys[row * 3 + column]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _digitKey(int digit) {
    return _KeypadKey(
      key: ValueKey<String>('parental-key-$digit'),
      onTap: () => onDigit(digit),
      child: Text('$digit'),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    super.key,
    required this.child,
    required this.onTap,
    this.filled = false,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// La tecla «aceptar» va rellena con el color principal.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ButtonStyle base = filled
        ? FilledButton.styleFrom()
        : FilledButton.styleFrom(
            backgroundColor: colors.surfaceContainerHighest,
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.outline),
          );
    final ButtonStyle style = base.copyWith(
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
    );

    return SizedBox.expand(
      child: FilledButton(
        onPressed: onTap,
        style: style,
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }
}
