import 'package:meta/meta.dart';
import 'memory_card_model.dart';

/// Representación inmutable del estado completo de la pantalla del juego de memoria.
@immutable
class MemoryGameState {
  final List<MemoryCard> cards;
  final int? firstSelectedCardIndex;
  final bool isProcessing;
  final bool isCompleted;
  final int moves;

  const MemoryGameState({
    this.cards = const [],
    this.firstSelectedCardIndex,
    this.isProcessing = false,
    this.isCompleted = false,
    this.moves = 0,
  });

  /// Permite emitir nuevos estados de forma segura y controlada.
  MemoryGameState copyWith({
    List<MemoryCard>? cards,
    int? firstSelectedCardIndex,
    bool? isProcessing,
    bool? isCompleted,
    int? moves,
    bool clearSelection = false,
  }) {
    return MemoryGameState(
      cards: cards ?? this.cards,
      firstSelectedCardIndex: clearSelection ? null : (firstSelectedCardIndex ?? this.firstSelectedCardIndex),
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      moves: moves ?? this.moves,
    );
  }
}