import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../brand/brand_assets.dart';
import '../../domain/parental/rest_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/parents_zone_button.dart';
import '../widgets/protected_exit.dart';

/// Pantalla de descanso (HU-009 R5, R6): tranquila, sin cuenta atrás, sin rojo
/// y sin acceso a los juegos. Deja entrar a la Zona de Padres (doble toque y
/// desafío), donde un adulto puede dar 15 minutos más, y a las actividades sin
/// pantallas (HU-047 D4). El «atrás» se protege
/// como en el menú (D-025).
///
/// Con [kind], es la versión de la hora de dormir (HU-038 R3): el niño dormido
/// bajo la luna, fondo teal profundo y textos en crema; «¡A dormir!» por la
/// noche y «¡A descansar!» en la siesta.
class RestScreen extends StatelessWidget {
  const RestScreen({super.key, this.kind});

  /// `null`: el límite diario (HU-009).
  final RestKind? kind;

  static void _closeApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final RestKind? kind = this.kind;
    final bool night = kind != null;
    final Color ink = night ? AppPalette.warmCream : AppPalette.deepTeal;
    final (String title, String subtitle) = switch (kind) {
      RestKind.night => (l10n.restNightTitle, l10n.restNightSubtitle),
      RestKind.nap => (l10n.restNapTitle, l10n.restNapSubtitle),
      null => (l10n.restTitle, l10n.restSubtitle),
    };

    return ProtectedExit(
      onExit: _closeApp,
      child: Scaffold(
        key: const ValueKey<String>('rest-screen'),
        backgroundColor: night ? AppPalette.deepTeal : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                // Todo el ancho: en el moto g55 la columna tomaba solo el ancho del
                // título y quedaba pegada al inicio en vez de centrada.
                constraints: BoxConstraints(minWidth: constraints.maxWidth - 48, minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // El niño descansando con su osito (PROMPTS §11), decorativo:
                    // el título ya lo dice. Crece con la pantalla sin pasar de
                    // 200 dp ni dejar sin sitio a los botones en horizontal.
                    Image.asset(
                      night ? BrandAssets.childSleeping : BrandAssets.childResting,
                      key: ValueKey<String>(night ? 'rest-illustration-night' : 'rest-illustration'),
                      width: math.min(200, MediaQuery.sizeOf(context).shortestSide * 0.4),
                      height: math.min(200, MediaQuery.sizeOf(context).shortestSide * 0.4),
                      excludeFromSemantics: true,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.bedtime_rounded, size: 96, color: ink.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: ink.withValues(alpha: night ? 0.9 : 0.8)),
                    ),
                    const SizedBox(height: 40),
                    ParentsZoneButton(
                      buttonKey: const ValueKey<String>('rest-parents-zone'),
                      foregroundColor: night ? AppPalette.warmCream : AppPalette.petrolBlue,
                    ),
                    const SizedBox(height: 12),
                    // Las ideas sin pantalla se abren en todo momento, también
                    // de noche, en la siesta o con el límite superado (HU-047 D4).
                    ActivitiesButton(
                      buttonKey: const ValueKey<String>('rest-activities'),
                      foregroundColor: night ? AppPalette.warmCream : AppPalette.petrolBlue,
                      iconSize: null,
                    ),
                    const SizedBox(height: 12),
                    // Salida directa, como en el menú: al llegar al límite el
                    // adulto puede cerrar la app sin pasar por la Zona de Padres.
                    TextButton.icon(
                      key: const ValueKey<String>('rest-exit'),
                      onPressed: _closeApp,
                      style: night ? TextButton.styleFrom(foregroundColor: AppPalette.warmCream) : null,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.menuExit),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
