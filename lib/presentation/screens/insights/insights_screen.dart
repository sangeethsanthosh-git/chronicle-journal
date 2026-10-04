import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/study_atmosphere_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/mood.dart';
import '../../../features/progression/providers/progression_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/statistics_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final stats = ref.watch(statisticsProvider);
    final progress = ref.watch(userProgressProvider);
    final achievements = ref.watch(achievementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Sanctuary & Insights',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Sanctuary Growth & Thought XP Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2219)
                    : const Color(0xFFFAF4E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A059),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${progress.currentLevel}',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF2C1B10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        progress.sanctuaryTitle,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark
                              ? AppColors.inkPrimaryDark
                              : AppColors.inkPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.levelProgress,
                      minHeight: 8,
                      backgroundColor: const Color(0x33C5A059),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        StudyAtmosphereColors.vintageBrass,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.totalXp} Thought XP Earned',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 12,
                          color: isDark
                              ? AppColors.inkSecondaryDark
                              : AppColors.inkSecondaryLight,
                        ),
                      ),
                      Text(
                        '${progress.xpForNextLevel} XP needed for next tier',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 12,
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Sanctuary Collectibles Showcase
            const Text(
              'Sanctuary Collectibles',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = achievements[index];
                  return Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.isUnlocked
                          ? (isDark
                                ? const Color(0xFF33291E)
                                : const Color(0xFFFFF9ED))
                          : (isDark
                                ? const Color(0xFF22201D)
                                : const Color(0xFFF0EBE0)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.isUnlocked
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF706B63),
                        width: item.isUnlocked ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.isUnlocked ? Icons.verified : Icons.lock_outline,
                          size: 26,
                          color: item.isUnlocked
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF88827A),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.isUnlocked
                                ? (isDark
                                      ? AppColors.inkPrimaryDark
                                      : AppColors.inkPrimaryLight)
                                : const Color(0xFF88827A),
                          ),
                        ),
                        Text(
                          item.isUnlocked
                              ? 'Unlocked'
                              : '${item.requiredXp} XP',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF88827A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            // Streak Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.paperCardDark
                    : AppColors.paperCardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.paperCardBorderDark
                      : AppColors.paperCardBorderLight,
                ),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 42)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.currentStreak} Day Writing Streak',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All-Time Record: ${stats.longestStreak} consecutive days',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13,
                            color: isDark
                                ? AppColors.inkSecondaryDark
                                : AppColors.inkSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Top Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Entries',
                    value: '${stats.totalEntries}',
                    icon: '📖',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'This Month',
                    value: '${stats.entriesThisMonth}',
                    icon: '📅',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Photos Added',
                    value: '${stats.photosAdded}',
                    icon: '📸',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Voice Memos',
                    value: '${stats.audioRecordings}',
                    icon: '🎙️',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Words Written',
                    value: '${stats.totalWordCount}',
                    icon: '✍️',
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mood Distribution Section
            const Text(
              'Mood Spectrum',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.paperCardDark
                    : AppColors.paperCardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.paperCardBorderDark
                      : AppColors.paperCardBorderLight,
                ),
              ),
              child: stats.totalEntries == 0
                  ? const Center(
                      child: Text(
                        'Write your first entry to see mood patterns.',
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stats.mostCommonMood != null) ...[
                          Text(
                            'Most Common Mood: ${stats.mostCommonMood!.emoji} ${stats.mostCommonMood!.label}',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vintageGold,
                            ),
                          ),
                          const Divider(height: 24),
                        ],
                        ...Mood.all.map((m) {
                          final count = stats.moodDistribution[m.type] ?? 0;
                          final percentage = stats.totalEntries > 0
                              ? (count / stats.totalEntries)
                              : 0.0;
                          if (count == 0) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Row(
                                    children: [
                                      Text(
                                        m.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        m.label,
                                        style: const TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      minHeight: 10,
                                      color: m.color,
                                      backgroundColor:
                                          (isDark
                                                  ? AppColors
                                                        .paperCardBorderDark
                                                  : AppColors
                                                        .paperCardBorderLight)
                                              .withAlpha(120),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '$count',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // Monthly Writing Activity Section
            const Text(
              'Monthly Writing Volume',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.paperCardDark
                    : AppColors.paperCardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.paperCardBorderDark
                      : AppColors.paperCardBorderLight,
                ),
              ),
              child: stats.monthlyActivity.isEmpty
                  ? const Center(child: Text('No historical monthly records.'))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: stats.monthlyActivity.entries.map((entry) {
                        final maxCount = stats.monthlyActivity.values.reduce(
                          (a, b) => a > b ? a : b,
                        );
                        final barHeight = maxCount > 0
                            ? (entry.value / maxCount) * 100
                            : 0.0;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 22,
                              height: barHeight.clamp(8.0, 100.0),
                              decoration: BoxDecoration(
                                color: AppColors.vintageGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.key.split(' ').first,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.paperCardDark : AppColors.paperCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.paperCardBorderDark
              : AppColors.paperCardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              color: isDark
                  ? AppColors.inkSecondaryDark
                  : AppColors.inkSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
