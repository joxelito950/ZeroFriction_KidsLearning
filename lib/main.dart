import 'data/local/hive_persistence_config.dart';
import 'data/local/hive_persistence_repository.dart';

Future<HivePersistenceRepository> createRepository({required String hivePath}) async {
  await HivePersistenceConfig.initialize(hivePath: hivePath);
  return HivePersistenceRepository(
    levelStateBox: HivePersistenceConfig.levelStateBox,
    userProfileBox: HivePersistenceConfig.userProfileBox,
  );
}