import 'package:flutter/painting.dart';

/// Los 7 colores de la app (D-032, docs/brand/PALETA.md). Es el **único** sitio
/// de `lib/` donde se escribe un color: el resto usa estas constantes o sus
/// transparencias (`withValues(alpha: …)`). Lo comprueba
/// test/architecture/palette_test.dart.
abstract final class AppPalette {
  /// Marca, texto y símbolos.
  static const Color deepTeal = Color(0xFF00454D);

  /// Fondo principal.
  static const Color warmCream = Color(0xFFFFF2E2);

  /// Acentos cálidos; solo decorativo (C4).
  static const Color softCoral = Color(0xFFD9735F);

  /// Acentos alegres; decorativo salvo sobre teal profundo (C4).
  static const Color amber = Color(0xFFECA463);

  /// Progreso de juego: estrellas, insignia y puntos de nivel (C5).
  static const Color gold = Color(0xFFA86B12);

  /// Lo que se toca o se activa (C6).
  static const Color petrolBlue = Color(0xFF176B78);

  /// Texto sobre azul petróleo y superficies de tarjetas.
  static const Color white = Color(0xFFFFFFFF);

  /// Todos, en el orden de PALETA.md.
  static const List<Color> all = [deepTeal, warmCream, softCoral, amber, gold, petrolBlue, white];
}
