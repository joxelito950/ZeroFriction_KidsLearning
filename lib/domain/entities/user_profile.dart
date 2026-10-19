class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.isSoundEnabled,
  });

  final bool isPremium;
  final bool isSoundEnabled;

  bool get soundEnabled => isSoundEnabled;

  UserProfile copyWith({
    bool? isPremium,
    bool? isSoundEnabled,
  }) {
    return UserProfile(
      isPremium: isPremium ?? this.isPremium,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.isPremium == isPremium &&
        other.isSoundEnabled == isSoundEnabled;
  }

  @override
  int get hashCode => Object.hash(isPremium, isSoundEnabled);
}
