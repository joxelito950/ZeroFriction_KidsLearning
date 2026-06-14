import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/entities/level_state.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import 'memory_card_model.dart';
import 'memory_game_state.dart';

/// Cubit que orquesta las reglas de negocio y los estados lógicos del Juego de Memoria.
class MemoryGameCubit extends Cubit<MemoryGameState> {
  final IPersistenceRepository _persistenceRepository;
  final String _levelId;

  MemoryGameCubit({
    required IPersistenceRepository persistenceRepository,
    required String levelId,
  })  : _persistenceRepository = persistenceRepository,
        _levelId = levelId,
        super(const MemoryGameState());

  /// Inicializa un nuevo tablero de juego mezclando las parejas de cartas de forma aleatoria.
  void startGame(List<String> imageAssets) {
    final List<MemoryCard> initialCards = [];
    int idCounter = 0;

    // Duplicamos las imágenes para crear parejas idénticas
    for (final asset in imageAssets) {
      initialCards.add(MemoryCard(id: idCounter++, assetPath: asset));
      initialCards.add(MemoryCard(id: idCounter++, assetPath: asset));
    }

    // Mezclamos la baraja de forma aleatoria en el dispositivo local
    initialCards.shuffle();

    emit(MemoryGameState(
      cards: initialCards,
      moves: 0,
      isProcessing: false,
      isCompleted: false,
    ));
  }

  /// Gestiona el evento en el cual el niño presiona una carta.
  Future<void> flipCard(int index) async {
    if (index < 0 || index >= state.cards.length) {
      return;
    }

    // Reglas de exclusión: ignorar clics si se está procesando un error,
    // o si la carta ya fue volteada o emparejada.
    if (state.isProcessing || 
        state.cards[index].isFaceUp || 
        state.cards[index].isMatched) {
      return;
    }

    // Volteamos visualmente la carta seleccionada
    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[index] = updatedCards[index].copyWith(isFaceUp: true);

    if (state.firstSelectedCardIndex == null) {
      // Caso A: Es la primera carta que voltea en este turno
      emit(state.copyWith(
        cards: updatedCards,
        firstSelectedCardIndex: index,
      ));
    } else {
      // Caso B: Es la segunda carta que voltea. Incrementamos intentos y evaluamos.
      final int firstIndex = state.firstSelectedCardIndex!;
      final bool isMatch = updatedCards[firstIndex].assetPath == updatedCards[index].assetPath;

      emit(state.copyWith(
        cards: updatedCards,
        moves: state.moves + 1,
        isProcessing: true, // Bloqueamos la pantalla temporalmente para evitar clics frenéticos
      ));

      if (isMatch) {
        // Marcamos las cartas como emparejadas de forma permanente
        // Importante: no mutar `updatedCards` después de haberlo emitido.
        final matchedCards = List<MemoryCard>.from(updatedCards);
        matchedCards[firstIndex] = matchedCards[firstIndex].copyWith(isMatched: true);
        matchedCards[index] = matchedCards[index].copyWith(isMatched: true);

        final bool hasWon = matchedCards.every((card) => card.isMatched);

        emit(state.copyWith(
          cards: matchedCards,
          isProcessing: false,
          clearSelection: true,
          isCompleted: hasWon,
        ));

        if (hasWon) {
          await _saveCompletedLevel();
        }
      } else {
        // No hubo coincidencia. Esperamos un lapso amigable (1.2 segundos) 
        // para permitir al niño memorizar y luego las regresamos boca abajo.
        await Future.delayed(const Duration(milliseconds: 1200));

        if (isClosed) return; // Evitamos fugas de memoria si salieron de la pantalla antes del delay

        final resetCards = List<MemoryCard>.from(state.cards);
        resetCards[firstIndex] = resetCards[firstIndex].copyWith(isFaceUp: false);
        resetCards[index] = resetCards[index].copyWith(isFaceUp: false);

        emit(state.copyWith(
          cards: resetCards,
          isProcessing: false,
          clearSelection: true,
        ));
      }
    }
  }

  /// Guarda el progreso del nivel en el repositorio persistente de Hive.
  Future<void> _saveCompletedLevel() async {
    // Calculamos las estrellas basadas en el rendimiento o simplemente otorgamos 3 por completar.
    // Para un niño de 3 años, lo ideal es siempre celebrar su logro positivamente.
    final finalState = LevelState(
      levelId: _levelId,
      isCompleted: true,
      stars: 3, 
    );

    await _persistenceRepository.saveLevelState(finalState);
  }
}