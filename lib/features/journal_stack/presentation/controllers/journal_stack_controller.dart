import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/database_provider.dart';
import '../../../../presentation/providers/journal_providers.dart';
import '../../domain/models/journal_stack_item.dart';

class JournalStackState {
  final JournalCategory? selectedCategory;
  final JournalStackSort sortOrder;
  final bool showArchived;
  final String? selectedJournalId;
  final bool isCreatingJournal;

  const JournalStackState({
    this.selectedCategory,
    this.sortOrder = JournalStackSort.recent,
    this.showArchived = false,
    this.selectedJournalId,
    this.isCreatingJournal = false,
  });

  JournalStackState copyWith({
    JournalCategory? selectedCategory,
    bool clearCategory = false,
    JournalStackSort? sortOrder,
    bool? showArchived,
    String? selectedJournalId,
    bool clearSelectedJournal = false,
    bool? isCreatingJournal,
  }) {
    return JournalStackState(
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      sortOrder: sortOrder ?? this.sortOrder,
      showArchived: showArchived ?? this.showArchived,
      selectedJournalId: clearSelectedJournal
          ? null
          : (selectedJournalId ?? this.selectedJournalId),
      isCreatingJournal: isCreatingJournal ?? this.isCreatingJournal,
    );
  }
}

class JournalStackController extends Notifier<JournalStackState> {
  @override
  JournalStackState build() => const JournalStackState();

  void selectJournal(String? journalId) {
    if (state.selectedJournalId == journalId) {
      // Toggle if already selected
      state = state.copyWith(clearSelectedJournal: true);
    } else {
      state = state.copyWith(selectedJournalId: journalId);
    }
  }

  void closePreview() {
    state = state.copyWith(clearSelectedJournal: true);
  }

  void setCategory(JournalCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  void setSort(JournalStackSort sort) {
    state = state.copyWith(sortOrder: sort);
  }

  void toggleShowArchived() {
    state = state.copyWith(
      showArchived: !state.showArchived,
      clearSelectedJournal: true,
    );
  }

  Future<void> createJournal({
    required String title,
    String? description,
    String? coverImage,
    required JournalCategory category,
    String? colorHex,
  }) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.createJournalVolume(
      title: title,
      description: description,
      coverImage: coverImage,
      category: category.name.toUpperCase(),
      colorHex: colorHex,
    );
  }

  Future<void> updateJournal({
    required String id,
    String? title,
    String? description,
    String? coverImage,
    JournalCategory? category,
    String? colorHex,
  }) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.updateJournalVolume(
      id: id,
      title: title,
      description: description,
      coverImage: coverImage,
      category: category?.name.toUpperCase(),
      colorHex: colorHex,
    );
  }

  Future<void> toggleArchive(String id, bool isArchived) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.toggleArchiveJournalVolume(id, !isArchived);
    if (state.selectedJournalId == id) {
      state = state.copyWith(clearSelectedJournal: true);
    }
  }

  Future<void> deleteJournal(String id) async {
    final repo = ref.read(journalRepositoryProvider);
    await repo.deleteJournalVolume(id);
    if (state.selectedJournalId == id) {
      state = state.copyWith(clearSelectedJournal: true);
    }
  }
}

final journalStackControllerProvider =
    NotifierProvider<JournalStackController, JournalStackState>(
      JournalStackController.new,
    );

/// Filtered and sorted books on the active shelf
final displayedJournalStackProvider = Provider<List<JournalStackItem>>((ref) {
  final stackAsync = ref.watch(journalStackStreamProvider);
  final filterState = ref.watch(journalStackControllerProvider);

  return stackAsync.when(
    data: (items) {
      var result = items.where((b) {
        // Active vs Archive
        if (b.isArchived != filterState.showArchived) return false;

        // Category filter
        if (filterState.selectedCategory != null &&
            b.category != filterState.selectedCategory) {
          return false;
        }

        return true;
      }).toList();

      // Sort
      switch (filterState.sortOrder) {
        case JournalStackSort.recent:
          result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case JournalStackSort.oldest:
          result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case JournalStackSort.mostEntries:
          result.sort((a, b) => b.entryCount.compareTo(a.entryCount));
          break;
        case JournalStackSort.recentlyUpdated:
          result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case JournalStackSort.alphabetical:
          result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
          break;
      }

      return result;
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
