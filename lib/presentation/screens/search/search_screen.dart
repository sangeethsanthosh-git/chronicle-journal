import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/mood.dart';
import '../../providers/journal_providers.dart';
import '../../providers/preferences_provider.dart';
import '../timeline/entry_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(entryFilterProvider.notifier)
          .updateFilter(
            ref
                .read(entryFilterProvider)
                .copyWith(searchQuery: _searchController.text),
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final filter = ref.watch(entryFilterProvider);
    final entries = ref.watch(filteredEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref
                  .read(entryFilterProvider.notifier)
                  .updateFilter(const EntryFilter());
              context.pop();
            },
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              color: isDark
                  ? AppColors.inkPrimaryDark
                  : AppColors.inkPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Search memories, words, places...',
              hintStyle: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                color: isDark
                    ? AppColors.inkMutedDark
                    : AppColors.inkMutedLight,
              ),
              border: InputBorder.none,
            ),
          ),
          actions: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  ref
                      .read(entryFilterProvider.notifier)
                      .updateFilter(filter.copyWith(searchQuery: ''));
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
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

            // Search Results
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Type keywords to explore your journal.'
                            : 'No matching entries found.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return EntryCard(
                          entryWithDetails: entries[index],
                          layout: prefs.defaultLayout,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
