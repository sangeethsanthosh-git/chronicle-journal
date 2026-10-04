import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../providers/database_provider.dart';
import '../../providers/preferences_provider.dart';
import '../timeline/entry_card.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(journalRepositoryProvider);
    final allEntries = await repo.getAllEntries();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Add Entry to Collection',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...allEntries.map((e) {
              return ListTile(
                title: Text(
                  e.entry.title.isNotEmpty ? e.entry.title : 'Untitled Entry',
                ),
                subtitle: Text(
                  e.entry.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () async {
                  await repo.addEntryToCollection(collectionId, e.entry.id);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final repo = ref.watch(journalRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Collection Stories',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shelves),
              tooltip: 'Journal Stack (Bookshelf)',
              onPressed: () => context.push('/journal-stack'),
            ),
            IconButton(
              icon: const Icon(Icons.auto_stories),
              tooltip: 'Read as Physical Book',
              onPressed: () => context.push('/book-reader'),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Entry',
              onPressed: () => _showAddEntryDialog(context, ref),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: repo.watchEntriesForCollection(collectionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data ?? [];
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text(
                        'This collection is empty',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the + button above to add journal pages to this collection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: Key(entry.entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    repo.removeEntryFromCollection(
                      collectionId,
                      entry.entry.id,
                    );
                  },
                  child: EntryCard(
                    entryWithDetails: entry,
                    layout: prefs.defaultLayout,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
