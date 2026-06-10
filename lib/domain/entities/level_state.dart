import 'package:hive/hive.dart';

part 'level_state.g.dart';

@HiveType(typeId: 0)
class LevelState {
  static const int minStars = 0;
  static const int maxStars = 3;

  static void validateStars(int value, {String fieldName = 'stars'}) {
    RangeError.checkValueInInterval(value, minStars, maxStars, fieldName);
  }

  LevelState({
    required this.levelId,
    required this.isCompleted,
    required this.stars,
  }) {
    validateStars(stars);
  }

  @HiveField(0)
  final String levelId;
  @HiveField(1)
  final bool isCompleted;
  @HiveField(2)
  final int stars;

  LevelState copyWith({
    String? levelId,
    bool? isCompleted,
    int? stars,
  }) {
    if (stars != null) {
      validateStars(stars);
    }

    return LevelState(
      levelId: levelId ?? this.levelId,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LevelState &&
        other.levelId == levelId &&
        other.isCompleted == isCompleted &&
        other.stars == stars;
  }

  @override
  int get hashCode => Object.hash(levelId, isCompleted, stars);
}
