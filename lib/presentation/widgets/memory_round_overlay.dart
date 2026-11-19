import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../brand/brand_assets.dart';
import '../../domain/memory/memory_ladder.dart';
import '../../domain/memory/memory_stars.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'medal_badge.dart';
import 'round_style.dart';

/// Celebración al ganar un tablero (HU-001 R14, D-030): sin botones, desaparece
/// sola. Es igual de alegre con cualquier número de estrellas; las que faltan se
/// ven como contorno suave. Al conseguir la insignia, la celebración es dorada.
class MemoryCelebration extends StatelessWidget {
  const MemoryCelebration({
    super.key,
    required this.stars,
    required this.badgeEarned,
    this.medal,
    this.message,
    this.festive = false,
  });

  final int stars;
  final bool badgeEarned;

  /// Frase propia del juego al ganar un nivel (¿Cuál es diferente? no busca
  /// parejas). Sin ella, la de la memoria.
  final String? message;

  /// Ronda completada (HU-037): bronce, plata u oro. Sin ella, la insignia de
  /// siempre.
  final GameDifficulty? medal;

  /// Edición de Navidad (HU-052 sección 6): los regalos que dejaron los
  /// vehículos, junto al árbol.
  final bool festive;

  /// El árbol y los regalos de la celebración de Navidad.
  static const String festiveSymbols = '🎁🎄🎁';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final GameDifficulty? round = medal;
    final Color medalColor = round == null ? AppPalette.gold : RoundStyle.colorOf(round);

