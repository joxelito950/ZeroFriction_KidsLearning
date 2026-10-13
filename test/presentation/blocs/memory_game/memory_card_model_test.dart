import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_card_model.dart';

void main() {
  group('MemoryCard', () {
    const card = MemoryCard(id: 1, assetPath: '🐶');

    test('starts face down and unmatched', () {
      expect(card.isFaceUp, isFalse);
      expect(card.isMatched, isFalse);
    });

    test('copyWith replaces only the provided fields', () {
      final flipped = card.copyWith(isFaceUp: true);

      expect(flipped.id, 1);
      expect(flipped.assetPath, '🐶');
      expect(flipped.isFaceUp, isTrue);
      expect(flipped.isMatched, isFalse);
      expect(card.copyWith(), card);
      expect(card.copyWith(id: 2, assetPath: '🐱', isMatched: true),
          const MemoryCard(id: 2, assetPath: '🐱', isMatched: true));
    });

    test('implements value equality and a consistent hashCode', () {
      const same = MemoryCard(id: 1, assetPath: '🐶');
      const differentState = MemoryCard(id: 1, assetPath: '🐶', isFaceUp: true);

      expect(card, same);
      expect(card.hashCode, same.hashCode);
      expect(card, isNot(differentState));
    });
  });
}
