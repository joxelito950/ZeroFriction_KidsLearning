import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../brand/brand_assets.dart';
import '../../domain/memory/memory_ladder.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../domain/shadows/shadow_ladder.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/game_icon.dart';
import '../widgets/liquid_gold.dart';
import '../widgets/parents_zone_button.dart';
import '../widgets/protected_exit.dart';
import '../widgets/round_style.dart';
import 'memory_game_screen.dart';
import 'shadow_game_screen.dart';

/// Menú principal súper visual y simplificado para niños de 3 años.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  /// Tiempo para el segundo toque en «Zona de Padres» (HU-004 R1, S5).
  static const Duration parentsZoneTapWindow = ParentsZoneButton.tapWindow;

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  /// Cierra la app; el gesto «atrás» del menú pide repetirlo antes (HU-001 R19).
  static void _closeApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    return ProtectedExit(
      onExit: _closeApp,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // En horizontal el alto útil es muy bajo: encabezado y botones van lado a lado.
              final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

              // El scroll es solo una red de seguridad para pantallas muy pequeñas;
              // el mínimo de alto mantiene el contenido centrado cuando sí cabe.
              return SingleChildScrollView(
                padding: _padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - _padding.vertical,
                  ),
                  child: isLandscape
                      ? const Row(
                          children: [
                            Expanded(child: _MenuHeader()),
                            SizedBox(width: 32),
                            Expanded(child: _MenuActions()),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _MenuHeader(),
                            SizedBox(height: 48),
                            _MenuActions(),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Encabezado con el logo (el personaje de identidad, HU-013) y el nombre de la app.
class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // El logo crece con la pantalla, sin pasar de 160 dp ni dejar sin sitio a
    // los botones en un teléfono pequeño en horizontal.
    final double logoSize = math.min(160, MediaQuery.sizeOf(context).shortestSide * 0.32);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decorativo: el título ya dice el nombre (HU-013, criterio 5).
        Image.asset(
          BrandAssets.logo,
          key: const ValueKey<String>('menu-logo'),
          width: logoSize,
          height: logoSize,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) => SizedBox.square(dimension: logoSize),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appTitle,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppPalette.deepTeal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.menuTagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppPalette.deepTeal.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Juego de memoria, acceso a la zona de padres y salida de la app.
class _MenuActions extends StatefulWidget {
  const _MenuActions();

  @override
  State<_MenuActions> createState() => _MenuActionsState();
}

class _MenuActionsState extends State<_MenuActions> {
  /// Progreso del juego de memoria: medalla (HU-001 R9) y dorado (HU-002).
  /// El menú solo lee lo guardado, sin calcular la pérdida (D-037).
  GameProgress _memory = GameProgress.initial();

  /// Progreso de Sombras (HU-007): medalla y dorado.
  GameProgress _shadows = GameProgress.initial();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  /// Si no se puede leer un progreso, su botón se muestra sin medalla ni dorado.
  Future<void> _loadProgress() async {
    final IPersistenceRepository repository = context.read<IPersistenceRepository>();
    GameProgress memory;
    GameProgress shadows;
    try {
      memory = await repository.readGameProgress(GameId.memory);
    } catch (_) {
      memory = GameProgress.initial();
    }
    try {
      shadows = await repository.readGameProgress(GameId.shadows);
    } catch (_) {
      shadows = GameProgress.initial();
    }
    if (!mounted || (memory == _memory && shadows == _shadows)) return;
    setState(() {
      _memory = memory;
      _shadows = shadows;
    });
  }

  /// Abre un juego y, al volver, relee el progreso: la medalla o el dorado
  /// pueden haber cambiado.
  Future<void> _open(Widget game) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => game));
    await _loadProgress();
  }

  /// La medalla del juego, sobre un círculo blanco: el dorado no contrasta con
  /// el color del botón.
  /// Con las rondas (HU-037), la medalla más alta: bronce, plata u oro.
  Widget _medal(String key, String label, GameDifficulty round) => Semantics(
        label: label,
        excludeSemantics: true,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: AppPalette.white,
          child: Icon(
            Icons.military_tech_rounded,
            key: ValueKey<String>(key),
            color: RoundStyle.colorOf(round),
            size: 30,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ButtonStyle smallButtonStyle = TextButton.styleFrom(foregroundColor: AppPalette.petrolBlue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Un solo botón: el juego retoma el nivel alcanzado (HU-001 R1).
        _MenuButton(
          title: l10n.menuMemoryTitle,
          subtitle: l10n.menuMemorySubtitle,
          // Azul petróleo: lo que se toca (PALETA.md, C6).
          backgroundColor: AppPalette.petrolBlue,
          textColor: AppPalette.white,
          icon: const GameIcon.memory(key: ValueKey<String>('menu-memory-icon'), size: 52),
          // Dorado líquido en todo el botón (HU-002 R16) y anunciado (R6).
          goldFraction: _memory.goldFraction(MemoryLadder.rounds),
          goldLabel: l10n.menuGameGoldSemantics(
            (_memory.goldFraction(MemoryLadder.rounds) * 100).round(),
            _memory.stars,
            MemoryLadder.rounds.maxStars,
          ),
          badge: switch (_memory.bestMedal) {
            final GameDifficulty medal => _medal('menu-memory-badge', RoundStyle.medalTitle(l10n, medal), medal),
            null => null,
          },
          onTap: () => _open(const MemoryGameScreen()),
        ),
        const SizedBox(height: 16),
        // Segundo juego, debajo de «Memoria» (HU-007 R1).
        _MenuButton(
          key: const ValueKey<String>('menu-shadows'),
          title: l10n.shadowsGameTitle,
          subtitle: l10n.menuShadowsSubtitle,
          // Teal profundo: se distingue del azul petróleo de la memoria.
          backgroundColor: AppPalette.deepTeal,
          textColor: AppPalette.white,
          icon: const GameIcon.shadows(key: ValueKey<String>('menu-shadows-icon'), size: 52),
          goldFraction: _shadows.goldFraction(ShadowLadder.rounds),
          goldLabel: l10n.menuGameGoldSemantics(
            (_shadows.goldFraction(ShadowLadder.rounds) * 100).round(),
            _shadows.stars,
            ShadowLadder.rounds.maxStars,
          ),
          badge: switch (_shadows.bestMedal) {
            final GameDifficulty medal => _medal('menu-shadows-badge', RoundStyle.medalTitle(l10n, medal), medal),
            null => null,
          },
          onTap: () => _open(const ShadowGameScreen()),
        ),
        const SizedBox(height: 40),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            // Doble toque y desafío para adultos (HU-004 R1).
            const ParentsZoneButton(),
            // La única salida sin confirmación (HU-001 R21).
            TextButton.icon(
              onPressed: MainMenuScreen._closeApp,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(l10n.menuExit),
              style: smallButtonStyle,
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget auxiliar para los botones interactivos del menú
class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  /// Icono del juego, delante del título (HU-013).
  final Widget? icon;

  /// Distintivo opcional junto a la flecha (la medalla de la insignia).
  final Widget? badge;

  /// Dorado del juego, de 0 a 1, y cómo lo anuncia el lector de pantalla.
  final double goldFraction;
  final String? goldLabel;

  const _MenuButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.icon,
    this.badge,
    this.goldFraction = 0,
    this.goldLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Sobre el dorado, el blanco queda en 4,40:1: una sombra suave en teal
    // profundo lo mantiene legible a cualquier altura del líquido (P13).
    final List<Shadow>? shadows =
        goldFraction > 0 ? [Shadow(color: AppPalette.deepTeal.withValues(alpha: 0.6), blurRadius: 4)] : null;

    return Semantics(
      value: goldLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppPalette.deepTeal.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: LiquidGold(fraction: goldFraction)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (icon case final Widget icon) ...[icon, const SizedBox(width: 14)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              shadows: shadows,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withValues(alpha: goldFraction > 0 ? 1 : 0.8),
                              shadows: shadows,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (badge case final Widget badge) ...[badge, const SizedBox(width: 8)],
                    Icon(
                      Icons.chevron_right_rounded,
                      color: textColor,
                      size: 28,
                      shadows: shadows,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
