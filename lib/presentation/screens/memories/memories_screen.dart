import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/polaroid_card.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../providers/memories_provider.dart';
import '../../providers/preferences_provider.dart';

class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final memories = ref.watch(memoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Memories & Time Capsule',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
        ),
        body: memories.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🕰️', style: TextStyle(fontSize: 54)),
                      const SizedBox(height: 16),
                      const Text(
                        'No Memories Yet Today',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'As you journal throughout the months and years, your past reflections on this exact calendar day will appear here automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.inkSecondaryDark
                              : AppColors.inkSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: memories.length,
                itemBuilder: (context, index) {
                  final memory = memories[index];
                  final entry = memory.entry.entry;
                  final hasPhotos = memory.entry.photoAttachments.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
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
                                color: Colors.black.withAlpha(25),
                                blurRadius: 8,
                                offset: const Offset(1, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => context.push('/entry/${entry.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.vintageGold.withAlpha(
                                          40,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        memory.timeAgoDescription.toUpperCase(),
                                        style: const TextStyle(
                                          letterSpacing: 1.2,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.vintageGold,
                                        ),
                                      ),
                                    ),
                                    MoodBadge(
                                      mood: memory.entry.mood,
                                      intensity: entry.moodIntensity,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  DateFormat(
                                    'EEEE, MMMM d, yyyy',
                                  ).format(entry.entryDate),
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.inkMutedDark
                                        : AppColors.inkMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (entry.title.isNotEmpty) ...[
                                  Text(
                                    entry.title,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  entry.content,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                if (hasPhotos) ...[
                                  const SizedBox(height: 16),
                                  Center(
                                    child: PolaroidCard(
                                      imagePath: memory
                                          .entry
                                          .photoAttachments
                                          .first
                                          .uri,
                                      caption: memory
                                          .entry
                                          .photoAttachments
                                          .first
                                          .caption,
                                      width: 180,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // Corner Washi Tape
                        const Positioned(
                          top: -8,
                          left: 20,
                          child: WashiTape(
                            width: 70,
                            height: 18,
                            color: AppColors.washiTapeRose,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
