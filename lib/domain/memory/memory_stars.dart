import 'memory_ladder.dart';

/// Estrellas al ganar un nivel del juego de memoria (D-030).
///
/// El mínimo de movimientos es el número de parejas (acertar todas a la primera).
/// 3★ si se usan como mucho mínimo + número de nivel movimientos; 2★ hasta el
/// doble del mínimo; 1★ hasta el triple; 0 por encima. Calibrado por simulación
/// en HU-002: exigente pero alcanzable, e imposible tocando al azar.
abstract final class MemoryStars {
  static const int max = 3;

  static int forWin({required int level, required int moves}) {
    final int minimum = MemoryLadder.levelAt(level).pairs;
    if (moves < minimum) {
      throw ArgumentError.value(moves, 'moves', 'cannot be lower than the $minimum pairs of level $level');
    }
    if (moves <= minimum + level) return 3;
    if (moves <= minimum * 2) return 2;
    if (moves <= minimum * 3) return 1;
    return 0;
  }
}
