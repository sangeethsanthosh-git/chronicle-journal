import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/binder_rings.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/polaroid_card.dart';
import '../../../core/widgets/postal_stamp.dart';
import '../../../core/widgets/torn_paper_card.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../../domain/models/journal_entry_with_details.dart';
import '../../../domain/models/journal_layout.dart';

class EntryCard extends StatelessWidget {
  final JournalEntryWithDetails entryWithDetails;
  final JournalLayout layout;

  const EntryCard({
    super.key,
    required this.entryWithDetails,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case JournalLayout.classic:
        return _buildClassic(context);
      case JournalLayout.scrapbook:
        return _buildScrapbook(context);
      case JournalLayout.postcard:
        return _buildPostcard(context);
      case JournalLayout.ringBinder:
        return _buildRingBinder(context);
      case JournalLayout.sanctuaryPanorama:
        return _buildSanctuaryPanorama(context);
      case JournalLayout.minimal:
        return _buildMinimal(context);
      case JournalLayout.photoDiary:
        return _buildPhotoDiary(context);
    }
  }

  // 1. CLASSIC
  Widget _buildClassic(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.paperCardDark : AppColors.paperCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.paperCardBorderDark
                : AppColors.paperCardBorderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(entry.entryDate),
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.inkSecondaryDark
                        : AppColors.inkSecondaryLight,
                  ),
                ),
                MoodBadge(
                  mood: entryWithDetails.mood,
                  intensity: entry.moodIntensity,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.title.isNotEmpty) ...[
              Text(
                entry.title,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.inkPrimaryDark
                      : AppColors.inkPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.inkSecondaryDark
                    : AppColors.inkSecondaryLight,
              ),
            ),
            if (entryWithDetails.photoAttachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.file(
                    File(entryWithDetails.photoAttachments.first.uri),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                      fontSize: 11,
                      color: isDark
                          ? AppColors.inkMutedDark
                          : AppColors.inkMutedLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (entry.weatherSummary != null) ...[
                  Text(
                    entry.weatherSummary!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.inkMutedDark
                          : AppColors.inkMutedLight,
                    ),
                  ),
                ],
                if (entryWithDetails.soundtracks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vintageGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.vintageGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.audiotrack,
                          size: 11,
                          color: AppColors.vintageGold,
                        ),
                        const SizedBox(width: 3),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            entryWithDetails.soundtracks.first.title ??
                                'Soundtrack',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.vintageGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (entry.isFavorite)
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.vintageGold,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. SCRAPBOOK
  Widget _buildScrapbook(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.paperCardDark
                    : AppColors.paperCardLight,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark
                      ? AppColors.paperCardBorderDark
                      : AppColors.paperCardBorderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PostalStamp(
                        dateText: DateFormat(
                          'dd.MM.yy',
                        ).format(entry.entryDate),
                        locationText:
                            entry.locationName?.toUpperCase() ?? 'MIORA',
                        size: 54,
                      ),
                      MoodBadge(
                        mood: entryWithDetails.mood,
                        intensity: entry.moodIntensity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (entry.title.isNotEmpty)
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    entry.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'serif', height: 1.5),
                  ),
                  if (entryWithDetails.photoAttachments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: PolaroidCard(
                        imagePath: entryWithDetails.photoAttachments.first.uri,
                        caption:
                            entryWithDetails.photoAttachments.first.caption,
                        width: 170,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Washi tape in top-left
            const Positioned(
              top: -8,
              left: 20,
              child: WashiTape(
                width: 80,
                height: 20,
                rotationDegrees: -6,
                color: AppColors.washiTapeSage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. POSTCARD
  Widget _buildPostcard(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.paperCardDark : const Color(0xFFFBF8EE),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark
                ? AppColors.paperCardBorderDark
                : const Color(0xFFDCD2C0),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POSTCARD',
                        style: TextStyle(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark
                              ? AppColors.inkMutedDark
                              : AppColors.inkMutedLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy').format(entry.entryDate),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PostalStamp(
                  dateText: DateFormat('dd-MM-yyyy').format(entry.entryDate),
                  locationText: entry.locationName?.toUpperCase() ?? 'AIRMAIL',
                  size: 48,
                  color: AppColors.postalStampRed,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.title.isNotEmpty)
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        entry.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Simulated address lines & Mood
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MoodBadge(
                        mood: entryWithDetails.mood,
                        intensity: entry.moodIntensity,
                        showLabel: false,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: AppColors.paperCardBorderLight,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: AppColors.paperCardBorderLight,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: AppColors.paperCardBorderLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. RING BINDER
  Widget _buildRingBinder(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.paperCardDark : AppColors.paperCardLight,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 6,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: BinderRings(height: 150, ringCount: 5),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(entry.entryDate),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        MoodBadge(
                          mood: entryWithDetails.mood,
                          intensity: entry.moodIntensity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (entry.title.isNotEmpty)
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      entry.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. SANCTUARY PANORAMA
  Widget _buildSanctuaryPanorama(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.paperCardDark : const Color(0xFFFAF5EB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.vintageGold.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.vintageGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat(
                        'MMMM d, yyyy',
                      ).format(entry.entryDate).toUpperCase(),
                      style: const TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vintageGold,
                      ),
                    ),
                  ],
                ),
                MoodBadge(
                  mood: entryWithDetails.mood,
                  intensity: entry.moodIntensity,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.title.isNotEmpty)
              Text(
                entry.title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. MINIMAL
  Widget _buildMinimal(BuildContext context) {
    final entry = entryWithDetails.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(entry.entryDate),
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.inkMutedDark
                        : AppColors.inkMutedLight,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entryWithDetails.mood.emoji} ${entryWithDetails.mood.label}',
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
            const SizedBox(height: 6),
            if (entry.title.isNotEmpty)
              Text(
                entry.title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.inkSecondaryDark
                    : AppColors.inkSecondaryLight,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  // 7. PHOTO DIARY
  Widget _buildPhotoDiary(BuildContext context) {
    final entry = entryWithDetails.entry;
    final hasPhotos = entryWithDetails.photoAttachments.isNotEmpty;

    return InkWell(
      onTap: () => context.push('/entry/${entry.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TornPaperCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasPhotos)
                PolaroidCard(
                  imagePath: entryWithDetails.photoAttachments.first.uri,
                  caption: entry.title.isNotEmpty ? entry.title : null,
                  width: 220,
                  rotationDegrees: 1.0,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paperBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entryWithDetails.mood.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      if (entry.title.isNotEmpty)
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(entry.entryDate),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.inkMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
