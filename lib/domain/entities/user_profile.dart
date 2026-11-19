import '../news/discovery.dart';

class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.isSoundEnabled,
    this.languageCode,
    this.discovery,
    this.highestSeenDate,
  });

  final bool isPremium;
  final bool isSoundEnabled;

  /// Idioma de la app (uno de `AppLanguage.supported`). `null` hasta el primer arranque,
  /// en el que se toma del dispositivo y se guarda (HU-011).
  final String? languageCode;

  /// Juegos y opciones ya descubiertos (HU-041). `null` en una instalación
  /// nueva, que aún no ha guardado nada: todo cuenta como visto (R2).
  final Discovery? discovery;

  /// La fecha más alta que ha visto la app (HU-042 R7, R8): protege las
  /// ediciones especiales de los cambios de fecha del teléfono. `null` hasta el
  /// primer arranque con HU-042.
  final DateTime? highestSeenDate;

  bool get soundEnabled => isSoundEnabled;

  /// Lo descubierto, con la regla de la instalación nueva aplicada.
  Discovery get discovered => discovery ?? Discovery.allSeen();

  UserProfile copyWith({
    bool? isPremium,
    bool? isSoundEnabled,
    String? languageCode,
    Discovery? discovery,
    DateTime? highestSeenDate,
  }) {
    return UserProfile(
      isPremium: isPremium ?? this.isPremium,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      languageCode: languageCode ?? this.languageCode,
      discovery: discovery ?? this.discovery,
      highestSeenDate: highestSeenDate ?? this.highestSeenDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.isPremium == isPremium &&
        other.isSoundEnabled == isSoundEnabled &&
        other.languageCode == languageCode &&
        other.discovery == discovery &&
        other.highestSeenDate == highestSeenDate;
  }

  @override
  int get hashCode => Object.hash(isPremium, isSoundEnabled, languageCode, discovery, highestSeenDate);
}
