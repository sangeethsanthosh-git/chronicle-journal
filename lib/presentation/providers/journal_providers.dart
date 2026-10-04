import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';
import '../../domain/models/journal_entry_with_details.dart';
import '../../domain/models/journal_layout.dart';
import '../../domain/models/mood.dart';
import '../../domain/usecases/calculate_streak_usecase.dart';
import '../../features/achievements/domain/models/journal_achievement.dart';
import '../../features/achievements/domain/usecases/evaluate_achievements_usecase.dart';
import '../../features/journal_stack/domain/models/journal_stack_item.dart';
import 'database_provider.dart';

enum EntrySortOrder { newestFirst, oldestFirst, recentlyUpdated }

class EntryFilter {
  final String searchQuery;
  final MoodType? mood;
  final String? tagId;
  final bool? isFavorite;
  final bool hasPhotos;
  final bool hasAudio;
  final DateTime? date;
  final EntrySortOrder sortOrder;

  const EntryFilter({
    this.searchQuery = '',
    this.mood,
    this.tagId,
    this.isFavorite,
    this.hasPhotos = false,
    this.hasAudio = false,
    this.date,
    this.sortOrder = EntrySortOrder.newestFirst,
  });

  EntryFilter copyWith({
    String? searchQuery,
    MoodType? mood,
    bool clearMood = false,
    String? tagId,
    bool clearTag = false,
    bool? isFavorite,
    bool clearFavorite = false,
    bool? hasPhotos,
    bool? hasAudio,
    DateTime? date,
    bool clearDate = false,
    EntrySortOrder? sortOrder,
  }) {
    return EntryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      mood: clearMood ? null : (mood ?? this.mood),
      tagId: clearTag ? null : (tagId ?? this.tagId),
      isFavorite: clearFavorite ? null : (isFavorite ?? this.isFavorite),
      hasPhotos: hasPhotos ?? this.hasPhotos,
      hasAudio: hasAudio ?? this.hasAudio,
      date: clearDate ? null : (date ?? this.date),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class EntryFilterNotifier extends Notifier<EntryFilter> {
  @override
  EntryFilter build() => const EntryFilter();

  void updateFilter(EntryFilter filter) => state = filter;
}

final entryFilterProvider = NotifierProvider<EntryFilterNotifier, EntryFilter>(
  () {
    return EntryFilterNotifier();
  },
);

class CurrentLayoutNotifier extends Notifier<JournalLayout> {
  @override
  JournalLayout build() => JournalLayout.classic;

  void setLayout(JournalLayout layout) => state = layout;
}

final currentLayoutProvider =
    NotifierProvider<CurrentLayoutNotifier, JournalLayout>(() {
      return CurrentLayoutNotifier();
    });

final allEntriesStreamProvider = StreamProvider<List<JournalEntryWithDetails>>((
  ref,
) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchAllEntries();
});

final allTagsStreamProvider = StreamProvider<List<Tag>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchAllTags();
});

final allCollectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchAllCollections();
});

final journalStackStreamProvider = StreamProvider<List<JournalStackItem>>((
  ref,
) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchJournalStackItems();
});

final filteredEntriesProvider = Provider<List<JournalEntryWithDetails>>((ref) {
  final entriesAsync = ref.watch(allEntriesStreamProvider);
  final filter = ref.watch(entryFilterProvider);

  return entriesAsync.when(
    data: (entries) {
      var result = entries.where((e) {
        // Query search
        if (filter.searchQuery.isNotEmpty) {
          final q = filter.searchQuery.toLowerCase();
          final titleMatch = e.entry.title.toLowerCase().contains(q);
          final contentMatch = e.entry.content.toLowerCase().contains(q);
          final locMatch =
              e.entry.locationName?.toLowerCase().contains(q) ?? false;
          final tagMatch = e.tags.any((t) => t.name.toLowerCase().contains(q));
          if (!titleMatch && !contentMatch && !locMatch && !tagMatch) {
            return false;
          }
        }

        // Mood
        if (filter.mood != null && e.mood.type != filter.mood) {
          return false;
        }

        // Tag
        if (filter.tagId != null && !e.tags.any((t) => t.id == filter.tagId)) {
          return false;
        }

        // Favorite
        if (filter.isFavorite != null &&
            e.entry.isFavorite != filter.isFavorite) {
          return false;
        }

        // Media
        if (filter.hasPhotos && e.photoAttachments.isEmpty) {
          return false;
        }
        if (filter.hasAudio && e.audioAttachments.isEmpty) {
          return false;
        }

        // Date
        if (filter.date != null) {
          final ed = e.entry.entryDate;
          final fd = filter.date!;
          if (ed.year != fd.year || ed.month != fd.month || ed.day != fd.day) {
            return false;
          }
        }

        return true;
      }).toList();

      // Sort
      switch (filter.sortOrder) {
        case EntrySortOrder.newestFirst:
          result.sort((a, b) => b.entry.entryDate.compareTo(a.entry.entryDate));
          break;
        case EntrySortOrder.oldestFirst:
          result.sort((a, b) => a.entry.entryDate.compareTo(b.entry.entryDate));
          break;
        case EntrySortOrder.recentlyUpdated:
          result.sort((a, b) => b.entry.updatedAt.compareTo(a.entry.updatedAt));
          break;
      }

      return result;
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

final todayEntryProvider = Provider<JournalEntryWithDetails?>((ref) {
  final entriesAsync = ref.watch(allEntriesStreamProvider);
  final now = DateTime.now();

  return entriesAsync.when(
    data: (entries) {
      for (final e in entries) {
        final d = e.entry.entryDate;
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          return e;
        }
      }
      return null;
    },
    loading: () => null,
    error: (err, stack) => null,
  );
});

final achievementsProvider = Provider<List<JournalAchievement>>((ref) {
  final entries = ref.watch(allEntriesStreamProvider).value ?? [];
  final volumes = ref.watch(journalStackStreamProvider).value ?? [];
  final entryDates = entries.map((e) => e.entry.entryDate).toList();
  final streak = CalculateStreakUseCase().execute(entryDates);

  return EvaluateAchievementsUseCase().execute(
    entries: entries,
    streak: streak.currentStreak,
    journalVolumeCount: volumes.length,
  );
});
