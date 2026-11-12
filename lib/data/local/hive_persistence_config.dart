import 'dart:async';

import 'package:hive_ce/hive.dart';

import 'models/game_progress_hive_model.dart';
import 'models/level_state_hive_model.dart';
import 'models/memory_progress_hive_model.dart';
import 'models/parental_settings_hive_model.dart';
import 'models/shadow_progress_hive_model.dart';
import 'models/user_profile_hive_model.dart';

final class HivePersistenceConfig {
  HivePersistenceConfig._();

  static const String levelStateBoxName = 'level_states';
  static const String userProfileBoxName = 'user_profile';
  static const String memoryProgressBoxName = 'memory_progress';
  static const String parentalSettingsBoxName = 'parental_settings';
  static const String shadowProgressBoxName = 'shadow_progress';
  static const String gameProgressBoxName = 'game_progress';

  static bool _initialized = false;
  static Completer<void>? _initializationCompleter;

  static Future<void> initialize({
    required String hivePath,
  }) async {
    if (_initializationCompleter != null) {
      return _initializationCompleter!.future;
    }
    if (_initialized) return;

    final completer = Completer<void>();
    _initializationCompleter = completer;

    try {
      Hive.init(hivePath);

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LevelStateHiveModelAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserProfileHiveModelAdapter());
      }

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(MemoryProgressHiveModelAdapter());
      }

      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ParentalSettingsHiveModelAdapter());
      }

      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(ShadowProgressHiveModelAdapter());
      }

      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(GameProgressHiveModelAdapter());
      }

      if (!Hive.isBoxOpen(levelStateBoxName)) {
        await Hive.openBox<LevelStateHiveModel>(levelStateBoxName);
      }
      if (!Hive.isBoxOpen(userProfileBoxName)) {
        await Hive.openBox<UserProfileHiveModel>(userProfileBoxName);
      }
      if (!Hive.isBoxOpen(memoryProgressBoxName)) {
        await Hive.openBox<MemoryProgressHiveModel>(memoryProgressBoxName);
      }
      if (!Hive.isBoxOpen(parentalSettingsBoxName)) {
        await Hive.openBox<ParentalSettingsHiveModel>(parentalSettingsBoxName);
      }
      if (!Hive.isBoxOpen(shadowProgressBoxName)) {
        await Hive.openBox<ShadowProgressHiveModel>(shadowProgressBoxName);
      }
      if (!Hive.isBoxOpen(gameProgressBoxName)) {
        await Hive.openBox<GameProgressHiveModel>(gameProgressBoxName);
      }
      _initialized = true;
      completer.complete();
    } catch (error, stackTrace) {
      if (Hive.isBoxOpen(levelStateBoxName)) {
        await Hive.box<LevelStateHiveModel>(levelStateBoxName).close();
      }
      if (Hive.isBoxOpen(userProfileBoxName)) {
        await Hive.box<UserProfileHiveModel>(userProfileBoxName).close();
      }
      if (Hive.isBoxOpen(memoryProgressBoxName)) {
        await Hive.box<MemoryProgressHiveModel>(memoryProgressBoxName).close();
      }
      if (Hive.isBoxOpen(parentalSettingsBoxName)) {
        await Hive.box<ParentalSettingsHiveModel>(parentalSettingsBoxName).close();
      }
      if (Hive.isBoxOpen(shadowProgressBoxName)) {
        await Hive.box<ShadowProgressHiveModel>(shadowProgressBoxName).close();
      }
      if (Hive.isBoxOpen(gameProgressBoxName)) {
        await Hive.box<GameProgressHiveModel>(gameProgressBoxName).close();
      }
      // El llamador original recibe el error vía `rethrow`; si no hubo llamadas
      // concurrentes nadie escucha este future, así que evitamos un error no capturado.
      completer.future.ignore();
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializationCompleter = null;
    }
  }

  static Box<LevelStateHiveModel> get levelStateBox =>
      _getOpenBox<LevelStateHiveModel>(levelStateBoxName);

  static Box<UserProfileHiveModel> get userProfileBox =>
      _getOpenBox<UserProfileHiveModel>(userProfileBoxName);

  static Box<MemoryProgressHiveModel> get memoryProgressBox =>
      _getOpenBox<MemoryProgressHiveModel>(memoryProgressBoxName);

  static Box<ParentalSettingsHiveModel> get parentalSettingsBox =>
      _getOpenBox<ParentalSettingsHiveModel>(parentalSettingsBoxName);

  static Box<ShadowProgressHiveModel> get shadowProgressBox =>
      _getOpenBox<ShadowProgressHiveModel>(shadowProgressBoxName);

  static Box<GameProgressHiveModel> get gameProgressBox => _getOpenBox<GameProgressHiveModel>(gameProgressBoxName);

  static Box<T> _getOpenBox<T>(String boxName) {
    if (!_initialized || !Hive.isBoxOpen(boxName)) {
      throw StateError(
        'HivePersistenceConfig is not initialized. '
        'Call initialize(hivePath: ...) before requesting boxes.',
      );
    }
    return Hive.box<T>(boxName);
  }
}
