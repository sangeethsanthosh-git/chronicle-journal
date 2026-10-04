import 'package:chronicle/core/theme/study_atmosphere_colors.dart';
import 'package:chronicle/features/companion/domain/models/companion_dialogue.dart';
import 'package:chronicle/features/progression/domain/models/achievement_data.dart';
import 'package:chronicle/features/progression/domain/models/user_progress_data.dart';
import 'package:chronicle/features/scrapbook/domain/models/scrapbook_item.dart';
import 'package:chronicle/features/world/domain/models/room_decoration.dart';
import 'package:chronicle/features/world/domain/models/world_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProgressData & Sanctuary Progression Tests', () {
    test('Calculates level and title correctly based on Thought XP', () {
      const p1 = UserProgressData(totalXp: 0, currentLevel: 1);
      expect(p1.sanctuaryTitle, 'The Novice Study');
      expect(p1.levelProgress, 0.0);
      expect(p1.xpForNextLevel, 100);

      const p2 = UserProgressData(totalXp: 250, currentLevel: 3);
      expect(p2.sanctuaryTitle, 'The Cozy Nook');
      expect(p2.levelProgress, 0.5);

      const p3 = UserProgressData(totalXp: 850, currentLevel: 9);
      expect(p3.sanctuaryTitle, 'The Flourishing Study');

      const p4 = UserProgressData(totalXp: 2000, currentLevel: 20);
      expect(p4.sanctuaryTitle, 'The Celestial Archive');
    });

    test('Serializes and deserializes UserProgressData correctly', () {
      final now = DateTime(2026, 10, 4, 12, 0);
      final p = UserProgressData(
        totalXp: 150,
        currentLevel: 2,
        totalEntriesWritten: 5,
        totalMemoriesSaved: 3,
        totalScrapbooksCreated: 2,
        lastJournalDate: now,
      );

      final json = p.toJson();
      final restored = UserProgressData.fromJson(json);

      expect(restored.totalXp, 150);
      expect(restored.currentLevel, 2);
      expect(restored.totalEntriesWritten, 5);
      expect(restored.totalMemoriesSaved, 3);
      expect(restored.totalScrapbooksCreated, 2);
      expect(restored.lastJournalDate, now);
    });

    test('Achievement defaults unlock based on XP threshold', () {
      final achievements = AchievementData.defaults;
      expect(achievements.length, greaterThanOrEqualTo(5));

      final firstWord = achievements.firstWhere((a) => a.id == 'first_word');
      expect(firstWord.requiredXp, 25);
    });
  });

  group('Companion Fable Dialogue & State Tests', () {
    test('Welcomes long-absence users with pure warmth and zero guilt', () {
      final greeting = CompanionDialogue.getGreeting(
        hour: 14,
        daysSinceLastJournal: 30, // 30 days away!
        totalEntries: 10,
      );

      // Must be warm and gentle, no shame or lost streak warnings
      expect(greeting, isNotEmpty);
      expect(greeting.toLowerCase().contains('streak'), isFalse);
      expect(greeting.toLowerCase().contains('failed'), isFalse);
      expect(greeting.toLowerCase().contains('missed'), isFalse);
    });

    test('Provides time-of-day greetings and thoughtful prompts', () {
      final morningGreeting = CompanionDialogue.getGreeting(
        hour: 8,
        daysSinceLastJournal: 0,
        totalEntries: 2,
      );
      expect(morningGreeting, isNotEmpty);

      final prompt = CompanionDialogue.getRandomPrompt();
      expect(prompt, isNotEmpty);
      expect(prompt.endsWith('?'), isTrue);
    });
  });

  group('Scrapbook Domain & Item Tests', () {
    test('Serializes and deserializes ScrapbookItem accurately', () {
      const item = ScrapbookItem(
        id: 'scrap_123',
        type: ScrapbookItemType.photo,
        x: 0.35,
        y: 0.45,
        rotation: 0.15,
        scale: 1.2,
        zIndex: 2,
        content: '/path/to/polaroid.jpg',
        styleMeta: 'kraft_tape',
      );

      final json = item.toJson();
      final restored = ScrapbookItem.fromJson(json);

      expect(restored.id, 'scrap_123');
      expect(restored.type, ScrapbookItemType.photo);
      expect(restored.x, 0.35);
      expect(restored.y, 0.45);
      expect(restored.rotation, 0.15);
      expect(restored.scale, 1.2);
      expect(restored.content, '/path/to/polaroid.jpg');
      expect(restored.styleMeta, 'kraft_tape');
    });
  });

  group('Study World State & Atmospheric Color Tests', () {
    test('Filters skybox gradient and ambient filter by hour of day', () {
      final morningGradient = StudyAtmosphereColors.getSkyGradient(8);
      expect(morningGradient.length, 2);

      final sunsetGradient = StudyAtmosphereColors.getSkyGradient(18);
      expect(sunsetGradient.length, 3);

      final nightGradient = StudyAtmosphereColors.getSkyGradient(23);
      expect(nightGradient.length, 2);
    });

    test('Room decorations have valid initial layout positions', () {
      final decors = RoomDecoration.defaultDecorations;
      expect(decors, isNotEmpty);

      for (final d in decors) {
        expect(d.posX, inInclusiveRange(0.0, 1.0));
        expect(d.posY, inInclusiveRange(0.0, 1.0));
        expect(d.unlockLevel, greaterThanOrEqualTo(1));
      }
    });

    test('WorldState toggles and updates correctly', () {
      const state = WorldState(isLampOn: true, currentHour: 15);
      final updated = state.copyWith(isLampOn: false, isRaining: true);

      expect(updated.isLampOn, isFalse);
      expect(updated.isRaining, isTrue);
      expect(updated.currentHour, 15);
    });
  });
}
