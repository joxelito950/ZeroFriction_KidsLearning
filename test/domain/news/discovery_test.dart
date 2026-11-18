import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/news/discovery.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

/// HU-041: las bases para destacar lo nuevo (dominio y guardado).
void main() {
  final GameProgress playing = GameProgress.initial();
  GameProgress withMedals(Set<GameDifficulty> medals) =>
      GameProgress(position: const RoundPosition(round: GameDifficulty.gold, level: 2), medals: medals);

  group('Discovery', () {
    test('a new install has seen everything (R2, criterion 1)', () {
      final Discovery fresh = Discovery.allSeen();
      for (final GameId game in GameId.values) {
        expect(fresh.isNewGame(game, playing), isFalse);
      }
      for (final ParentsFeature feature in ParentsFeature.values) {
        expect(fresh.isNewFeature(feature), isFalse);
      }
    });

    test('a profile from before HU-041 saw what rc.5 had: «Their progress» is new to it (R7)', () {
      final Discovery before = Discovery.beforeNews();
      for (final GameId game in Discovery.gamesInRc5) {
        expect(before.isNewGame(game, playing), isFalse);
      }
      expect(before.isNewFeature(ParentsFeature.progress), isTrue);
      expect(before.isNewFeature(ParentsFeature.language), isFalse);
      expect(before.sawFeature(ParentsFeature.progress).isNewFeature(ParentsFeature.progress), isFalse);
    });

    test('a new game stays highlighted until it is opened for the third time (P1, criterion 2)', () {
      Discovery discovery = Discovery();
      expect(discovery.isNewGame(GameId.shadows, playing), isTrue);
      discovery = discovery.openedGame(GameId.shadows).openedGame(GameId.shadows);
      expect(discovery.opensOf(GameId.shadows), 2);
      expect(discovery.isNewGame(GameId.shadows, playing), isTrue);
      discovery = discovery.openedGame(GameId.shadows);
      expect(discovery.isNewGame(GameId.shadows, playing), isFalse);
      expect(discovery.openedGame(GameId.shadows), same(discovery), reason: 'counting stops at 3');
      expect(discovery.isNewGame(GameId.memory, playing), isTrue);
    });

    test('or until the child passes the silver round in it (P1)', () {
      final Discovery discovery = Discovery().openedGame(GameId.memory);
      expect(discovery.isNewGame(GameId.memory, withMedals({GameDifficulty.bronze})), isTrue);
      expect(discovery.isNewGame(GameId.memory, withMedals({GameDifficulty.bronze, GameDifficulty.silver})), isFalse);
    });

    test('rejects counts out of range and compares by value', () {
      expect(() => Discovery(gameOpens: {GameId.memory: 4}), throwsRangeError);
      expect(Discovery.allSeen(), Discovery.allSeen());
      expect(Discovery.allSeen().hashCode, Discovery.allSeen().hashCode);
      expect(Discovery.allSeen(), isNot(Discovery.beforeNews()));
      expect(Discovery().sawFeature(ParentsFeature.pin).sawFeature(ParentsFeature.pin).seenFeatures, {ParentsFeature.pin});
      expect(Discovery().toString(), startsWith('Discovery('));
    });
  });

  group('saved in the user profile (section 5)', () {
    test('a profile without anything discovered reads as all seen and is saved that way', () {
      const UserProfile fresh = UserProfile(isPremium: false, isSoundEnabled: true);
      expect(fresh.discovered, Discovery.allSeen());
      final UserProfileHiveModel model = UserProfileHiveModel.fromEntity(fresh);
      expect(model.gameOpens, {for (final GameId game in GameId.values) game.name: Discovery.opensToSee});
      expect(model.toEntity().discovery, Discovery.allSeen());
    });

    test('a profile saved before HU-041 reads as what rc.5 had', () {
      const UserProfileHiveModel old = UserProfileHiveModel(isPremium: false, isSoundEnabled: true, languageCode: 'es');
      expect(old.toEntity().discovery, Discovery.beforeNews());
    });

    test('opens and seen options survive a round trip; unknown names are ignored', () {
      final UserProfile profile = const UserProfile(isPremium: false, isSoundEnabled: true)
          .copyWith(discovery: Discovery().openedGame(GameId.oddOneOut).sawFeature(ParentsFeature.games));
      expect(UserProfileHiveModel.fromEntity(profile).toEntity(), profile);

      const UserProfileHiveModel future = UserProfileHiveModel(
        isPremium: false,
        isSoundEnabled: true,
        gameOpens: {'memory': 9, 'puzzle': 1},
        seenFeatures: ['sound', 'bedtime'],
      );
      expect(
        future.toEntity().discovery,
        Discovery(gameOpens: {GameId.memory: Discovery.opensToSee}, seenFeatures: {ParentsFeature.sound}),
      );
    });
  });
}
