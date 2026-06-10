import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.isSoundEnabled,
  });

  @HiveField(0)
  final bool isPremium;
  @HiveField(1)
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
