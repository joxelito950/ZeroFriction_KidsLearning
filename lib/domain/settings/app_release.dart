/// Datos de la versión que se compila.
abstract final class AppRelease {
  /// Día en que se prepara la versión. Las ediciones especiales solo se abren
  /// hasta 13 meses después (HU-042 R7). **Se actualiza en cada release**
  /// (checklist de la sección 5 de la especificación).
  static final DateTime builtOn = DateTime(2026, 11, 27);
}
