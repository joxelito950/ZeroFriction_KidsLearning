import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/activities/activity.dart';
import '../../l10n/app_localizations.dart';
import '../screens/activities_screen.dart';
import '../screens/activity_screen.dart';
import '../theme/app_palette.dart';

/// Carga las actividades sin pantallas (HU-047) en el idioma de la app y las
/// vuelve a cargar si el idioma cambia. Mientras cargan, o si no hay de dónde
/// sacarlas, [builder] recibe `null`.
class ActivityLibraryLoader extends StatefulWidget {
  const ActivityLibraryLoader({super.key, required this.builder});

  final Widget Function(BuildContext context, ActivityLibrary? library) builder;

  @override
  State<ActivityLibraryLoader> createState() => _ActivityLibraryLoaderState();
}

class _ActivityLibraryLoaderState extends State<ActivityLibraryLoader> {
  IActivitySource? _source;
  String? _language;
  ActivityLibrary? _library;

  @override
  void initState() {
    super.initState();
    _source = context.read<IActivitySource?>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    _load(language);
  }

  Future<void> _load(String language) async {
    final IActivitySource? source = _source;
    if (source == null) return;
    try {
      final ActivityLibrary library = await source.load(language);
      if (mounted && _language == language) setState(() => _library = library);
    } catch (_) {
      // Sin actividades, la tarjeta del día no sale y la sección queda vacía.
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _library);
}

/// «Categoría · 10 min»: lo que se ve de una actividad junto a su título.
String activityMeta(AppLocalizations l10n, Activity activity) =>
    '${l10n.activitiesCategory(activity.category.name)} · ${l10n.activitiesMinutes(activity.minutes)}';

/// Una actividad en una lista: título, categoría, minutos y los primeros
/// materiales. Al tocarla se abre su pantalla (HU-047 D3).
class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, required this.library});

  final Activity activity;
  final ActivityLibrary library;

  /// Cuántos materiales se adelantan en la tarjeta.
  static const int shownMaterials = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: ValueKey<String>('activity-card-${activity.id}'),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 6, 8, 6),
        title: Text(activity.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              activityMeta(l10n, activity),
              style: theme.textTheme.bodyMedium?.copyWith(color: AppPalette.petrolBlue, fontWeight: FontWeight.w600),
            ),
            if (activity.materials.isNotEmpty)
              Text(
                activity.materials.take(shownMaterials).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        // La flecha sigue la dirección del texto (árabe, RTL).
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => ActivityScreen.open(context, activity, library),
      ),
    );
  }
}

/// El acceso a «Actividades sin pantallas» (HU-047 D2, D4): en el pie del menú
/// y en la pantalla de descanso. Sin desafío (P8): no cambia ni compra nada.
class ActivitiesButton extends StatelessWidget {
  const ActivitiesButton({
    super.key,
    this.buttonKey = const ValueKey<String>('menu-activities'),
    this.foregroundColor = AppPalette.petrolBlue,
    this.iconSize = 18,
  });

  final Key buttonKey;

  /// Azul petróleo sobre crema; crema sobre la pantalla de noche (HU-038 R3).
  final Color foregroundColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      key: buttonKey,
      onPressed: () => ActivitiesScreen.open(context),
      icon: Icon(Icons.lightbulb_outline_rounded, size: iconSize),
      label: Text(l10n.activitiesTitle),
      style: TextButton.styleFrom(foregroundColor: foregroundColor),
    );
  }
}

/// Un aviso para el adulto en una caja ámbar suave, como el resto de avisos
/// informativos de la app (HU-047 D6).
class ActivityNotice extends StatelessWidget {
  const ActivityNotice({super.key, required this.text, this.title, this.icon = Icons.health_and_safety_outlined});

  final String text;
  final String? title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: AppPalette.deepTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title case final String title)
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(text, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
