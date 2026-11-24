import '../news/discovery.dart';

class UserProfile {
  const UserProfile({
    required this.isPremium,
    required this.isSoundEnabled,
    this.languageCode,
    this.discovery,
    this.highestSeenDate,
    this.activityHiddenOn,
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

  /// El día en que el adulto cerró la tarjeta de la actividad del día con la ✕
  /// (HU-047 P13): ese día no se muestra; vuelve al día siguiente. `null` si
  /// nunca se cerró.
  final DateTime? activityHiddenOn;

  bool get soundEnabled => isSoundEnabled;

  /// Lo descubierto, con la regla de la instalación nueva aplicada.
  Discovery get discovered => discovery ?? Discovery.allSeen();

  UserProfile copyWith({
    bool? isPremium,
    bool? isSoundEnabled,
    String? languageCode,
    Discovery? discovery,
    DateTime? highestSeenDate,
    DateTime? activityHiddenOn,
  }) {
    return UserProfile(
      isPremium: isPremium ?? this.isPremium,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      languageCode: languageCode ?? this.languageCode,
      discovery: discovery ?? this.discovery,
      highestSeenDate: highestSeenDate ?? this.highestSeenDate,
      activityHiddenOn: activityHiddenOn ?? this.activityHiddenOn,
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
        other.highestSeenDate == highestSeenDate &&
        other.activityHiddenOn == activityHiddenOn;
  }

  @override
  int get hashCode =>
      Object.hash(isPremium, isSoundEnabled, languageCode, discovery, highestSeenDate, activityHiddenOn);
}
