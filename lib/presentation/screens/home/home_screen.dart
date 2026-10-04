import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/quotes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../providers/journal_providers.dart';
import '../../providers/memories_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/statistics_provider.dart';
import '../timeline/entry_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final todayEntry = ref.watch(todayEntryProvider);
    final stats = ref.watch(statisticsProvider);
    final memories = ref.watch(memoriesProvider);
    final recentEntries = ref.watch(filteredEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Chronicle',
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 0.5,
              color: isDark
                  ? AppColors.inkPrimaryDark
                  : AppColors.inkPrimaryLight,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_stories_rounded),
              tooltip: 'Read Journal as Book',
              onPressed: () => context.push('/book-reader'),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => context.push('/search'),
            ),
            IconButton(
              icon: const Icon(Icons.collections_bookmark_outlined),
              onPressed: () => context.push('/collections'),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allEntriesStreamProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Header Greeting & Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.inkPrimaryDark
                            : AppColors.inkPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.inkSecondaryDark
                            : AppColors.inkSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Streak & Quote Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.paperCardDark
                        : AppColors.paperCardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.paperCardBorderDark
                          : AppColors.paperCardBorderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.vintageGold.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '🔥',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${stats.currentStreak} Day Writing Streak',
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  stats.longestStreak > 0
                                      ? 'Best: ${stats.longestStreak} days'
                                      : 'Write daily to keep your flame lit',
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
                          ),
                        ],
                      ),
                      if (prefs.showQuotes) ...[
                        const Divider(height: 20),
                        Text(
                          Quotes.getTodayQuote(),
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            height: 1.4,
                            color: isDark
                                ? AppColors.inkSecondaryDark
                                : AppColors.inkSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Today's Entry Spotlight
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Page',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (todayEntry != null)
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        onPressed: () =>
                            context.push('/editor?id=${todayEntry.entry.id}'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (todayEntry != null)
                EntryCard(
                  entryWithDetails: todayEntry,
                  layout: prefs.defaultLayout,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => context.push('/editor'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.paperCardDark
                            : AppColors.paperCardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.paperCardBorderDark
                              : AppColors.paperCardBorderLight,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('🖋️', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 10),
                          const Text(
                            'How was your day?',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Record your reflections, memories, and thoughts.',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.inkSecondaryDark
                                  : AppColors.inkSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vintageGold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () => context.push('/editor'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Write Today\'s Entry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Quick Actions Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.edit_note_rounded,
                      label: 'New Entry',
                      onTap: () => context.push('/editor'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.mood_rounded,
                      label: 'Mood',
                      onTap: () => context.push('/editor?focusMood=true'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.camera_alt_outlined,
                      label: 'Photo',
                      onTap: () => context.push('/editor?pickPhoto=true'),
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.mic_none_rounded,
                      label: 'Voice',
                      onTap: () => context.push('/editor?recordAudio=true'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Memories Section
              if (memories.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'On This Day',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/memories'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.paperCardDark
                              : AppColors.paperCardLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? AppColors.paperCardBorderDark
                                : AppColors.paperCardBorderLight,
                          ),
                        ),
                        child: InkWell(
                          onTap: () =>
                              context.push('/entry/${memory.entry.entry.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const WashiTape(
                                    width: 50,
                                    height: 14,
                                    color: AppColors.washiTapeRose,
                                  ),
                                  const Spacer(),
                                  Text(
                                    memory.timeAgoDescription,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.vintageGold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (memory.entry.entry.title.isNotEmpty)
                                Text(
                                  memory.entry.entry.title,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  memory.entry.entry.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  MoodBadge(
                                    mood: memory.entry.mood,
                                    intensity: memory.entry.entry.moodIntensity,
                                    showLabel: false,
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat.yMMMd().format(
                                      memory.entry.entry.entryDate,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 10,
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Recent Entries Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Entries',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (recentEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Center(
                    child: Text(
                      'No journal entries yet.\nTap + to write your first page!',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        color: isDark
                            ? AppColors.inkMutedDark
                            : AppColors.inkMutedLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...recentEntries
                    .take(5)
                    .map(
                      (e) => EntryCard(
                        entryWithDetails: e,
                        layout: prefs.defaultLayout,
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.inkPrimaryLight,
          foregroundColor: AppColors.paperCardLight,
          onPressed: () => context.push('/editor'),
          child: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
          children: [
            Icon(icon, size: 24, color: AppColors.vintageGold),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.inkSecondaryDark
                    : AppColors.inkSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
