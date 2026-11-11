import 'package:flutter/material.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/memory/memory_stars.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'round_style.dart';

/// Celebración al ganar un tablero (HU-001 R14, D-030): sin botones, desaparece
/// sola. Es igual de alegre con cualquier número de estrellas; las que faltan se
/// ven como contorno suave. Al conseguir la insignia, la celebración es dorada.
class MemoryCelebration extends StatelessWidget {
  const MemoryCelebration({super.key, required this.stars, required this.badgeEarned, this.medal});

  final int stars;
  final bool badgeEarned;

  /// Ronda completada (HU-037): bronce, plata u oro. Sin ella, la insignia de
  /// siempre.
  final GameDifficulty? medal;

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
        Icon(
          badgeEarned ? Icons.military_tech_rounded : Icons.emoji_events_rounded,
          size: 56,
          color: badgeEarned ? medalColor : AppPalette.softCoral,
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
              : (badgeEarned ? l10n.memoryBadgeMessage : l10n.victoryMessage),
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
        Icon(Icons.touch_app_rounded, size: 56, color: RoundStyle.colorOf(round)),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: color,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
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
