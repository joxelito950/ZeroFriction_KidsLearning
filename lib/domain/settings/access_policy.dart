/// Quién tiene lo Premium (D-040, decidido el 2026-11-12).
///
/// Mientras dure la prueba cerrada y hasta que exista el pago (HU-006), **todos
/// los juegos son 100 % gratis**: todo lo Premium (el nivel 8 de Sombras, la
/// ronda Imposible de «¿Cuál es diferente?», «Jugar sin tiempo»…) está abierto.
/// Al desarrollar HU-006 o al terminar la prueba cerrada se pone
/// [everythingFree] a `false` y vuelven las reglas de pago ya definidas
/// (D-028, HU-037 P6).
abstract final class AccessPolicy {
  /// `true` durante la prueba cerrada (D-040). Los tests de las reglas de pago
  /// lo ponen a `false` para probarlas tal como serán.
  static bool everythingFree = true;

  /// Si se juega con lo Premium: comprado o, mientras dure D-040, para todos.
  static bool hasPremium({required bool purchased}) => everythingFree || purchased;
}
