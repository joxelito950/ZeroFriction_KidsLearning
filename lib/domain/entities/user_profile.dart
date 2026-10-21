class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.isSoundEnabled,
    this.languageCode,
  });

  final bool isPremium;
  final bool isSoundEnabled;

  /// Idioma de la app (uno de `AppLanguage.supported`). `null` hasta el primer arranque,
  /// en el que se toma del dispositivo y se guarda (HU-011).
  final String? languageCode;

  bool get soundEnabled => isSoundEnabled;

  UserProfile copyWith({
    bool? isPremium,
    bool? isSoundEnabled,
    String? languageCode,
  }) {
    return UserProfile(
      isPremium: isPremium ?? this.isPremium,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.isPremium == isPremium &&
        other.isSoundEnabled == isSoundEnabled &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(isPremium, isSoundEnabled, languageCode);
}
