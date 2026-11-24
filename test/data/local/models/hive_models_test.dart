import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/level_state_hive_model.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/news/discovery.dart';

void main() {
  group('LevelStateHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      final entity = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 2);

      final model = LevelStateHiveModel.fromEntity(entity);

      expect(model.levelId, 'farm_easy');
      expect(model.isCompleted, isTrue);
      expect(model.stars, 2);
      expect(model.toEntity(), entity);
    });

    test('keeps the business rule in the entity: invalid stored stars are rejected', () {
      const corrupted = LevelStateHiveModel(levelId: 'farm_easy', isCompleted: true, stars: 7);

      expect(corrupted.toEntity, throwsRangeError);
    });
  });

  group('UserProfileHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      const entity = UserProfile(isPremium: true, isSoundEnabled: false);

      final model = UserProfileHiveModel.fromEntity(entity);

      expect(model.isPremium, isTrue);
      expect(model.isSoundEnabled, isFalse);
      expect(model.languageCode, isNull);
      // Sin nada descubierto se guarda todo como visto (HU-041 R2).
      expect(model.toEntity(), entity.copyWith(discovery: Discovery.allSeen()));
    });

    test('round-trips the language code', () {
      final entity = const UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'ar')
          .copyWith(discovery: Discovery.allSeen());

      expect(UserProfileHiveModel.fromEntity(entity).toEntity(), entity);
    });

    // HU-047 P13: el día en que se cerró la idea del día, en el campo 6.
    test('round-trips the day the daily activity was hidden, also through Hive', () async {
      final entity = const UserProfile(isPremium: false, isSoundEnabled: true)
          .copyWith(discovery: Discovery.allSeen(), activityHiddenOn: DateTime(2026, 11, 23));
      expect(UserProfileHiveModel.fromEntity(entity).activityHiddenOn, DateTime(2026, 11, 23));
      expect(UserProfileHiveModel.fromEntity(entity).toEntity(), entity);
      expect(entity, isNot(entity.copyWith(activityHiddenOn: DateTime(2026, 11, 24))));

      final Directory folder = await Directory.systemTemp.createTemp('hive_activity_hidden_');
      addTearDown(() => folder.delete(recursive: true));
      Hive.init(folder.path);
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserProfileHiveModelAdapter());
      Box<UserProfileHiveModel> box = await Hive.openBox<UserProfileHiveModel>('profile');
      await box.put('current', UserProfileHiveModel.fromEntity(entity));
      await box.close();
      box = await Hive.openBox<UserProfileHiveModel>('profile');
      expect(box.get('current')!.toEntity(), entity);
      await Hive.close();
    });
  });
}
