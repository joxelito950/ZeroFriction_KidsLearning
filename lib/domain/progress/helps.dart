import '../settings/game_difficulty.dart';
import 'round_ladder.dart';

/// Cuándo hay ayudas (decidido por el dueño el 2026-11-24, HU-026 P5 y
/// HU-027 P6): la mano guía (HU-022), el destello que cuenta (HU-026) o una
/// muestra igual a lo que se busca (HU-027) solo van **en el tutorial y en la
/// ronda base, bronce**. Desde plata, el niño juega solo. Regla común a todos
/// los juegos.
abstract final class Helps {
  /// La ronda base: la única, además del tutorial, con ayudas.
  static const GameDifficulty baseRound = GameDifficulty.bronze;

  static bool allowedAt(GameDifficulty round, int level) => level == RoundLadder.tutorial || round == baseRound;
}
