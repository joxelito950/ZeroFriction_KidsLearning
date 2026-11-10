import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../domain/sound/game_sound.dart';

/// [ISoundEffects] con `audioplayers` (HU-005 P4). Los sonidos van dentro de la
/// app (`assets/sounds/`), sin red (R6).
class AudioplayersSoundEffects implements ISoundEffects {
  AudioplayersSoundEffects({Future<void> Function(GameSound sound)? playAsset}) : _playAsset = playAsset;

  final Future<void> Function(GameSound sound)? _playAsset;

  /// Un reproductor por sonido, creado al usarlo por primera vez.
  final Map<GameSound, AudioPlayer> _players = {};

  /// Volumen dentro del volumen del teléfono: moderado (P2). Nunca lo sube (R5).
  static const double volume = 0.7;

  /// Sonidos de interfaz: siguen el volumen del sistema y el modo silencio del
  /// teléfono (R5), y no paran la música que esté sonando.
  static final AudioContext _context = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  static String assetOf(GameSound sound) => 'sounds/${sound.name}.wav';

  @override
  Future<void> play(GameSound sound) async {
    try {
      await (_playAsset ?? _play)(sound);
    } catch (_) {
      // Si no se puede reproducir, el juego sigue igual y sin avisos (R7).
    }
  }

  /// El reproductor arranca tareas propias sin esperar a que terminen; se crea
  /// en una zona protegida para que un fallo del plugin no llegue a la app (R7).
  Future<void> _play(GameSound sound) {
    final completer = Completer<void>();
    runZonedGuarded(
      () async {
        final AudioPlayer player =
            _players.putIfAbsent(sound, () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency));
        await player.stop();
        await player.play(AssetSource(assetOf(sound)), volume: volume, ctx: _context);
        if (!completer.isCompleted) completer.complete();
      },
      (error, stackTrace) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }
}
