import '../../../domain/sound/game_sound.dart';
import '../memory_game/memory_ladder_state.dart';
import '../odd_one_out/odd_one_out_state.dart';
import '../shadow_game/shadow_game_state.dart';

/// Qué sonido corresponde a un cambio de estado de los juegos (HU-005 R1, R2).
/// Las pantallas comparan el estado anterior con el nuevo; los cubits no saben
/// nada del sonido.
abstract final class GameSoundEvents {
  /// Memoria: voltear una carta, encontrar una pareja y completar el tablero o
  /// conseguir la insignia. La vista previa, ocultar dos cartas distintas y el
  /// tiempo agotado no suenan.
  static GameSound? memory(MemoryLadderState previous, MemoryLadderState next) {
    if (next.phase == MemoryRoundPhase.celebrating && previous.phase != MemoryRoundPhase.celebrating) {
      return next.badgeEarned ? GameSound.badge : GameSound.complete;
    }
    if (previous.phase != MemoryRoundPhase.playing ||
        next.phase != MemoryRoundPhase.playing ||
        previous.round != next.round) {
      return null;
    }
    final int matchedBefore = previous.cards.where((card) => card.isMatched).length;
    final int matchedNow = next.cards.where((card) => card.isMatched).length;
    if (matchedNow > matchedBefore) {
      // La última pareja la celebra el sonido del tablero completado.
      return matchedNow == next.cards.length ? null : GameSound.match;
    }
    final int shownBefore = previous.cards.where((card) => card.isFaceUp || card.isMatched).length;
    final int shownNow = next.cards.where((card) => card.isFaceUp || card.isMatched).length;
    return shownNow > shownBefore ? GameSound.flip : null;
  }

  /// Sombras: encajar un objeto (como una pareja, HU-007 sección 5) y completar
  /// el tablero o conseguir la medalla. Soltar en otra sombra no suena.
  static GameSound? shadows(ShadowGameState previous, ShadowGameState next) {
    if (next.phase == ShadowRoundPhase.celebrating && previous.phase != ShadowRoundPhase.celebrating) {
      return next.medalEarned ? GameSound.badge : GameSound.complete;
    }
    if (previous.round != next.round || next.placed.length <= previous.placed.length) return null;
    return next.objects.every(next.placed.contains) ? null : GameSound.match;
  }

  /// ¿Cuál es diferente?: acertar suena como una pareja; completar el nivel o
  /// ganar la medalla, como siempre. Un fallo no suena (R3).
  static GameSound? oddOneOut(OddOneOutState previous, OddOneOutState next) {
    if (next.phase == previous.phase) return null;
    return switch (next.phase) {
      OddPhase.solved => GameSound.match,
      OddPhase.celebrating => next.medal != null ? GameSound.badge : GameSound.complete,
      OddPhase.inviting => GameSound.complete,
      _ => null,
    };
  }
}
