import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/activities/activity.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../screens/activity_screen.dart';
import '../theme/app_palette.dart';
import 'activity_widgets.dart';

/// La sugerencia del día en el menú (HU-047 D1, P10): «Idea para hoy, sin
/// pantallas», el título y los minutos. Al tocarla se abre la actividad; la ✕
/// la oculta hasta mañana (P13), y se guarda el día en el perfil.
///
/// Es para el adulto: pequeña, blanca y tranquila, con el niño y el adulto en
/// el icono (P8), para que no parezca otro juego. Mientras carga, sin
/// actividades o cerrada hoy, no ocupa sitio.
class DailyActivityCard extends StatefulWidget {
  const DailyActivityCard({super.key, required this.clock, this.padding = EdgeInsets.zero});

  /// El reloj del menú (inyectable en los tests).
  final DateTime Function() clock;

  /// El hueco alrededor, solo si se ve.
  final EdgeInsetsGeometry padding;

  /// El texto acompaña: con el del sistema al máximo crece hasta 1,3, para
  /// dejar sitio a los juegos en un teléfono pequeño (HU-023 R2).
  static const double maxTextScale = 1.3;

  @override
  State<DailyActivityCard> createState() => _DailyActivityCardState();
}

class _DailyActivityCardState extends State<DailyActivityCard> {
  /// `false` hasta leer el perfil: así no aparece y desaparece al arrancar.
  bool _profileRead = false;
  DateTime? _hiddenOn;

  @override
  void initState() {
    super.initState();
    _readHiddenDay();
  }

  IPersistenceRepository? get _repository => context.read<IPersistenceRepository?>();

  Future<void> _readHiddenDay() async {
    DateTime? hiddenOn;
    try {
      hiddenOn = (await _repository?.readUserProfile())?.activityHiddenOn;
    } catch (_) {
      // Sin perfil, la tarjeta se muestra.
    }
    if (mounted) {
      setState(() {
        _hiddenOn = hiddenOn;
        _profileRead = true;
      });
    }
  }

  static DateTime _dayOf(DateTime moment) => DateTime(moment.year, moment.month, moment.day);

  Future<void> _hideUntilTomorrow() async {
    final DateTime today = _dayOf(widget.clock());
    setState(() => _hiddenOn = today);
    final IPersistenceRepository? repository = _repository;
    try {
      final UserProfile profile =
          await repository?.readUserProfile() ?? const UserProfile(isPremium: false, isSoundEnabled: true);
      await repository?.saveUserProfile(profile.copyWith(activityHiddenOn: today));
    } catch (_) {
      // Si no se guarda, vuelve a salir en el próximo arranque: nada se rompe.
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = _dayOf(widget.clock());
    final DateTime? hiddenOn = _hiddenOn;
    final bool hidden = !_profileRead || (hiddenOn != null && _dayOf(hiddenOn) == today);
    // Las actividades se cargan a la vez que se lee el perfil.
    return ActivityLibraryLoader(
      builder: (context, library) {
        final Activity? activity = library?.suggestionFor(today);
        if (hidden || library == null || activity == null) return const SizedBox.shrink();
        return Padding(
          padding: widget.padding,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: DailyActivityCard.maxTextScale,
            child: _Card(
              activity: activity,
              onOpen: () => ActivityScreen.open(context, activity, library),
              onHide: _hideUntilTomorrow,
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.activity, required this.onOpen, required this.onHide});

  final Activity activity;
  final VoidCallback onOpen;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          key: const ValueKey<String>('menu-daily-activity'),
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          shadowColor: AppPalette.deepTeal.withValues(alpha: 0.3),
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 0, 8),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom_rounded, color: AppPalette.petrolBlue, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.activitiesDailyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppPalette.deepTeal.withValues(alpha: 0.8)),
                        ),
                        Text(
                          '${activity.title} · ${l10n.activitiesMinutes(activity.minutes)}',
                          key: const ValueKey<String>('menu-daily-activity-title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey<String>('menu-daily-activity-hide'),
                    tooltip: l10n.activitiesDailyHide,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppPalette.deepTeal.withValues(alpha: 0.7),
                    onPressed: onHide,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
