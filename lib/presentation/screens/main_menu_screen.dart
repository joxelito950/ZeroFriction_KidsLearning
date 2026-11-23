import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../brand/brand_assets.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/news/discovery.dart';
import '../../domain/news/edition_check.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/daily_activity_card.dart';
import '../widgets/game_catalog.dart';
import '../widgets/game_grid.dart';
import '../widgets/liquid_gold.dart';
import '../widgets/parents_setting_page.dart';
import '../widgets/parents_zone_button.dart';
import '../widgets/protected_exit.dart';
import '../widgets/medal_badge.dart';
import '../widgets/round_style.dart';

/// Menú principal súper visual y simplificado para niños de 3 años.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  /// Tiempo para el segundo toque en «Zona de Padres» (HU-004 R1, S5).
  static const Duration parentsZoneTapWindow = ParentsZoneButton.tapWindow;

  /// El reloj de las ediciones especiales (HU-042); los tests lo cambian.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  /// Cierra la app; el gesto «atrás» del menú pide repetirlo antes (HU-001 R19).
  static void _closeApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    return ProtectedExit(
      onExit: _closeApp,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: _padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // En horizontal el alto útil es muy bajo: encabezado y juegos van
                // lado a lado. La cuadrícula ocupa el alto que queda (HU-023).
                final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
                // La idea del día (HU-047 D1) va entre el logo y los juegos; en
                // horizontal, debajo del logo, en la columna que se desplaza, y
                // con ella el acceso a la sección: en el pie, un tercer botón
                // pasaba a otra fila y dejaba los juegos sin sitio (HU-023 R2).
                return isLandscape
                    ? Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const _MenuHeader(),
                                  DailyActivityCard(
                                      clock: MainMenuScreen.clock, padding: const EdgeInsets.only(top: 16)),
                                  const SizedBox(height: 8),
                                  MediaQuery.withClampedTextScaling(
                                    maxScaleFactor: _MenuHeader.maxTaglineScale,
                                    child: const ActivitiesButton(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(child: _MenuActions(minColumns: 1, withActivities: false)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _MenuHeader(),
                          const SizedBox(height: 16),
                          DailyActivityCard(clock: MainMenuScreen.clock, padding: const EdgeInsets.only(bottom: 16)),
                          const SizedBox(height: 16),
                          const Flexible(child: _MenuActions(minColumns: 2)),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado con el logo (el personaje de identidad, HU-013) y el nombre de la app.
class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  /// El lema acompaña: con el texto del sistema al máximo crece hasta 1,5.
  static const double maxTaglineScale = 1.5;

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
        // El nombre, en una línea: con el texto al máximo en un teléfono
        // estrecho se partía en tres y no dejaba sitio a los juegos (HU-023 R2).
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.appTitle,
            maxLines: 1,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppPalette.deepTeal,
            ),
          ),
        ),
        const SizedBox(height: 4),
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: _MenuHeader.maxTaglineScale,
          child: Text(
            l10n.menuTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppPalette.deepTeal.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Los juegos en cuadrícula (HU-023), el acceso a la zona de padres y la
/// salida de la app.
class _MenuActions extends StatefulWidget {
  const _MenuActions({required this.minColumns, this.withActivities = true});

  /// En vertical, al menos 2 columnas (HU-023 3.1).
  final int minColumns;

  /// El acceso a las actividades sin pantallas va en el pie (HU-047 D2); en
  /// horizontal, debajo de la idea del día.
  final bool withActivities;

  @override
  State<_MenuActions> createState() => _MenuActionsState();
}

class _MenuActionsState extends State<_MenuActions> {
  /// Progreso de cada juego: medalla (HU-037) y dorado (HU-002). El menú solo
  /// lee lo guardado, sin calcular la pérdida (D-037).
  Map<GameId, GameProgress> _progress = const {};

  /// Lo que ya descubrió el niño (HU-041) y los juegos con su edición abierta
  /// (HU-042).
  Discovery _discovery = Discovery.allSeen();
  Set<GameId> _editions = const {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  /// Si no se puede leer un progreso, su tarjeta se muestra sin medalla ni dorado.
  Future<void> _loadProgress() async {
    final IPersistenceRepository repository = context.read<IPersistenceRepository>();
    final Map<GameId, GameProgress> progress = {};
    for (final MenuGame game in GameCatalog.all) {
      try {
        progress[game.id] = await repository.readGameProgress(game.id);
      } catch (_) {
        progress[game.id] = GameProgress.initial();
      }
    }
    // La fecha más alta vista solo la guarda el menú (HU-042 R7).
    final Set<GameId> editions = await EditionCheck.refresh(repository, now: MainMenuScreen.clock());
    Discovery discovery = _discovery;
    try {
      discovery = (await repository.readUserProfile())?.discovered ?? Discovery.allSeen();
    } catch (_) {
      // Sin perfil, nada se destaca.
    }
    if (!mounted || (mapEquals(progress, _progress) && setEquals(editions, _editions) && discovery == _discovery)) {
      return;
    }
    setState(() {
      _progress = progress;
      _editions = editions;
      _discovery = discovery;
    });
  }

  /// Abre un juego y, al volver, relee el progreso: la medalla o el dorado
  /// pueden haber cambiado.
  Future<void> _open(MenuGame game) async {
    final IPersistenceRepository repository = context.read<IPersistenceRepository>();
    unawaited(_recordOpen(repository, game.id));
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => game.screen()));
    await _loadProgress();
  }

  /// Cuenta la apertura para HU-041 (un juego nuevo se destaca hasta abrirlo
  /// tres veces). Si falla, el juego se abre igual.
  static Future<void> _recordOpen(IPersistenceRepository repository, GameId id) async {
    try {
      final UserProfile profile =
          await repository.readUserProfile() ?? const UserProfile(isPremium: false, isSoundEnabled: true);
      final Discovery next = profile.discovered.openedGame(id);
      if (next != profile.discovered) await repository.saveUserProfile(profile.copyWith(discovery: next));
    } catch (_) {
      // Solo se pierde una cuenta: nunca bloquea el juego.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ButtonStyle smallButtonStyle = TextButton.styleFrom(foregroundColor: AppPalette.petrolBlue);
    final List<MenuGame> games = GameCatalog.all;

    // Juntos y centrados: la cuadrícula ocupa lo que necesita, como mucho el
    // alto que queda.
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: GameGrid(
            count: games.length,
            minColumns: widget.minColumns,
            cardBuilder: (context, index, side) {
              final MenuGame game = games[index];
              final GameProgress progress = _progress[game.id] ?? GameProgress.initial();
              return _GameCard(
                game: game,
                progress: progress,
                isNew: _discovery.isNewGame(game.id, progress),
                festive: _editions.contains(game.id),
                side: side,
                onTap: () => _open(game),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Botones pequeños para el adulto: con el texto al máximo crecen hasta
        // 1,5 para caber en una fila y dejar sitio a las tarjetas (HU-023 R2).
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: _MenuHeader.maxTaglineScale,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              // Ideas para jugar sin pantalla, sin desafío (HU-047 D2, P8).
              if (widget.withActivities) const ActivitiesButton(),
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
        ),
      ],
    );
  }
}

/// La tarjeta de un juego (HU-023 R1): su icono grande, su nombre debajo en
/// letra pequeña para el adulto, el dorado llenándola de abajo arriba (HU-002
/// R16) y la medalla más alta en la esquina (HU-037). Toda se puede tocar.
class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.progress,
    required this.side,
    required this.onTap,
    this.isNew = false,
    this.festive = false,
  });

  final MenuGame game;
  final GameProgress progress;
  final double side;
  final VoidCallback onTap;

  /// «Nuevo» hasta abrirlo tres veces o superar la plata (HU-023 R7, HU-041).
  final bool isNew;

  /// Edición especial abierta: un 🎄 en la esquina, sin texto ni precio (R8).
  final bool festive;

  /// El adorno de la edición de Navidad.
  static const String festiveSymbol = '🎄';

  /// El nombre es para el adulto: con el texto del sistema al máximo, crece
  /// hasta 1,6 veces para no tapar el icono, que es lo que reconoce el niño.
  static const double maxTitleScale = 1.6;

  /// Parte del alto libre que ocupa el icono (visto en el moto g55: a tamaño
  /// completo, la medalla pisaba el icono).
  static const double iconShare = 0.85;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final double gold = progress.goldFraction(game.rounds);
    final String title = game.title(l10n);
    // Sobre el dorado, el blanco queda en 4,40:1: una sombra suave en teal
    // profundo lo mantiene legible a cualquier altura del líquido (HU-002 P13).
    final List<Shadow>? shadows =
        gold > 0 ? [Shadow(color: AppPalette.deepTeal.withValues(alpha: 0.6), blurRadius: 4)] : null;
    final double medalRadius = (side * 0.13).clamp(14.0, 26.0);
    final GameDifficulty? medal = progress.bestMedal;

    return Semantics(
      button: true,
      label: isNew ? '$title, ${l10n.newBadge}' : title,
      value: l10n.menuGameGoldSemantics((gold * 100).round(), progress.stars, game.rounds.maxStars),
      excludeSemantics: true,
      child: Material(
        key: ValueKey<String>('menu-${game.keyName}'),
        color: game.background,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: AppPalette.deepTeal.withValues(alpha: 0.4),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(child: LiquidGold(fraction: gold)),
              Padding(
                padding: EdgeInsets.fromLTRB(10, side * 0.1, 10, 10),
                child: Column(
                  children: [
                    // Al 85 % del hueco: la esquina queda libre para la medalla.
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: iconShare,
                        child: FittedBox(
                          child: game.icon(ValueKey<String>('menu-${game.keyName}-icon'), side * 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: maxTitleScale,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                          color: game.foreground,
                          shadows: shadows,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: NewBadge(key: ValueKey<String>('menu-${game.keyName}-new'), label: l10n.newBadge),
                ),
              if (festive)
                PositionedDirectional(
                  bottom: side * 0.22,
                  end: 8,
                  child: Text(
                    festiveSymbol,
                    key: ValueKey<String>('menu-${game.keyName}-festive'),
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(fontSize: (side * 0.16).clamp(18.0, 30.0)),
                  ),
                ),
              if (medal != null)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  // La medalla, sobre un círculo blanco: el dorado no contrasta
                  // con el color de la tarjeta (HU-048).
                  child: CircleAvatar(
                    radius: medalRadius,
                    backgroundColor: AppPalette.white,
                    child: MedalBadge(
                      key: ValueKey<String>('menu-${game.keyName}-badge'),
                      style: RoundStyle.medalStyleOf(medal),
                      size: medalRadius * 1.8,
                      semanticLabel: RoundStyle.medalTitle(l10n, medal),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
