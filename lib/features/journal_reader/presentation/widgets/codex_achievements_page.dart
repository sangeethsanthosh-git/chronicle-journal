import 'package:flutter/material.dart';
import '../../../achievements/domain/models/journal_achievement.dart';

/// Game Codex Achievements page spread (matching References 1 & 2):
/// - Left Page: Daily writing streak, total entry milestone bar, stats
/// - Right Page: Collectible ink stamp seals, mystery hints, unlocked lore
class CodexAchievementsPage extends StatelessWidget {
  final List<JournalAchievement> achievements;
  final int streak;
  final int totalEntries;

  const CodexAchievementsPage({
    super.key,
    required this.achievements,
    required this.streak,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFD7C5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header banner (Game Codex Style: "NOTEBOOK / TROPHY")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: Color(0xFFC99A3E),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CHRONICLE CODEX',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF2C2218),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2218),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length} SEALS',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAF7EE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Daily Streak & Volume Milestones Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAE1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDD4C1)),
            ),
            child: Row(
              children: [
                // Streak Flame Stamp
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7EE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC99A3E),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: Color(0xFFC86D51),
                        ),
                        Text(
                          '$streak d',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2218),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Writing Rhythm',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2218),
                            ),
                          ),
                          Text(
                            '$totalEntries Entries',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A6B5D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress track
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (totalEntries / 50).clamp(0.05, 1.0),
                          backgroundColor: const Color(0xFFDDD4C1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFC86D51),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Collectible Achievement Seals Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.85,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return _buildAchievementSealTile(ach);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSealTile(JournalAchievement ach) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ach.isUnlocked
            ? const Color(0xFFFAF7EE)
            : const Color(0xFFEDE6DA).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ach.isUnlocked
              ? ach.sealColor.withValues(alpha: 0.5)
              : const Color(0xFFD4CBBC),
          width: 1.2,
        ),
        boxShadow: ach.isUnlocked
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Stamp Seal Emblem
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ach.isUnlocked
                  ? ach.sealColor.withValues(alpha: 0.15)
                  : const Color(0xFFDFD6C7),
              shape: BoxShape.circle,
              border: Border.all(
                color: ach.isUnlocked ? ach.sealColor : const Color(0xFFB5AA98),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                ach.isUnlocked ? ach.icon : Icons.lock_outline,
                size: 16,
                color: ach.isUnlocked ? ach.sealColor : const Color(0xFF9E9280),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ach.isUnlocked ? ach.title : '???',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ach.isUnlocked
                        ? const Color(0xFF2C2218)
                        : const Color(0xFF8C7E6D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ach.isUnlocked ? ach.description : 'Undiscovered chapter',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontStyle: ach.isUnlocked
                        ? FontStyle.normal
                        : FontStyle.italic,
                    color: const Color(0xFF7A6B5D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