    return _OverlayCard(
      key: ValueKey<String>(
        round != null ? 'medal-celebration-${round.name}' : (badgeEarned ? 'memory-badge-celebration' : 'memory-celebration'),
      ),
      color: AppPalette.white,
      borderColor: badgeEarned ? medalColor : AppPalette.amber,
      borderWidth: badgeEarned ? 4 : 2,
      children: [
        // Medalla de ronda: el niño celebrando con ella en el pecho (HU-049).
        // Celebración de nivel: la copa de siempre (HU-049 P1).
        if (round != null)
          CelebratingChild(medal: RoundStyle.medalStyleOf(round))
        else
          Icon(
            Icons.emoji_events_rounded,
            size: 56,
            color: badgeEarned ? medalColor : AppPalette.softCoral,
          ),
        if (festive)
          const ExcludeSemantics(
            child: Text(
              festiveSymbols,
              key: ValueKey<String>('celebration-festive'),
              textScaler: TextScaler.noScaling,
              style: TextStyle(fontSize: 36, height: 1.2),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          round != null ? RoundStyle.medalTitle(l10n, round) : (badgeEarned ? l10n.memoryBadgeTitle : l10n.victoryTitle),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          round != null
              ? RoundStyle.medalMessage(l10n, round)
              : (badgeEarned ? l10n.memoryBadgeMessage : message ?? l10n.victoryMessage),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Semantics(
          label: l10n.memoryStarsSemantics(stars, MemoryStars.max),
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < MemoryStars.max; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _AnimatedStar(index: index, earned: index < stars),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Aviso de «se acabó el tiempo» (HU-001 R15, D-021): mensaje de ayuda, nunca de
/// castigo; sin botones ni sonido, y desaparece solo.
class MemoryTimeUpNotice extends StatelessWidget {
  const MemoryTimeUpNotice({super.key, required this.loss, this.fewerMessage});

  final MemoryLoss loss;

  /// Mensaje propio del juego al bajar de nivel (Sombras habla de dibujos, no
  /// de cartas). Sin él, el de la memoria.
  final String? fewerMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _OverlayCard(
      key: const ValueKey<String>('memory-time-up'),
      color: AppPalette.white,
      borderColor: AppPalette.deepTeal.withValues(alpha: 0.3),
      children: [
        const Icon(Icons.hourglass_bottom_rounded, size: 48, color: AppPalette.deepTeal),
        const SizedBox(height: 12),
        Text(
          switch (loss) {
            MemoryLoss.restart => l10n.memoryTimeUpRestart,
            MemoryLoss.easierRound => l10n.roundEasierMessage,
            MemoryLoss.fewerCards => fewerMessage ?? l10n.memoryTimeUpFewerCards,
          },
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Invitación a jugar tras el tutorial de cada ronda (HU-037 R9): sin
/// estrellas ni botones, desaparece sola. La mano de HU-022 da el «¡vamos!».
class PlayInvitation extends StatelessWidget {
  const PlayInvitation({super.key, required this.round});

  /// Ronda que empieza: da color al aviso (P8).
  final GameDifficulty round;

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      key: const ValueKey<String>('play-invitation'),
      color: AppPalette.white,
      borderColor: RoundStyle.colorOf(round),
      borderWidth: 3,
      children: [
        // El niño invitando (HU-049), en lugar de la mano del sistema. En
        // árabe se refleja para señalar hacia el lado del contenido.
        Transform.flip(
          flipX: Directionality.of(context) == TextDirection.rtl,
          child: Image.asset(
            BrandAssets.childInviting,
            key: const ValueKey<String>('play-invitation-child'),
            height: CelebratingChild.height,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.touch_app_rounded, size: 56, color: RoundStyle.colorOf(round)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).roundInvitationTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// El niño celebrando entre confeti con la medalla de la ronda sobre el pecho
/// (HU-049). La ilustración trae un hueco transparente en el pecho; la medalla
/// se coloca con su disco centrado en él y un poco más grande, para taparlo.
/// Sin cinta: dibujada encima no seguía el cuello del niño, que no está del todo
/// de frente (visto en la prueba cerrada, 2026-11-19).
class CelebratingChild extends StatelessWidget {
  const CelebratingChild({super.key, required this.medal});

  final MedalStyle medal;

  /// Alto de la ilustración en la tarjeta: cabe con la tarjeta reducida.
  static const double height = 180;

  /// Proporción de la ilustración (390 × 480 px).
  static const double aspect = 390 / 480;

  /// Centro y radio del hueco del pecho, en fracciones del ancho y del alto de
  /// la ilustración (medidos en `assets/brand/child_celebrating.png`).
  static const Offset holeCenter = Offset(0.5385, 0.5344);
  static const double holeRadius = 0.0949;

  /// La medalla tapa el hueco con un 15 % de margen.
  static double get medalSize => holeRadius * 1.15 / MedalBadge.discRadius * height * aspect;

  @override
  Widget build(BuildContext context) {
    const double width = height * aspect;
    final double size = medalSize;
    return SizedBox(
      key: const ValueKey<String>('celebrating-child'),
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(BrandAssets.childCelebrating, fit: BoxFit.fill, excludeFromSemantics: true),
          ),
          Positioned(
            left: holeCenter.dx * width - MedalBadge.discCenter.dx * size,
            top: holeCenter.dy * height - MedalBadge.discCenter.dy * size,
            child: MedalBadge(key: const ValueKey<String>('celebrating-child-medal'), style: medal, size: size),
          ),
        ],
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({
    super.key,
    required this.color,
    required this.borderColor,
    this.borderWidth = 2,
    required this.children,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;
  final List<Widget> children;

  static const double _margin = 24;
  static const double _maxWidth = 420;

  @override
  Widget build(BuildContext context) {
    // Si no cabe (teléfono en horizontal, textos largos), el aviso se reduce
    // en lugar de desplazarse: desaparece solo y el niño no lo va a mover, así
    // que las estrellas nunca deben quedar fuera de la pantalla.
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.all(_margin),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: math.min(_maxWidth, constraints.maxWidth - 2 * _margin),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: color,
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: [
                  BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  const _AnimatedStar({required this.index, required this.earned});

  final int index;
  final bool earned;

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  // Sufijos de las claves de test de cada estrella.
  static const String _earnedKey = 'earned';
  static const String _emptyKey = 'empty';

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Curve curve = [Curves.easeInOut, Curves.easeInOutCubic, Curves.easeInOutBack][widget.index % 3];
    final double beginScale = [0.9, 0.82, 0.88][widget.index % 3];
    final animation = CurvedAnimation(parent: _controller, curve: curve);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double t = animation.value;
        return Transform.translate(
          offset: Offset(0, (1 - t) * 6),
          child: Transform.scale(scale: beginScale + (1 - beginScale) * t, child: child),
        );
      },
      child: Icon(
        widget.earned ? Icons.star_rounded : Icons.star_outline_rounded,
        key: ValueKey<String>('memory-star-${widget.index}-${widget.earned ? _earnedKey : _emptyKey}'),
        color: widget.earned ? AppPalette.gold : AppPalette.gold.withValues(alpha: 0.5),
        size: 56,
      ),
    );
  }
}
