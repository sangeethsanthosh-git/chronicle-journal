import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';
import 'journal_empty_state.dart';
import 'journal_shelf.dart';

/// Renders the multi-tier illustrated bookshelf stack containing the user's books.
class JournalStack extends StatelessWidget {
  final List<JournalStackItem> books;
  final String? selectedJournalId;
  final ValueChanged<String> onSelectBook;
  final VoidCallback onAddBook;
  final bool isArchivedMode;

  const JournalStack({
    super.key,
    required this.books,
    required this.selectedJournalId,
    required this.onSelectBook,
    required this.onAddBook,
    this.isArchivedMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Column(
        children: [
          // Empty illustrated shelf
          JournalShelf(
            books: const [],
            selectedJournalId: null,
            onSelectBook: (_) {},
            onAddBook: onAddBook,
            showAddBookSlot: !isArchivedMode,
          ),
          JournalEmptyState(
            onCreateJournal: onAddBook,
            isArchivedMode: isArchivedMode,
          ),
        ],
      );
    }

    // Split books across dual shelves for rich composition matching the reference image
    if (books.length <= 4) {
      // Single shelf is sufficient for small collections
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: JournalShelf(
          books: books,
          selectedJournalId: selectedJournalId,
          onSelectBook: onSelectBook,
          onAddBook: onAddBook,
          showAddBookSlot: !isArchivedMode,
        ),
      );
    }

    final midpoint = (books.length / 2).ceil();
    final topShelfBooks = books.sublist(0, midpoint);
    final bottomShelfBooks = books.sublist(midpoint);

    return Column(
      children: [
        // Top Shelf
        JournalShelf(
          books: topShelfBooks,
          selectedJournalId: selectedJournalId,
          onSelectBook: onSelectBook,
          onAddBook: onAddBook,
          showAddBookSlot: false,
        ),

        const SizedBox(height: 24),

        // Bottom Shelf
        JournalShelf(
          books: bottomShelfBooks,
          selectedJournalId: selectedJournalId,
          onSelectBook: onSelectBook,
          onAddBook: onAddBook,
          showAddBookSlot: !isArchivedMode,
        ),
      ],
    );
  }
}
