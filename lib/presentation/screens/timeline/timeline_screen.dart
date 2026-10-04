import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/journal_layout.dart';
import '../../../domain/models/mood.dart';
import '../../providers/journal_providers.dart';
import '../../providers/preferences_provider.dart';
import 'entry_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final currentLayout = ref.watch(currentLayoutProvider);
    final filter = ref.watch(entryFilterProvider);
    final entries = ref.watch(filteredEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Journal Timeline',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          actions: [
            // Layout switcher button
            PopupMenuButton<JournalLayout>(
              icon: const Icon(Icons.style_outlined),
              tooltip: 'Change Layout Style',
              onSelected: (layout) {
                ref.read(currentLayoutProvider.notifier).setLayout(layout);
              },
              itemBuilder: (context) {
                return JournalLayout.values.map((l) {
                  return PopupMenuItem(
                    value: l,
                    child: Row(
                      children: [
                        if (l == currentLayout)
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.vintageGold,
                          )
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Text(
                          l.label,
                          style: const TextStyle(fontFamily: 'serif'),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
            // Sort button
            PopupMenuButton<EntrySortOrder>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort Entries',
              onSelected: (order) {
                ref
                    .read(entryFilterProvider.notifier)
                    .updateFilter(filter.copyWith(sortOrder: order));
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: EntrySortOrder.newestFirst,
                  child: Text(
                    'Newest First',
                    style: TextStyle(fontFamily: 'serif'),
                  ),
                ),
                const PopupMenuItem(
                  value: EntrySortOrder.oldestFirst,
                  child: Text(
                    'Oldest First',
                    style: TextStyle(fontFamily: 'serif'),
                  ),
                ),
                const PopupMenuItem(
                  value: EntrySortOrder.recentlyUpdated,
                  child: Text(
                    'Recently Updated',
                    style: TextStyle(fontFamily: 'serif'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Favorites Filter Chip
                  FilterChip(
                    label: const Text(
                      '⭐ Favorites',
                      style: TextStyle(fontFamily: 'serif', fontSize: 12),
                    ),
                    selected: filter.isFavorite == true,
                    onSelected: (val) {
                      ref
                          .read(entryFilterProvider.notifier)
                          .updateFilter(
                            filter.copyWith(
                              isFavorite: val ? true : null,
                              clearFavorite: !val,
                            ),
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Has Photos Filter Chip
                  FilterChip(
                    label: const Text(
                      '📸 Photos',
                      style: TextStyle(fontFamily: 'serif', fontSize: 12),
                    ),
                    selected: filter.hasPhotos,
                    onSelected: (val) {
                      ref
                          .read(entryFilterProvider.notifier)
                          .updateFilter(filter.copyWith(hasPhotos: val));
                    },
                  ),
                  const SizedBox(width: 8),
                  // Has Audio Filter Chip
                  FilterChip(
                    label: const Text(
                      '🎙️ Audio',
                      style: TextStyle(fontFamily: 'serif', fontSize: 12),
                    ),
                    selected: filter.hasAudio,
                    onSelected: (val) {
                      ref
                          .read(entryFilterProvider.notifier)
                          .updateFilter(filter.copyWith(hasAudio: val));
                    },
                  ),
                  const SizedBox(width: 8),
                  // Mood filter selector
                  ...Mood.all.map((m) {
                    final isSelected = filter.mood == m.type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          '${m.emoji} ${m.label}',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          ref
                              .read(entryFilterProvider.notifier)
                              .updateFilter(
                                filter.copyWith(
                                  mood: val ? m.type : null,
                                  clearMood: !val,
                                ),
                              );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Entries List
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📖', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No entries found matching filters.',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.inkMutedDark
                                  : AppColors.inkMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return EntryCard(
                          entryWithDetails: entries[index],
                          layout: currentLayout,
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.inkPrimaryLight,
          foregroundColor: AppColors.paperCardLight,
          onPressed: () => context.push('/editor'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
