import 'dart:async';

import 'package:hive/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/user_profile.dart';
import 'hive_adapters.dart';

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

      if (!Hive.isAdapterRegistered(kLevelStateTypeId)) {
        Hive.registerAdapter(LevelStateAdapter());
      }

      if (!Hive.isAdapterRegistered(kUserProfileTypeId)) {
        Hive.registerAdapter(UserProfileAdapter());
      }

      if (!Hive.isBoxOpen(levelStateBoxName)) {
        await Hive.openBox<LevelState>(levelStateBoxName);
      }
      if (!Hive.isBoxOpen(userProfileBoxName)) {
        await Hive.openBox<UserProfile>(userProfileBoxName);
      }
      _initialized = true;
      completer.complete();
    } catch (error, stackTrace) {
      if (Hive.isBoxOpen(levelStateBoxName)) {
        await Hive.box<LevelState>(levelStateBoxName).close();
      }
      if (Hive.isBoxOpen(userProfileBoxName)) {
        await Hive.box<UserProfile>(userProfileBoxName).close();
      }
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializationCompleter = null;
    }
  }

  static Box<LevelState> get levelStateBox =>
      _getOpenBox<LevelState>(levelStateBoxName);

  static Box<UserProfile> get userProfileBox =>
      _getOpenBox<UserProfile>(userProfileBoxName);

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
