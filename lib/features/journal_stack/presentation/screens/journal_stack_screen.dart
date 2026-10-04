import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/providers/journal_providers.dart';
import '../../domain/models/journal_stack_item.dart';
import '../controllers/journal_stack_controller.dart';
import '../widgets/create_journal_dialog.dart';
import '../widgets/journal_book_preview.dart';
import '../widgets/journal_stack.dart';

/// Full-screen Journal Stack experience matching reference media_1791113864516.jpg:
/// - Editorial title and literary typography
/// - Dual wooden bookshelves with physical books, tilt angles, and soft diagonal shadows
/// - Category filtering with tactile paper chips
/// - Sort order switching (Recent, Most Entries, Oldest, etc.)
/// - Active vs Archived volume shelves
/// - Ambient dust motes & warm sunlight
class JournalStackScreen extends ConsumerStatefulWidget {
  const JournalStackScreen({super.key});

  @override
  ConsumerState<JournalStackScreen> createState() => _JournalStackScreenState();
}

class _JournalStackScreenState extends ConsumerState<JournalStackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  void _showCreateDialog([JournalStackItem? existing]) {
    final controller = ref.read(journalStackControllerProvider.notifier);
    showDialog(
      context: context,
      builder: (ctx) => CreateJournalDialog(
        existingItem: existing,
        onSave:
            ({
              required String title,
              String? description,
              String? coverImage,
              required JournalCategory category,
              String? colorHex,
            }) async {
              if (existing == null) {
                await controller.createJournal(
                  title: title,
                  description: description,
                  coverImage: coverImage,
                  category: category,
                  colorHex: colorHex,
                );
              } else {
                await controller.updateJournal(
                  id: existing.id,
                  title: title,
                  description: description,
                  coverImage: coverImage,
                  category: category,
                  colorHex: colorHex,
                );
              }
            },
      ),
    );
  }

  void _onBookSelected(JournalStackItem item) {
    final controller = ref.read(journalStackControllerProvider.notifier);
    controller.selectJournal(item.id);

    showDialog(
      context: context,
      builder: (ctx) => JournalBookPreview(
        item: item,
        onClose: () {
          Navigator.of(ctx).pop();
          controller.closePreview();
        },
        onOpenJournal: () {
          Navigator.of(ctx).pop();
          controller.closePreview();
          // Open into physical animated book reader with the selected journal's collection
          context.push('/collections/${item.id}');
        },
        onEdit: () {
          Navigator.of(ctx).pop();
          _showCreateDialog(item);
        },
        onToggleArchive: () async {
          Navigator.of(ctx).pop();
          await controller.toggleArchive(item.id, item.isArchived);
        },
        onDelete: () async {
          Navigator.of(ctx).pop();
          final confirm = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              backgroundColor: const Color(0xFFFAF7EE),
              title: const Text(
                'Delete Journal Volume?',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to delete "${item.title}"? Your entries will not be deleted.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(c).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color(0xFFB54545)),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await controller.deleteJournal(item.id);
          }
        },
      ),
    ).then((_) {
      controller.closePreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stackState = ref.watch(journalStackControllerProvider);
    final displayedBooks = ref.watch(displayedJournalStackProvider);
    final allItemsAsync = ref.watch(journalStackStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7EE),
      body: Stack(
        children: [
          // 1. Soft Warm Wallpaper & Ambient Dust Motes
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _StackAmbientPainter(
                      progress: _ambientController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Editorial App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          color: const Color(0xFF4A3E31),
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: 'Back to Room',
                        ),
                        // Archive vs Active Toggle Pill
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EAE1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFDDD6C7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildModePill(
                                label: 'Current Shelf',
                                icon: Icons.auto_stories,
                                isSelected: !stackState.showArchived,
                                onTap: () {
                                  if (stackState.showArchived) {
                                    ref
                                        .read(
                                          journalStackControllerProvider
                                              .notifier,
                                        )
                                        .toggleShowArchived();
                                  }
                                },
                              ),
                              _buildModePill(
                                label: 'Archive',
                                icon: Icons.inventory_2_outlined,
                                isSelected: stackState.showArchived,
                                onTap: () {
                                  if (!stackState.showArchived) {
                                    ref
                                        .read(
                                          journalStackControllerProvider
                                              .notifier,
                                        )
                                        .toggleShowArchived();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        // Add Button
                        IconButton(
                          icon: const Icon(Icons.add, size: 24),
                          color: const Color(0xFF4A3E31),
                          tooltip: 'Create New Journal',
                          onPressed: () => _showCreateDialog(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Literary Heading (Matches "Not Nahid / Stories, Tech, and Creativity" reference typography)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 14.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          stackState.showArchived
                              ? 'ARCHIVE VAULT'
                              : 'JOURNAL STACK',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF2C2218),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stackState.showArchived
                              ? 'Preserved chapters and past journeys'
                              : 'Chronicles, Memories, and Reflection',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Color(0xFF7A6B5D),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Filter Ribbon
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _buildCategoryChip(
                          label: 'All Volumes',
                          icon: Icons.layers_outlined,
                          isSelected: stackState.selectedCategory == null,
                          onTap: () => ref
                              .read(journalStackControllerProvider.notifier)
                              .setCategory(null),
                        ),
                        for (final cat in JournalCategory.values) ...[
                          const SizedBox(width: 8),
                          _buildCategoryChip(
                            label: cat.label,
                            icon: cat.icon,
                            isSelected: stackState.selectedCategory == cat,
                            onTap: () => ref
                                .read(journalStackControllerProvider.notifier)
                                .setCategory(cat),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sorting options bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.sort,
                          size: 14,
                          color: Color(0xFF8C7355),
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<JournalStackSort>(
                          initialValue: stackState.sortOrder,
                          tooltip: 'Sort bookshelf',
                          color: const Color(0xFFFAF7EE),
                          onSelected: (sort) => ref
                              .read(journalStackControllerProvider.notifier)
                              .setSort(sort),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stackState.sortOrder.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8C7355),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: Color(0xFF8C7355),
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => JournalStackSort.values
                              .map(
                                (s) => PopupMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Icon(
                                        s.icon,
                                        size: 16,
                                        color: const Color(0xFF4A3E31),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        s.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF2C2218),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // The Illustrated Multi-tier Bookshelf Stack
                SliverToBoxAdapter(
                  child: allItemsAsync.when(
                    data: (_) => JournalStack(
                      books: displayedBooks,
                      selectedJournalId: stackState.selectedJournalId,
                      onSelectBook: (id) {
                        final found = displayedBooks
                            .where((b) => b.id == id)
                            .firstOrNull;
                        if (found != null) {
                          _onBookSelected(found);
                        }
                      },
                      onAddBook: () => _showCreateDialog(),
                      isArchivedMode: stackState.showArchived,
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text('Error loading journals: $err'),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // Bottom Editorial Stamp (Matches "© 2024 Not Nahid" reference footer)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Chronicle • Illustrated Living Journal',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: const Color(0xFF8C7355).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2218) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? const Color(0xFFFAF7EE)
                  : const Color(0xFF7A6B5D),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFAF7EE)
                    : const Color(0xFF7A6B5D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2218) : const Color(0xFFF3EEE2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2C2218)
                : const Color(0xFFE2DDD1),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? const Color(0xFFFAF7EE)
                  : const Color(0xFF7A6B5D),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFAF7EE)
                    : const Color(0xFF4A3E31),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gentle ambient dust motes and soft diagonal warm sunlight beam
class _StackAmbientPainter extends CustomPainter {
  final double progress;

  _StackAmbientPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle warm sunlight cone from top-right
    final sunbeamPath = Path();
    sunbeamPath.moveTo(size.width * 0.7, 0);
    sunbeamPath.lineTo(size.width, 0);
    sunbeamPath.lineTo(size.width * 0.4, size.height);
    sunbeamPath.lineTo(0, size.height);
    sunbeamPath.close();

    final sunbeamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFF7E6).withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(sunbeamPath, sunbeamPaint);

    // Floating delicate dust motes
    final motePaint = Paint()
      ..color = const Color(0xFFEADBBE).withValues(alpha: 0.45);
    final count = 14;
    for (int i = 0; i < count; i++) {
      final seed = (i * 137.5);
      final x =
          (math.sin(seed + progress * 2 * math.pi) * 0.4 + 0.5) * size.width;
      final y = ((i / count) + progress * 0.4) % 1.0 * size.height;
      final radius = 1.0 + (i % 3) * 0.7;
      canvas.drawCircle(Offset(x, y), radius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StackAmbientPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
