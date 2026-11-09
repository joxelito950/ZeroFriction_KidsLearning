/// Comprobación compartida de D-024 y D-026: emojis visibles en Android 8.
library;

/// Rangos de emojis añadidos en Unicode 11 o posterior (Emoji 11+). Con
/// `minSdk` 26 (Android 8.0) solo se garantiza Emoji 5.0 = Unicode 10 (D-024,
/// D-026, HU-001 T1): un emoji de estos rangos se vería como un cuadro vacío.
const _unicode11OrLater = [
  (0x1F6D5, 0x1F6DF),
  (0x1F6F9, 0x1F6FF),
  (0x1F7E0, 0x1F7FF),
  (0x1F90C, 0x1F90F),
  (0x1F93F, 0x1F93F),
  (0x1F94D, 0x1F94F),
  (0x1F96C, 0x1F97F),
  (0x1F998, 0x1F9BF),
  (0x1F9C1, 0x1F9CF),
  (0x1F9E7, 0x1F9FF),
  (0x1FA00, 0x1FAFF),
];

const _zeroWidthJoiner = 0x200D;

/// Motivo por el que un emoji no se vería en Android 8, o `null` si es válido.
String? whyNotEmoji5(String symbol) {
  for (final rune in symbol.runes) {
    if (rune == _zeroWidthJoiner) return 'uses a ZWJ sequence';
    for (final (from, to) in _unicode11OrLater) {
      if (rune >= from && rune <= to) {
        return 'U+${rune.toRadixString(16).toUpperCase()} is Unicode 11 or later';
      }
    }
  }
  return null;
}
