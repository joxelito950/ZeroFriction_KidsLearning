class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.soundEnabled,
  });

  final bool isPremium;
  final bool soundEnabled;

  UserProfile copyWith({
    bool? isPremium,
    bool? soundEnabled,
  }) {
    return UserProfile(
      isPremium: isPremium ?? this.isPremium,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.isPremium == isPremium &&
        other.soundEnabled == soundEnabled;
  }

  @override
  int get hashCode => Object.hash(isPremium, soundEnabled);
}
