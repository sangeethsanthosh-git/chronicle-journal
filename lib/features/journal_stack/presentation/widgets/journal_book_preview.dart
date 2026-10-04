import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';
import 'journal_book_cover.dart';

/// Interactive preview card displayed when a book is pulled from the shelf:
/// - Prominent 3D hardcover presentation
/// - Editorial metadata: title, description, date range, entry/photo stats, mood tone
/// - Tactile action triggers: Open Journal, Edit, Archive, Delete
class JournalBookPreview extends StatelessWidget {
  final JournalStackItem item;
  final VoidCallback onOpenJournal;
  final VoidCallback onEdit;
  final VoidCallback onToggleArchive;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const JournalBookPreview({
    super.key,
    required this.item,
    required this.onOpenJournal,
    required this.onEdit,
    required this.onToggleArchive,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7EE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDD6C7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  offset: const Offset(0, 16),
                  blurRadius: 36,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar with close icon and archive status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isArchived
                              ? const Color(0xFF8C7355).withValues(alpha: 0.15)
                              : item.spineColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isArchived
                                  ? Icons.archive_outlined
                                  : item.category.icon,
                              size: 13,
                              color: item.isArchived
                                  ? const Color(0xFF8C7355)
                                  : item.spineColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.isArchived
                                  ? 'ARCHIVED'
                                  : item.category.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: item.isArchived
                                    ? const Color(0xFF8C7355)
                                    : item.spineColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF5A4838)),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        onPressed: onClose,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 1. Prominent Book Cover Visual Focal Point
                  Center(
                    child: Hero(
                      tag: 'journal_cover_${item.id}',
                      child: JournalBookCover(
                        item: item,
                        width: 190,
                        height: 250,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Journal Title & Description
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2218),
                      letterSpacing: 0.5,
                    ),
                  ),

                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '"${item.description!}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: Color(0xFF706050),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // 3. Date Range
                  Text(
                    item.dateRangeText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C7355),
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Physical Statistics Grid (Entries, Photos, Mood)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEE2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDD1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.auto_stories,
                          value: '${item.entryCount}',
                          label: 'Pages',
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFDDD6C7),
                        ),
                        _buildStatItem(
                          icon: Icons.photo_outlined,
                          value: '${item.photoCount}',
                          label: 'Photos',
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFDDD6C7),
                        ),
                        _buildStatItem(
                          icon: Icons.mood,
                          value: item.moodSummary ?? 'Reflective',
                          label: 'Tone',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 5. OPEN JOURNAL Primary Action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2218),
                        foregroundColor: const Color(0xFFFAF7EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.menu_book, size: 20),
                      label: const Text(
                        'OPEN JOURNAL',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      onPressed: onOpenJournal,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Secondary Action buttons: Edit, Archive, Delete
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4A3E31),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: onEdit,
                      ),
                      TextButton.icon(
                        icon: Icon(
                          item.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                          size: 15,
                        ),
                        label: Text(
                          item.isArchived ? 'Unarchive' : 'Archive',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4A3E31),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: onToggleArchive,
                      ),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 15,
                          color: Color(0xFFB54545),
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB54545),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF8C7355)),
            const SizedBox(width: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2218),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF8C7355),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
