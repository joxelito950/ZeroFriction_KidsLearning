import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:toddler_logic/data/local/hive_persistence_config.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

/// Los fixtures de `test/fixtures/hive_v2/` se generaron con hive 2.2.3 antes de
/// migrar a hive_ce (TD-002). Este test garantiza que los datos guardados por
/// versiones anteriores de la app se siguen leyendo sin pérdida.
void main() {
  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_v2_compat_');
    for (final name in ['level_states.hive', 'user_profile.hive']) {
      await File('test/fixtures/hive_v2/$name')
          .copy('${hiveDir.path}${Platform.pathSeparator}$name');
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  test('hive_ce reads boxes written by hive 2.2.3 without data loss', () async {
    await HivePersistenceConfig.initialize(hivePath: hiveDir.path);

    final levels = HivePersistenceConfig.levelStateBox;
    expect(levels.length, 2);
    expect(
      levels.get('farm_easy'),
      LevelState(levelId: 'farm_easy', isCompleted: true, stars: 3),
    );
    expect(
      levels.get('wild_medium'),
      LevelState(levelId: 'wild_medium', isCompleted: false, stars: 1),
    );

    expect(
      HivePersistenceConfig.userProfileBox.get('current_user_profile'),
      const UserProfile(isPremium: true, isSoundEnabled: false),
    );
  });
}
