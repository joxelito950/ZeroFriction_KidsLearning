import '../progress/game_progress.dart';

/// Un día del año, sin el año: las ediciones vuelven cada año (HU-042 P5).
final class MonthDay {
  const MonthDay(this.month, this.day);

  final int month;
  final int day;

  /// Para comparar dentro del año: 1120 es el 20 de noviembre.
  int get _key => month * 100 + day;

  static int keyOf(DateTime date) => date.month * 100 + date.day;
}

/// Una edición especial (HU-042, D-043): un juego que, entre dos fechas de cada
/// año, se juega entero y con su toque de temporada.
final class SpecialEdition {
  const SpecialEdition({required this.game, required this.from, required this.until});

  final GameId game;

  /// Primer y último día, incluidos. Si [until] es anterior a [from], la
  /// edición cruza el año (del 20 de noviembre al 6 de enero).
  final MonthDay from;
  final MonthDay until;

  /// ¿Cae [date] dentro de la ventana de este año?
  bool contains(DateTime date) {
    final int day = MonthDay.keyOf(date);
    return from._key <= until._key
        ? day >= from._key && day <= until._key
        : day >= from._key || day <= until._key;
  }
}

/// Decide si una edición está abierta sin poder preguntar la hora a nadie
/// (la app no usa la red, D-033), con las protecciones de HU-042 R7 a R9.
abstract final class SpecialEditions {
  /// La Navidad de «A su sitio» (HU-052 sección 6): del 20 de noviembre al 6 de
  /// enero (HU-042 P1).
  static const SpecialEdition christmas =
      SpecialEdition(game: GameId.vehicles, from: MonthDay(11, 20), until: MonthDay(1, 6));

  static const List<SpecialEdition> all = [christmas];

  /// Margen para los cambios de hora o de zona: atrasar el reloj hasta 2 días
  /// no cuenta como trampa (R7).
  static const Duration clockSlack = Duration(days: 2);

  /// Cada versión solo abre ediciones hasta 13 meses después de compilarse
  /// (R7): con una versión vieja no se van abriendo años futuros.
  static const Duration support = Duration(days: 396);

  /// ¿Está abierta [edition] a la fecha [now]? [highestSeen] es la fecha más
  /// alta que ha visto la app y [builtOn], el día en que se compiló la versión.
  static bool isOpen(
    SpecialEdition edition, {
    required DateTime now,
    required DateTime? highestSeen,
    required DateTime builtOn,
  }) {
    if (!edition.contains(now)) return false;
    // Atrasar el reloj nunca reabre una edición (R8).
    if (highestSeen != null && now.isBefore(highestSeen.subtract(clockSlack))) return false;
    // Ni adelantarlo más allá del soporte de la versión (R7).
    return !now.isAfter(builtOn.add(support));
  }

  /// Los juegos con su edición abierta.
  static Set<GameId> openGames({required DateTime now, required DateTime? highestSeen, required DateTime builtOn}) => {
        for (final SpecialEdition edition in all)
          if (isOpen(edition, now: now, highestSeen: highestSeen, builtOn: builtOn)) edition.game,
      };

  /// La fecha más alta vista, con [now]: nunca baja (R8).
  static DateTime highest(DateTime? highestSeen, DateTime now) =>
      highestSeen == null || now.isAfter(highestSeen) ? now : highestSeen;
}
