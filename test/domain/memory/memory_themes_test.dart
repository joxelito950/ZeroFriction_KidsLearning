import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/memory/memory_themes.dart';

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
String? _whyNotEmoji5(String symbol) {
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

void main() {
  group('MemoryThemes catalog (HU-001, R17, R18, T1)', () {
    test('has the nine initial themes with unique ids', () {
      expect(MemoryThemes.all.map((theme) => theme.id), [
        'farm',
        'wild',
        'vehicles',
        'construction',
        'emotions',
        'food',
        'fruits',
        'flags',
        'home',
      ]);
    });

    test('every theme has at least the 8 different emojis the 4x4 needs', () {
      final int maxPairs = MemoryLadder.levels.last.pairs;
      for (final theme in MemoryThemes.all) {
        expect(theme.symbols.length, greaterThanOrEqualTo(maxPairs), reason: theme.id);
        expect(theme.symbols.toSet(), hasLength(theme.symbols.length), reason: '${theme.id} has repeated emojis');
      }
    });

    test('no emoji is repeated across themes', () {
      final all = MemoryThemes.all.expand((theme) => theme.symbols).toList();
      expect(all.toSet(), hasLength(all.length));
    });

    test('every emoji is Emoji 5.0 or earlier (visible on Android 8)', () {
      for (final theme in MemoryThemes.all) {
        for (final symbol in theme.symbols) {
          expect(_whyNotEmoji5(symbol), isNull, reason: '${theme.id}: $symbol');
        }
      }
    });

    test('the Emoji 5.0 check detects newer emojis', () {
      expect(_whyNotEmoji5('🧸'), isNotNull, reason: 'teddy bear is Emoji 11 (TD-006)');
      expect(_whyNotEmoji5('🧱'), isNotNull);
      expect(_whyNotEmoji5('🦩'), isNotNull);
      expect(_whyNotEmoji5('👨‍🍳'), isNotNull, reason: 'ZWJ sequence');
      expect(_whyNotEmoji5('🦖'), isNull, reason: 'T-Rex is Emoji 5.0');
      expect(_whyNotEmoji5('🇨🇴'), isNull);
    });
  });

  group('MemoryThemes.pick', () {
    test('returns the requested number of different emojis from a single theme (criterion 14)', () {
      final random = Random(7);
      for (final level in MemoryLadder.levels) {
        for (var i = 0; i < 50; i++) {
          final content = MemoryThemes.pick(random, pairs: level.pairs);
          final theme = MemoryThemes.all.singleWhere((theme) => theme.id == content.themeId);

          expect(content.symbols, hasLength(level.pairs));
          expect(content.symbols.toSet(), hasLength(level.pairs));
          expect(theme.symbols, containsAll(content.symbols));
        }
      }
    });

    test('is reproducible with the same seed', () {
      final first = MemoryThemes.pick(Random(42), pairs: 6);
      final second = MemoryThemes.pick(Random(42), pairs: 6);

      expect(second.themeId, first.themeId);
      expect(second.symbols, first.symbols);
    });

    test('uses every theme and varies the emojis over many boards', () {
      final random = Random(1);
      final picks = List.generate(500, (_) => MemoryThemes.pick(random, pairs: 2));

      expect(picks.map((pick) => pick.themeId).toSet(), hasLength(MemoryThemes.all.length));
      expect(picks.map((pick) => pick.symbols.join()).toSet().length, greaterThan(50));
    });

    test('rejects impossible boards', () {
      expect(() => MemoryThemes.pick(Random(1), pairs: 0), throwsArgumentError);
      expect(() => MemoryThemes.pick(Random(1), pairs: 50), throwsArgumentError);
    });
  });
}
