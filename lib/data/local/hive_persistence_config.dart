import 'dart:async';

import 'package:hive_ce/hive.dart';

import 'models/level_state_hive_model.dart';
import 'models/user_profile_hive_model.dart';

final class HivePersistenceConfig {
  HivePersistenceConfig._();

  static const String levelStateBoxName = 'level_states';
  static const String userProfileBoxName = 'user_profile';

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

      if (!Hive.isBoxOpen(levelStateBoxName)) {
        await Hive.openBox<LevelStateHiveModel>(levelStateBoxName);
      }
      if (!Hive.isBoxOpen(userProfileBoxName)) {
        await Hive.openBox<UserProfileHiveModel>(userProfileBoxName);
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
