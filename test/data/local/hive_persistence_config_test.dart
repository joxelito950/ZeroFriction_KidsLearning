import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:toddler_logic/data/local/hive_persistence_config.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

/// `Hive.openBox` (hive 2.2.3) completa con error un Completer interno que nadie
/// escucha, así que cada fallo al abrir una caja filtra un error no capturado
/// propio de Hive. Solo toleramos ese; cualquier otro vendría de nuestro código.
const int _hiveOpenBoxLeakedErrors = 1;

/// Ejecuta [body] en una zona aislada y devuelve los errores no capturados.
Future<List<Object>> _collectUncaughtErrors(Future<void> Function() body) async {
  final uncaught = <Object>[];
  final done = Completer<void>();
  runZonedGuarded(
    () => body().whenComplete(done.complete),
    (error, _) => uncaught.add(error),
  );
  await done.future;
  await Future<void>.delayed(Duration.zero);
  return uncaught;
}

/// HivePersistenceConfig guarda estado estático, así que estos tests
/// se ejecutan en orden: primero los fallos y luego la inicialización correcta.
void main() {
  late Directory tempDir;
  late File notADirectory;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_config_test_');
    notADirectory = File('${tempDir.path}${Platform.pathSeparator}not_a_dir');
    await notADirectory.writeAsString('x');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('HivePersistenceConfig', () {
    test('box getters throw before initialization', () {
      expect(() => HivePersistenceConfig.levelStateBox, throwsStateError);
      expect(() => HivePersistenceConfig.userProfileBox, throwsStateError);
    });

    test('a failing initialization rethrows without leaking its own unhandled error', () async {
      Object? thrown;
      final uncaught = await _collectUncaughtErrors(() async {
        try {
          await HivePersistenceConfig.initialize(hivePath: notADirectory.path);
        } catch (error) {
          thrown = error;
        }
      });

      expect(thrown, isA<FileSystemException>());
      expect(uncaught, hasLength(lessThanOrEqualTo(_hiveOpenBoxLeakedErrors)));
      expect(Hive.isBoxOpen(HivePersistenceConfig.levelStateBoxName), isFalse);
      expect(Hive.isBoxOpen(HivePersistenceConfig.userProfileBoxName), isFalse);
      expect(() => HivePersistenceConfig.levelStateBox, throwsStateError);
    });

    test('concurrent callers share the same failure', () async {
      final thrown = <Object>[];
      final uncaught = await _collectUncaughtErrors(() async {
        final first = HivePersistenceConfig.initialize(hivePath: notADirectory.path);
        final second = HivePersistenceConfig.initialize(hivePath: notADirectory.path);
        for (final call in [first, second]) {
          try {
            await call;
          } catch (error) {
            thrown.add(error);
          }
        }
      });

      expect(thrown, [isA<FileSystemException>(), isA<FileSystemException>()]);
      expect(thrown.first, same(thrown.last));
      expect(uncaught, hasLength(lessThanOrEqualTo(_hiveOpenBoxLeakedErrors)));
    });

    test('concurrent initialization opens both typed boxes once', () async {
      await Future.wait([
        HivePersistenceConfig.initialize(hivePath: tempDir.path),
        HivePersistenceConfig.initialize(hivePath: tempDir.path),
      ]);

      expect(HivePersistenceConfig.levelStateBox, isA<Box<LevelState>>());
      expect(HivePersistenceConfig.userProfileBox, isA<Box<UserProfile>>());
      expect(Hive.isAdapterRegistered(0), isTrue);
      expect(Hive.isAdapterRegistered(1), isTrue);
    });

    test('initializing again after success is a no-op that keeps the same boxes', () async {
      final Box<LevelState> boxBefore = HivePersistenceConfig.levelStateBox;

      await HivePersistenceConfig.initialize(hivePath: tempDir.path);

      expect(HivePersistenceConfig.levelStateBox, same(boxBefore));
    });

    test('opened boxes persist entities through the generated adapters', () async {
      final level = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 3);
      const profile = UserProfile(isPremium: true, isSoundEnabled: false);

      await HivePersistenceConfig.levelStateBox.put(level.levelId, level);
      await HivePersistenceConfig.userProfileBox.put('current_user_profile', profile);

      expect(HivePersistenceConfig.levelStateBox.get('farm_easy'), level);
      expect(HivePersistenceConfig.userProfileBox.get('current_user_profile'), profile);
    });
  });
}
