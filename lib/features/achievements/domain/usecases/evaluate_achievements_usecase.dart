import 'package:flutter/material.dart';
import '../../../../domain/models/journal_entry_with_details.dart';
import '../models/journal_achievement.dart';

class EvaluateAchievementsUseCase {
  List<JournalAchievement> execute({
    required List<JournalEntryWithDetails> entries,
    required int streak,
    required int journalVolumeCount,
  }) {
    final entryCount = entries.length;
    int photoCount = 0;
    int audioCount = 0;
    int wordCount = 0;
    final Set<String> distinctLocations = {};

    for (final e in entries) {
      photoCount += e.photoAttachments.length;
      audioCount += e.audioAttachments.length;
      wordCount += e.entry.content
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .length;
      if (e.entry.locationName != null &&
          e.entry.locationName!.trim().isNotEmpty) {
        distinctLocations.add(e.entry.locationName!.trim().toLowerCase());
      }
    }

    return [
      JournalAchievement(
        id: 'first_page',
        title: 'First Page',
        description: 'Placed your very first reflection onto paper.',
        icon: Icons.edit_note_rounded,
        sealColor: const Color(0xFFC86D51),
        targetValue: 1,
        currentValue: entryCount,
        isUnlocked: entryCount >= 1,
        category: AchievementCategory.volume,
        stampSymbol: '✦',
      ),
      JournalAchievement(
        id: 'streak_3',
        title: 'Gentle Rhythm',
        description: 'Maintained a quiet 3-day writing habit.',
        icon: Icons.local_fire_department_outlined,
        sealColor: const Color(0xFFD4AF37),
        targetValue: 3,
        currentValue: streak,
        isUnlocked: streak >= 3,
        category: AchievementCategory.streak,
        stampSymbol: 'III',
      ),
      JournalAchievement(
        id: 'streak_7',
        title: '7-Day Chronicle',
        description: 'Wrote every single day for an entire week.',
        icon: Icons.wb_sunny_outlined,
        sealColor: const Color(0xFFC99A3E),
        targetValue: 7,
        currentValue: streak,
        isUnlocked: streak >= 7,
        category: AchievementCategory.streak,
        stampSymbol: 'VII',
      ),
      JournalAchievement(
        id: 'memory_keeper',
        title: 'Memory Keeper',
        description: 'Gathered 10 preserved chapters of life.',
        icon: Icons.auto_stories_outlined,
        sealColor: const Color(0xFF3D6B7D),
        targetValue: 10,
        currentValue: entryCount,
        isUnlocked: entryCount >= 10,
        category: AchievementCategory.volume,
        stampSymbol: 'X',
      ),
      JournalAchievement(
        id: 'storyteller_30',
        title: 'Storyteller',
        description: 'Reached 30 personal chronicles in your archive.',
        icon: Icons.history_edu_outlined,
        sealColor: const Color(0xFF7E5B6E),
        targetValue: 30,
        currentValue: entryCount,
        isUnlocked: entryCount >= 30,
        category: AchievementCategory.volume,
        stampSymbol: 'XXX',
      ),
      JournalAchievement(
        id: 'photo_collector',
        title: 'Visual Keepsake',
        description: 'Taped 5 photograph memories into your scrapbook.',
        icon: Icons.photo_library_outlined,
        sealColor: const Color(0xFF4A6B5B),
        targetValue: 5,
        currentValue: photoCount,
        isUnlocked: photoCount >= 5,
        category: AchievementCategory.visual,
        stampSymbol: '📷',
      ),
      JournalAchievement(
        id: 'voice_of_time',
        title: 'Voice of Time',
        description: 'Recorded an audio voice memo onto a cassette.',
        icon: Icons.mic_none_outlined,
        sealColor: const Color(0xFF8A5E44),
        targetValue: 1,
        currentValue: audioCount,
        isUnlocked: audioCount >= 1,
        category: AchievementCategory.audio,
        stampSymbol: '🎙',
      ),
      JournalAchievement(
        id: 'world_wanderer',
        title: 'World Wanderer',
        description: 'Pinned journal pages across 3 distinct places.',
        icon: Icons.map_outlined,
        sealColor: const Color(0xFF414B66),
        targetValue: 3,
        currentValue: distinctLocations.length,
        isUnlocked: distinctLocations.length >= 3,
        category: AchievementCategory.explorer,
        stampSymbol: '🗺',
      ),
      JournalAchievement(
        id: 'deep_thoughts',
        title: 'Deep Thoughts',
        description: 'Penned more than 500 total words across your entries.',
        icon: Icons.draw_outlined,
        sealColor: const Color(0xFFC0787A),
        targetValue: 500,
        currentValue: wordCount,
        isUnlocked: wordCount >= 500,
        category: AchievementCategory.volume,
        stampSymbol: '✎',
      ),
      JournalAchievement(
        id: 'library_architect',
        title: 'Library Architect',
        description:
            'Organized your stories into 2 or more volumes on the shelf.',
        icon: Icons.shelves,
        sealColor: const Color(0xFF8C7355),
        targetValue: 2,
        currentValue: journalVolumeCount,
        isUnlocked: journalVolumeCount >= 2,
        category: AchievementCategory.library,
        stampSymbol: '📚',
      ),
    ];
  }
}
