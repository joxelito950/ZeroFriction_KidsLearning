import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/data/local/hive_persistence_config.dart';
import 'package:toddler_logic/data/local/hive_persistence_repository.dart';
import 'package:toddler_logic/data/local/models/game_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/level_state_hive_model.dart';
import 'package:toddler_logic/data/local/models/memory_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/data/local/models/shadow_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

class _LevelBox extends Mock implements Box<LevelStateHiveModel> {}

class _ProfileBox extends Mock implements Box<UserProfileHiveModel> {}

class _SettingsBox extends Mock implements Box<ParentalSettingsHiveModel> {}

/// HU-037, entrega 2: el progreso con rondas se guarda en los modelos de
/// siempre (typeId 2 y 4) con campos nuevos, y lo de antes se migra (P7).
void main() {
  const easy = GameDifficulty.easy;
  const normal = GameDifficulty.normal;
  final DateTime day = DateTime.utc(2026, 11, 11, 9);

  final progress = GameProgress(
    position: const RoundPosition(round: GameDifficulty.impossible, level: 3, tutorialFalls: 1),
    medals: const {easy, normal},
    records: {
      const RoundLevel(easy, 2): LevelRecord(bestStars: 3, achievedAt: day),
      const RoundLevel(normal, 5): LevelRecord(bestStars: 1, achievedAt: day.add(const Duration(days: 1))),
    },
    lastPlayedAt: day,
  );

  group('models', () {
    test('round-trip the progress with rounds in both games', () {
      expect(MemoryProgressHiveModel.fromGameProgress(progress).toGameProgress(), progress);
      expect(ShadowProgressHiveModel.fromGameProgress(progress).toGameProgress(), progress);
      final model = MemoryProgressHiveModel.fromGameProgress(progress);
      expect(model.hasBadge, isTrue, reason: 'old readers still see a badge');
      expect(model.bestStarsByLevel, isEmpty, reason: 'old maps are no longer written');
      expect(model.bestStarsByRoundLevel, {2: 3, 15: 1});
      expect(ShadowProgressHiveModel.fromGameProgress(GameProgress.initial()).hasMedal, isFalse);
    });

    test('without the new fields, the old progress is migrated to Normal (P7)', () {
      final old = MemoryProgressHiveModel(
        currentLevel: 3,
        hasBadge: false,
        bestStarsByLevel: const {1: 3, 2: 2, 4: 1},
        achievedAtByLevel: {1: day, 2: day},
        lastPlayedAt: day,
      );
      final GameProgress migrated = old.toGameProgress();
      expect(migrated.position, const RoundPosition(round: normal, level: 3));
      expect(migrated.medals, isEmpty);
      expect(migrated.records, {const RoundLevel(normal, 2): LevelRecord(bestStars: 2, achievedAt: day)},
          reason: 'level 1 is now the tutorial, and a star without its date is ignored');
    });

    test('the common model round-trips, ignoring a record without its date', () {
      expect(GameProgressHiveModel.fromGameProgress(progress).toGameProgress(), progress);
      const model = GameProgressHiveModel(
        round: 'normal',
        level: 2,
        medals: [],
        bestStarsByRoundLevel: {12: 3},
        achievedAtByRoundLevel: {},
      );
      expect(model.toGameProgress().records, isEmpty);
    });

    test('a record without its date is ignored instead of inventing one', () {
      final model = ShadowProgressHiveModel(
        currentLevel: 2,
        hasMedal: false,
        bestStarsByLevel: const {},
        achievedAtByLevel: const {},
        round: 'easy',
        bestStarsByRoundLevel: const {2: 3},
      );
      expect(model.toGameProgress().records, isEmpty);
      expect(model.toGameProgress().medals, isEmpty);
      expect(model.toGameProgress().position.tutorialFalls, 0);
    });
  });

  group('real boxes', () {
    late Directory dir;

    setUpAll(() async {
      dir = await Directory.systemTemp.createTemp('progress_rc3_');
      for (final name in ['memory_progress.hive', 'shadow_progress.hive']) {
        await File('test/fixtures/progress_rc3/$name').copy('${dir.path}${Platform.pathSeparator}$name');
      }
      await HivePersistenceConfig.initialize(hivePath: dir.path);
    });

    tearDownAll(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    HivePersistenceRepository repository() => HivePersistenceRepository(
          levelStateBox: _LevelBox(),
          userProfileBox: _ProfileBox(),
          memoryProgressBox: HivePersistenceConfig.memoryProgressBox,
          parentalSettingsBox: _SettingsBox(),
          shadowProgressBox: HivePersistenceConfig.shadowProgressBox,
          gameProgressBox: HivePersistenceConfig.gameProgressBox,
        );

    test('data saved by version 1.0.0-rc.3 is read and migrated without losing anything', () async {
      final GameProgress memory = await repository().readGameProgress(GameId.memory);
      expect(memory.position, const RoundPosition(round: normal, level: 4));
      expect(memory.medals, {easy, normal}, reason: 'the old badge becomes bronze and silver');
      expect(memory.records.keys.toSet(),
          {const RoundLevel(normal, 2), const RoundLevel(normal, 3), const RoundLevel(normal, 5)});
      expect(memory.stars, 3 + 2 + 1);
      expect(memory.lastPlayedAt!.isAtSameMomentAs(DateTime.utc(2026, 11, 4, 9)), isTrue);

      final GameProgress shadows = await repository().readGameProgress(GameId.shadows);
      expect(shadows.position, const RoundPosition(round: normal, level: 6));
      expect(shadows.medals, isEmpty);
      expect(shadows.records.keys, [const RoundLevel(normal, 4)]);
    });

    test('progress with rounds survives a write and a reopen of the box', () async {
      await repository().saveGameProgress(GameId.shadows, progress);
      await repository().saveGameProgress(GameId.memory, GameProgress.initial());
      await HivePersistenceConfig.shadowProgressBox.close();
      await Hive.openBox<ShadowProgressHiveModel>(HivePersistenceConfig.shadowProgressBoxName);

      final GameProgress read = await repository().readGameProgress(GameId.shadows);
      expect(read.position, progress.position);
      expect(read.medals, progress.medals);
      expect(read.records.length, 2);
      expect(await repository().readGameProgress(GameId.memory), GameProgress.initial());
    });

    test('games born with rounds share one box, one key per game (HU-025 P5, typeId 5)', () async {
      expect(await repository().readGameProgress(GameId.oddOneOut), GameProgress.initial());
      await repository().saveGameProgress(GameId.oddOneOut, progress);
      await HivePersistenceConfig.gameProgressBox.close();
      await Hive.openBox<GameProgressHiveModel>(HivePersistenceConfig.gameProgressBoxName);
      expect(await repository().readGameProgress(GameId.oddOneOut), progress);
      expect(HivePersistenceConfig.gameProgressBox.keys, ['oddOneOut']);
    });

    test('a game never played starts in the Easy tutorial', () async {
      await HivePersistenceConfig.memoryProgressBox.clear();
      expect(await repository().readGameProgress(GameId.memory), GameProgress.initial());
    });
  });
}
