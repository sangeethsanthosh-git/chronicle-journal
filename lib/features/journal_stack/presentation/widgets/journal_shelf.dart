import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';
import 'journal_book_spine.dart';
import 'journal_shelf_painter.dart';

/// Renders a single horizontal wooden shelf ledge with physical books standing on it,
/// bookends, and the "+ Add Journal" slot.
class JournalShelf extends StatelessWidget {
  final List<JournalStackItem> books;
  final String? selectedJournalId;
  final ValueChanged<String> onSelectBook;
  final VoidCallback onAddBook;
  final bool showAddBookSlot;

  const JournalShelf({
    super.key,
    required this.books,
    required this.selectedJournalId,
    required this.onSelectBook,
    required this.onAddBook,
    this.showAddBookSlot = true,
  });

  @override
  Widget build(BuildContext context) {
    const shelfHeight = 220.0;
    const shelfY = 190.0;

    return SizedBox(
      height: shelfHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. The Illustrated Wooden Shelf Planks & Soft Diagonal Shadow
          Positioned.fill(
            child: CustomPaint(
              painter: const JournalShelfPainter(shelfY: shelfY),
            ),
          ),

          // 2. Books standing on the shelf
          Positioned(
            left: 0,
            right: 0,
            bottom: shelfHeight - shelfY,
            child: SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Bookend / Small stacked books accent
                    _buildCozyBookend(),

                    const SizedBox(width: 8),

                    // The User's Physical Journal Books
                    for (int i = 0; i < books.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: JournalBookSpine(
                          item: books[i],
                          isSelected: selectedJournalId == books[i].id,
                          isDimmed:
                              selectedJournalId != null &&
                              selectedJournalId != books[i].id,
                          showFloatingTag: i == 0 || i == books.length - 1,
                          onTap: () => onSelectBook(books[i].id),
                        ),
                      ),
                    ],

                    // "+ Add Journal" Blank Book Slot
                    if (showAddBookSlot) ...[
                      const SizedBox(width: 8),
                      _buildAddJournalBookSlot(context),
                    ],

                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Blank tactile book spine with a dashed outline and "+" icon
  Widget _buildAddJournalBookSlot(BuildContext context) {
    return Semantics(
      label: 'Create new journal volume',
      button: true,
      child: Tooltip(
        message: 'Create New Journal',
        child: GestureDetector(
          onTap: onAddBook,
          child: Container(
            width: 32,
            height: 155,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEE2).withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
              border: Border.all(
                color: const Color(0xFFB58055).withValues(alpha: 0.6),
                width: 1.5,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 16,
                  color: const Color(0xFF8C7355).withValues(alpha: 0.9),
                ),
                const SizedBox(height: 6),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'NEW VOLUME',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: const Color(0xFF8C7355).withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Small illustrated bookend matching the reference image styling
  Widget _buildCozyBookend() {
    return Container(
      width: 12,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(-2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
