import 'data/local/hive_persistence_repository.dart';
import 'data/local/hive_persistence_config.dart';


final repository = HivePersistenceRepository(
  levelStateBox: HivePersistenceConfig.levelStateBox,
  userProfileBox: HivePersistenceConfig.userProfileBox,
);