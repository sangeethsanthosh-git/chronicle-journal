import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../providers/database_provider.dart';
import '../../providers/journal_providers.dart';
import '../../providers/preferences_provider.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'New Journal Collection',
          style: TextStyle(fontFamily: 'serif'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                hintText: 'e.g. Travel, Personal Growth, 2026',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Memories from my travels...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final repo = ref.read(journalRepositoryProvider);
                await repo.createCollection(
                  nameController.text.trim(),
                  descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                  null,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final collectionsAsync = ref.watch(allCollectionsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Journal Collections',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
        ),
        body: collectionsAsync.when(
          data: (collections) {
            if (collections.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        'Organize Your Stories',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Group your reflections into themed scrapbooks such as Travel, Personal Growth, Projects, or Family.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: isDark
                              ? AppColors.inkSecondaryDark
                              : AppColors.inkSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Collection'),
                        onPressed: () =>
                            _showCreateCollectionDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: collections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final collection = collections[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () =>
                          context.push('/collections/${collection.id}'),
                      borderRadius: BorderRadius.circular(12),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 6,
                              offset: const Offset(1, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const Text('📁', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 12),
                            Text(
                              collection.name,
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (collection.description != null)
                              Text(
                                collection.description!,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.inkSecondaryDark
                                      : AppColors.inkSecondaryLight,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  color: AppColors.inkMutedLight,
                                  onPressed: () {
                                    ref
                                        .read(journalRepositoryProvider)
                                        .deleteCollection(collection.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -6,
                      right: 16,
                      child: WashiTape(
                        width: 50,
                        height: 16,
                        color: AppColors.washiTapeKraft,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              const Center(child: Text('Error loading collections')),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.inkPrimaryLight,
          foregroundColor: AppColors.paperCardLight,
          onPressed: () => _showCreateCollectionDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
