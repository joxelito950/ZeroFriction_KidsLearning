import 'package:hive_ce/hive.dart';

import '../../../domain/parental/play_history.dart';
import '../../../domain/progress/game_progress.dart';

part 'play_day_hive_model.g.dart';

/// Formato de guardado de un día del historial de juego (HU-034 R3): caja
/// `play_history` con una clave por fecha (`aaaa-mm-dd`). typeId 6 e índices
/// de campo fijos: NO deben cambiar (SPECIFICATION 3.4). Los juegos se guardan
/// por su nombre (`GameId.name`) para que añadir un juego no cambie el formato.
@HiveType(typeId: 6)
class PlayDayHiveModel {
  const PlayDayHiveModel({required this.day, required this.secondsByGame, required this.outsideSeconds});

  factory PlayDayHiveModel.fromPlayDay(PlayDay day) => PlayDayHiveModel(
        day: day.day,
        secondsByGame: {for (final entry in day.byGame.entries) entry.key.name: entry.value.inSeconds},
        outsideSeconds: day.outsideGames.inSeconds,
      );

  /// Clave de la caja para el día de [day].
  static String keyOf(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  @HiveField(0)
  final DateTime day;
  @HiveField(1)
  final Map<String, int> secondsByGame;
  @HiveField(2)
  final int outsideSeconds;

  /// Un juego que ya no existe se ignora en vez de romper la lectura.
  PlayDay toPlayDay() => PlayDay(
        day: day,
        byGame: {
          for (final entry in secondsByGame.entries)
            for (final GameId game in GameId.values)
              if (game.name == entry.key) game: Duration(seconds: entry.value),
        },
        outsideGames: Duration(seconds: outsideSeconds),
      );
}
