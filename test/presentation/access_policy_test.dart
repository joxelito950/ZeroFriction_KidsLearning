import 'dart:io';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/settings/access_policy.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/presentation/blocs/game_settings/game_settings_cubit.dart';
import 'package:toddler_logic/presentation/blocs/odd_one_out/odd_one_out_cubit.dart';

import 'memory_game_test_support.dart';

/// D-040: mientras dure la prueba cerrada y hasta HU-006, todo es gratis.
void main() {
  late MockPersistenceRepository repository;

  setUp(() {
    registerMemoryGameFallbacks();
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    AccessPolicy.everythingFree = true;
  });

  tearDown(() => AccessPolicy.everythingFree = false);

  test('the app ships with everything free during the closed test', () {
    // El valor del código (no el de los tests) es el de la prueba cerrada. Al
    // desarrollar HU-006 o terminar la prueba, cambiar este test con D-040.
    expect(File('lib/domain/settings/access_policy.dart').readAsStringSync(),
        contains('static bool everythingFree = true;'));
    expect(AccessPolicy.hasPremium(purchased: false), isTrue);
    AccessPolicy.everythingFree = false;
    expect(AccessPolicy.hasPremium(purchased: false), isFalse);
    expect(AccessPolicy.hasPremium(purchased: true), isTrue);
  });

  test('Premium parts open without buying: the Parents zone shows them', () async {
    final cubit = GameSettingsCubit(repository: repository);
    await cubit.load();
    expect(cubit.state.isPremium, isTrue);
    await cubit.close();
  });

  test('the Reto máximo round of Odd one out is playable without buying', () {
    fakeAsync((async) {
      when(() => repository.readGameProgress(GameId.oddOneOut))
          .thenAnswer((_) async => progressAt(2, round: GameDifficulty.impossible));
      final cubit = OddOneOutCubit(repository: repository, random: Random(1));
      cubit.start();
      async.flushMicrotasks();
      expect(cubit.state.gameRound, GameDifficulty.impossible);
      cubit.close();
    });
  });
}
