import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'adult_session_guard.dart';

/// Fila de la Zona de Padres (HU-046 §4.1): icono, título y lo que está
/// elegido. Al tocarla se abre su pantalla de configuración.
class ParentsSettingRow extends StatelessWidget {
  const ParentsSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.onTap,
    this.dot = false,
  });

  final IconData icon;
  final String title;
  final String summary;
  final VoidCallback onTap;

  /// Un punto discreto junto a la flecha: hay algo que mirar dentro (HU-034
  /// P8). Azul petróleo, nunca un color de alarma.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(summary, style: theme.textTheme.bodyMedium),
        // La flecha sigue la dirección del texto (árabe, RTL).
        trailing: dot
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    key: ValueKey<String>('parents-row-dot'),
                    decoration: BoxDecoration(color: AppPalette.petrolBlue, shape: BoxShape.circle),
                    child: SizedBox.square(dimension: 10),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded),
                ],
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

/// Pantalla de configuración de una opción (HU-046 §4.2). Con [onSave], tiene
/// «Guardar», activo solo con cambios ([dirty], R2); al salir con cambios sin
/// guardar se pregunta (R3). Sin [onSave] es de solo lectura (R6). Va dentro de
/// [AdultSessionGuard]: si se cierra la sesión, lo no guardado se descarta (R5).
/// Nunca abre otra pantalla (R4).
class ParentsSettingPage extends StatelessWidget {
  const ParentsSettingPage({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.dirty = false,
  });

  final String title;
  final Widget child;

  /// Aplica el borrador y dice si se guardó: con un valor no válido, la
  /// pantalla sigue abierta. `null` en las pantallas de solo lectura.
  final Future<bool> Function()? onSave;
  final bool dirty;

  /// Abre [page] encima de la Zona de Padres.
  static Future<void> open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _save(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    if (await onSave!() && navigator.mounted) navigator.pop();
  }

  Future<void> _askBeforeLeaving(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final bool? save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey<String>('parents-unsaved-dialog'),
        title: Text(l10n.parentsUnsavedTitle),
        actions: [
          TextButton(
            key: const ValueKey<String>('parents-unsaved-discard'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.parentsDiscard),
          ),
          FilledButton(
            key: const ValueKey<String>('parents-unsaved-save'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.parentsSave),
          ),
        ],
      ),
    );
    if (save == null || !navigator.mounted) return;
    if (save && !await onSave!()) return;
    if (navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool editable = onSave != null;

    return AdultSessionGuard(
      child: PopScope(
        canPop: !(editable && dirty),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _askBeforeLeaving(context);
        },
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(16), children: [child]),
          ),
          bottomNavigationBar: editable
              // Por encima del teclado: al escribir un límite propio, «Guardar»
              // quedaba tapado (visto en el moto g55 el 2026-11-16).
              ? SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
                    child: FilledButton.icon(
                      key: const ValueKey<String>('parents-setting-save'),
                      onPressed: dirty ? () => _save(context) : null,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.parentsSave),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
