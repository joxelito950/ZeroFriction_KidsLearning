import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../brand/brand_assets.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/parents_zone_button.dart';
import '../widgets/protected_exit.dart';

/// Pantalla de descanso (HU-009 R5, R6): tranquila, sin cuenta atrás, sin rojo
/// y sin acceso a los juegos. Solo deja entrar a la Zona de Padres (doble toque
/// y desafío), donde un adulto puede dar 15 minutos más. El «atrás» se protege
/// como en el menú (D-025).
class RestScreen extends StatelessWidget {
  const RestScreen({super.key});

  static void _closeApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ProtectedExit(
      onExit: _closeApp,
      child: Scaffold(
        key: const ValueKey<String>('rest-screen'),
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
                      BrandAssets.childResting,
                      key: const ValueKey<String>('rest-illustration'),
                      width: math.min(200, MediaQuery.sizeOf(context).shortestSide * 0.4),
                      height: math.min(200, MediaQuery.sizeOf(context).shortestSide * 0.4),
                      excludeFromSemantics: true,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.bedtime_rounded, size: 96, color: AppPalette.deepTeal.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.restTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPalette.deepTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.restSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: AppPalette.deepTeal.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 40),
                    const ParentsZoneButton(buttonKey: ValueKey<String>('rest-parents-zone')),
                    const SizedBox(height: 12),
                    // Salida directa, como en el menú: al llegar al límite el
                    // adulto puede cerrar la app sin pasar por la Zona de Padres.
                    TextButton.icon(
                      key: const ValueKey<String>('rest-exit'),
                      onPressed: _closeApp,
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
