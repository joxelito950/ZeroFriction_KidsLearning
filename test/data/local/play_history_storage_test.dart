import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:toddler_logic/data/local/hive_persistence_config.dart';
import 'package:toddler_logic/data/local/hive_persistence_repository.dart';
import 'package:toddler_logic/data/local/models/game_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/memory_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/play_day_hive_model.dart';
import 'package:toddler_logic/data/local/models/shadow_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/stuck_fields.dart';
import 'package:toddler_logic/domain/parental/play_history.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

/// HU-034, entrega 1: el historial diario (typeId 6) y la cuenta de «atascado»
/// de cada juego se guardan en el teléfono y se leen igual.
void main() {
  final DateTime wednesday = DateTime(2026, 11, 18, 10);
  const Duration minute = Duration(minutes: 1);

  group('PlayDayHiveModel', () {
    test('round-trips a day, with its games by name and the time outside the games', () {
      final PlayDay day = PlayDay(
        day: wednesday,
        byGame: {GameId.memory: minute * 3, GameId.oddOneOut: minute},
        outsideGames: const Duration(seconds: 40),
      );
      final PlayDayHiveModel model = PlayDayHiveModel.fromPlayDay(day);
      expect(model.secondsByGame, {'memory': 180, 'oddOneOut': 60});
      expect(model.outsideSeconds, 40);
      expect(model.toPlayDay(), day);
    });

    test('a game that no longer exists is ignored instead of breaking the read', () {
      final model = PlayDayHiveModel(day: wednesday, secondsByGame: const {'puzzle': 60, 'shadows': 30}, outsideSeconds: 0);
      expect(model.toPlayDay().byGame, {GameId.shadows: const Duration(seconds: 30)});
    });

    test('the box key is the date', () {
      expect(PlayDayHiveModel.keyOf(DateTime(2026, 3, 7, 23)), '2026-03-07');
    });
  });

  group('stuck count in the progress models (R4)', () {
    final GameProgress stuck = GameProgress(
      position: const RoundPosition(round: GameDifficulty.gold, level: 4),
      stuckLevel: 4,
      stuckFalls: 2,
    );

    test('the three game models keep it', () {
      expect(MemoryProgressHiveModel.fromGameProgress(stuck).toGameProgress(), stuck);
      expect(ShadowProgressHiveModel.fromGameProgress(stuck).toGameProgress(), stuck);
      expect(GameProgressHiveModel.fromGameProgress(stuck).toGameProgress(), stuck);
    });

    test('data saved before HU-034, or an incomplete pair, reads as not stuck', () {
      expect(stuckFallsOrZero(null, null), 0);
      expect(stuckFallsOrZero(4, null), 0);
      expect(stuckFallsOrZero(null, 2), 0);
      expect(stuckFallsOrZero(4, -1), 0);
      expect(stuckFallsOrZero(4, 2), 2);
      const model = GameProgressHiveModel(
        round: 'normal',
        level: 4,
        medals: [],
        bestStarsByRoundLevel: {},
        achievedAtByRoundLevel: {},
        stuckLevel: 4,
      );
      expect(model.toGameProgress().stuckLevel, isNull);
    });
  });

  group('HivePersistenceRepository with real boxes', () {
    late Directory dir;

    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp('play_history_');
      await HivePersistenceConfig.initialize(hivePath: dir.path);
    });

    tearDownAll(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    HivePersistenceRepository repository() => HivePersistenceRepository(
          levelStateBox: HivePersistenceConfig.levelStateBox,
          userProfileBox: HivePersistenceConfig.userProfileBox,
          memoryProgressBox: HivePersistenceConfig.memoryProgressBox,
          parentalSettingsBox: HivePersistenceConfig.parentalSettingsBox,
          shadowProgressBox: HivePersistenceConfig.shadowProgressBox,
          gameProgressBox: HivePersistenceConfig.gameProgressBox,
          playHistoryBox: HivePersistenceConfig.playHistoryBox,
        );

    test('saves each day under its date and forgets the days out of the window (R3)', () async {
      for (var offset = 0; offset < 8; offset++) {
        await repository().savePlayDay(PlayDay(day: DateTime(2026, 11, 18 - offset), outsideGames: minute));
      }
      // Guardar otra vez el mismo día lo sustituye.
      await repository().savePlayDay(PlayDay(day: wednesday, byGame: {GameId.memory: minute * 2}));
      expect(HivePersistenceConfig.playHistoryBox.length, 8);

      final PlayHistory history = await repository().readPlayHistory(wednesday);
      expect(history.days, hasLength(PlayHistory.keptDays));
      expect(history.days.first.day, DateTime(2026, 11, 13));
      expect(history.dayAt(wednesday).playedIn(GameId.memory), minute * 2);
      expect(HivePersistenceConfig.playHistoryBox.length, PlayHistory.keptDays, reason: 'old days deleted');

      // Sin nada que borrar, la lectura no toca la caja.
      expect(await repository().readPlayHistory(wednesday), history);
    });
  });
}
