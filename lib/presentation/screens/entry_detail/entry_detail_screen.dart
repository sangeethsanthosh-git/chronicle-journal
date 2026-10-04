import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/polaroid_card.dart';
import '../../../core/widgets/postal_stamp.dart';
import '../../providers/database_provider.dart';
import '../../providers/journal_providers.dart';

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Entry?',
          style: TextStyle(fontFamily: 'serif'),
        ),
        content: const Text('This will remove this entry from your journal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(journalRepositoryProvider);
      await repo.softDeleteEntry(entryId);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(allEntriesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return entriesAsync.when(
      data: (entries) {
        final matchingEntries = entries
            .where((e) => e.entry.id == entryId)
            .toList();

        if (matchingEntries.isEmpty) {
          return const Scaffold(body: Center(child: Text('Entry not found')));
        }

        final entryWithDetails = matchingEntries.first;
        final entry = entryWithDetails.entry;

        return PaperBackground(
          paperStyle: entryWithDetails.paperStyle,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    entry.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: entry.isFavorite ? AppColors.vintageGold : null,
                  ),
                  onPressed: () {
                    final repo = ref.read(journalRepositoryProvider);
                    repo.toggleFavorite(entry.id, !entry.isFavorite);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Export as PDF',
                  onPressed: () =>
                      PdfExporter.exportEntriesToPdf([entryWithDetails]),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${entry.title}\n\n${entry.content}\n\n— Written on Chronicle',
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => context.push('/editor?id=${entry.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _deleteEntry(context, ref),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // Top Stamps & Mood
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PostalStamp(
                      dateText: DateFormat(
                        'dd.MM.yyyy',
                      ).format(entry.entryDate),
                      locationText:
                          entry.locationName?.toUpperCase() ?? 'PARIS',
                      size: 56,
                    ),
                    MoodBadge(
                      mood: entryWithDetails.mood,
                      intensity: entry.moodIntensity,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date & Time
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy • h:mm a',
                  ).format(entry.entryDate),
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.inkSecondaryDark
                        : AppColors.inkSecondaryLight,
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                if (entry.title.isNotEmpty) ...[
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.inkPrimaryDark
                          : AppColors.inkPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(height: 1),
                const SizedBox(height: 16),

                // Photos Polaroid Gallery
                if (entryWithDetails.photoAttachments.isNotEmpty) ...[
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: entryWithDetails.photoAttachments.map((photo) {
                      return PolaroidCard(
                        imagePath: photo.uri,
                        caption: photo.caption,
                        width: 220,
                        rotationDegrees: 1.5,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Content
                Text(
                  entry.content,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    height: 1.8,
                    color: isDark
                        ? AppColors.inkPrimaryDark
                        : AppColors.inkPrimaryLight,
                  ),
                ),

                const SizedBox(height: 24),

                // Audio Memos
                if (entryWithDetails.audioAttachments.isNotEmpty) ...[
                  const Text(
                    'Voice Reflections',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entryWithDetails.audioAttachments.map(
                    (audio) => AudioPlayerWidget(audioPath: audio.uri),
                  ),
                  const SizedBox(height: 20),
                ],

                // Metadata Footer
                const Divider(height: 32),
                Row(
                  children: [
                    if (entry.locationName != null) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: isDark
                            ? AppColors.inkMutedDark
                            : AppColors.inkMutedLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.locationName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (entry.weatherSummary != null) ...[
                      Text(
                        '${entry.weatherSummary} (${entry.weatherTemperature?.round()}°C)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${entryWithDetails.wordCount} words',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        color: isDark
                            ? AppColors.inkMutedDark
                            : AppColors.inkMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          const Scaffold(body: Center(child: Text('Error loading entry'))),
    );
  }
}
