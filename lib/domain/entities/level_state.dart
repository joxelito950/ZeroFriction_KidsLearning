class LevelState {
  const LevelState({
    required this.levelId,
    required this.isCompleted,
    required this.stars,
  }) : assert(stars >= 0 && stars <= 3, 'stars must be between 0 and 3');

  final String levelId;
  final bool isCompleted;
  final int stars;

  LevelState copyWith({
    String? levelId,
    bool? isCompleted,
    int? stars,
  }) {
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
