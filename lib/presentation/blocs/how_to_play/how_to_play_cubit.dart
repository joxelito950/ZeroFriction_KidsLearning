import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/how_to_play.dart';

/// Cómo juega el niño (HU-039, HU-031): lo leen los tableros y la mano guía de
/// todos los juegos y lo cambia la Zona de Padres. Vive en toda la app.
final class HowToPlay {
  const HowToPlay({this.moveMode = MoveMode.both, this.hand = PlayingHand.right});

  final MoveMode moveMode;
  final PlayingHand hand;

  bool get leftHanded => hand == PlayingHand.left;

  @override
  bool operator ==(Object other) => other is HowToPlay && other.moveMode == moveMode && other.hand == hand;

  @override
  int get hashCode => Object.hash(moveMode, hand);
}

class HowToPlayCubit extends Cubit<HowToPlay> {
  HowToPlayCubit({required IPersistenceRepository repository})
      : _repository = repository,
        super(const HowToPlay());

  final IPersistenceRepository _repository;

  /// Lee lo guardado; si no se puede, se juega con «Ambas» y la derecha.
  Future<void> load() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      if (!isClosed) emit(HowToPlay(moveMode: settings.moveMode, hand: settings.playingHand));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  /// Aplica los dos ajustes al instante en todos los juegos (P5) y los guarda.
  Future<void> save(HowToPlay value) async {
    emit(value);
    try {
      await _repository.updateParentalSettings(
        (current) => current.withMoveMode(value.moveMode).withPlayingHand(value.hand),
      );
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }
}
