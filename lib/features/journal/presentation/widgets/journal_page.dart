import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mood_badge.dart';
import '../../../../core/widgets/polaroid_card.dart';
import '../../../../core/widgets/postal_stamp.dart';
import '../../../../core/widgets/vintage_rubber_stamp.dart';
import '../../../../core/widgets/washi_tape.dart';
import '../../../../domain/models/journal_entry_with_details.dart';
import '../../../../domain/models/mood.dart';

enum JournalPageType {
  textOpening,
  textContinuation,
  photoMemories,
  scrapbook,
  quoteReflection,
  emptyBlank,
}

/// Represents the data to render on a single physical journal page
class JournalPageContent {
  final JournalPageType type;
  final JournalEntryWithDetails? entry;
  final String title;
  final String bodyText;
  final DateTime? date;
  final String? location;
  final Mood? mood;
  final List<String> photoPaths;
  final String? quoteText;
  final String? quoteAuthor;
  final int pageNumber;
  final int totalPages;

  const JournalPageContent({
    required this.type,
    this.entry,
    this.title = '',
    this.bodyText = '',
    this.date,
    this.location,
    this.mood,
    this.photoPaths = const [],
    this.quoteText,
    this.quoteAuthor,
    this.pageNumber = 1,
    this.totalPages = 1,
  });

  JournalPageContent copyWith({
    JournalPageType? type,
    JournalEntryWithDetails? entry,
    String? title,
    String? bodyText,
    DateTime? date,
    String? location,
    Mood? mood,
    List<String>? photoPaths,
    String? quoteText,
    String? quoteAuthor,
    int? pageNumber,
    int? totalPages,
  }) {
    return JournalPageContent(
      type: type ?? this.type,
      entry: entry ?? this.entry,
      title: title ?? this.title,
      bodyText: bodyText ?? this.bodyText,
      date: date ?? this.date,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      photoPaths: photoPaths ?? this.photoPaths,
      quoteText: quoteText ?? this.quoteText,
      quoteAuthor: quoteAuthor ?? this.quoteAuthor,
      pageNumber: pageNumber ?? this.pageNumber,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  /// Factory to convert a JournalEntryWithDetails into a pair or sequence of pages
  static List<JournalPageContent> fromEntry(JournalEntryWithDetails item) {
    final entry = item.entry;
    final pages = <JournalPageContent>[];

    // Left / Opening Page
    pages.add(
      JournalPageContent(
        type: JournalPageType.textOpening,
        entry: item,
        title: entry.title.isEmpty
            ? DateFormat('EEEE, MMMM d').format(entry.entryDate)
            : entry.title,
        bodyText: entry.content,
        date: entry.entryDate,
        location: entry.locationName,
        mood: Mood.fromString(entry.mood),
        photoPaths: item.photoAttachments.map((a) => a.uri).toList(),
      ),
    );

    // If photos exist, add photo/scrapbook page
    if (item.photoAttachments.isNotEmpty) {
      pages.add(
        JournalPageContent(
          type: JournalPageType.photoMemories,
          entry: item,
          title: 'Keepsakes & Memories',
          bodyText: entry.content.length > 150
              ? entry.content.substring(
                  150,
                  entry.content.length.clamp(150, 400),
                )
              : 'Cherished photographic moments preserved in ink.',
          date: entry.entryDate,
          location: entry.locationName,
          photoPaths: item.photoAttachments.map((a) => a.uri).toList(),
        ),
      );
    } else {
      // Add quote reflection / scrapbook back page
      pages.add(
        JournalPageContent(
          type: JournalPageType.quoteReflection,
          entry: item,
          title: 'Daily Reflection',
          bodyText: 'Every page turned is a testament to mindful living.',
          date: entry.entryDate,
          quoteText:
              '“Write down what you cannot say aloud. Small moments build a lifetime of wonder.”',
          quoteAuthor: 'Chronicle Study Notes',
        ),
      );
    }

    return pages;
  }
}

/// A single rendered physical page of the journal.
/// Can be positioned on the Left or Right side of the center spine.
typedef JournalPage = JournalPageWidget;

class JournalPageWidget extends StatelessWidget {
  final JournalPageContent content;
  final bool isLeftPage;
  final Color paperColor;
  final VoidCallback? onTap;

  const JournalPageWidget({
    super.key,
    required this.content,
    required this.isLeftPage,
    this.paperColor = const Color(0xFFFAF7EE),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: paperColor,
          // Subtle authentic physical page edge border
          border: Border.all(color: Colors.black.withAlpha(28), width: 0.8),
          borderRadius: BorderRadius.horizontal(
            left: isLeftPage ? const Radius.circular(5) : Radius.zero,
            right: !isLeftPage ? const Radius.circular(5) : Radius.zero,
          ),
        ),
        child: Stack(
          children: [
            // 1. Subtle Paper Ruled Lines / Texture
            Positioned.fill(
              child: CustomPaint(
                painter: _NotebookLinesPainter(isLeftPage: isLeftPage),
              ),
            ),

            // 2. Page Content Body
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isLeftPage ? 22 : 18,
                  20,
                  isLeftPage ? 18 : 22,
                  26,
                ),
                child: _buildBody(context),
              ),
            ),

            // 3. Subtle page numbering footer
            Positioned(
              bottom: 8,
              left: isLeftPage ? 18 : null,
              right: !isLeftPage ? 18 : null,
              child: Text(
                '— ${content.pageNumber} —',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF8B8279),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (content.type) {
      case JournalPageType.textOpening:
        return _buildTextOpeningPage(context);
      case JournalPageType.photoMemories:
        return _buildPhotoPage(context);
      case JournalPageType.quoteReflection:
        return _buildQuotePage(context);
      case JournalPageType.scrapbook:
        return _buildScrapbookPage(context);
      case JournalPageType.textContinuation:
      case JournalPageType.emptyBlank:
        return _buildContinuationPage(context);
    }
  }

  /// Opening chapter-style journal page with Title, Date, Drop Cap, Mood
  Widget _buildTextOpeningPage(BuildContext context) {
    final dateStr = content.date != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(content.date!)
        : '';

    final text = content.bodyText;
    final firstChar = text.isNotEmpty ? text[0] : '';
    final remainingText = text.length > 1 ? text.substring(1) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Strip: Date & Location + Stamp
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF8B7E72),
                    ),
                  ),
                  if (content.location != null &&
                      content.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 10,
                          color: Color(0xFF8B7E72),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          content.location!,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9.5,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF8B7E72),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (content.date != null)
              PostalStamp(
                dateText: DateFormat('dd.MM.yy').format(content.date!),
                locationText: 'CHRONICLE',
                size: 36,
                color: AppColors.postalStampBlue,
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Title
        if (content.title.isNotEmpty)
          Text(
            content.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C2621),
              height: 1.25,
            ),
          ),

        const SizedBox(height: 8),

        // Mood & Weather Badge Row
        if (content.mood != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [MoodBadge(mood: content.mood!, showIntensity: false)],
            ),
          ),

        // Body Text with Drop Cap
        Expanded(
          child: text.isEmpty
              ? const Center(
                  child: Text(
                    'Empty page awaiting your thoughts...',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFAAA095),
                      fontSize: 12,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: firstChar,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(
                              0xFF8B2635,
                            ), // Antique crimson drop cap
                            height: 0.9,
                          ),
                        ),
                        TextSpan(
                          text: remainingText,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 12.5,
                            height: 1.6,
                            color: Color(0xFF2A231C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  /// Photo memories page with taped polaroid and caption
  Widget _buildPhotoPage(BuildContext context) {
    final photo = content.photoPaths.isNotEmpty
        ? content.photoPaths.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pinned Polaroid photo with authentic washi tape
        Expanded(
          flex: 7,
          child: Center(
            child: photo != null && File(photo).existsSync()
                ? Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      PolaroidCard(
                        imagePath: photo,
                        caption: content.date != null
                            ? DateFormat('MMMM yyyy').format(content.date!)
                            : 'Memory',
                        pinnedWithPaperclip: false,
                        rotationDegrees: -2.0,
                      ),
                      Positioned(
                        top: -8,
                        child: WashiTape(
                          color: AppColors.washiTapeSage,
                          width: 55,
                          height: 18,
                          rotationDegrees: 3.0,
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 36,
                        color: Colors.black38,
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 10),

        // Accompanying notes / caption
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2621),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content.bodyText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF5E544A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Literary quote and reflection seal page
  Widget _buildQuotePage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Vintage Archive Rubber Seal
        const VintageRubberStamp(
          text: 'CHRONICLE ARCHIVE • BESPOKE QUALITY',
          centerText: 'VERIFIED',
          size: 48,
          color: AppColors.postalStampRed,
        ),

        const SizedBox(height: 10),

        // Literary Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            content.quoteText ?? '“Write what you cannot say aloud.”',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: Color(0xFF2A231C),
            ),
          ),
        ),

        if (content.quoteAuthor != null) ...[
          const SizedBox(height: 6),
          Text(
            '— ${content.quoteAuthor}',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B8279),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Washi tape accent on bottom
        WashiTape(
          color: AppColors.washiTapeOchre,
          width: 70,
          height: 14,
          rotationDegrees: -2.0,
        ),
      ],
    );
  }

  Widget _buildScrapbookPage(BuildContext context) {
    return _buildPhotoPage(context);
  }

  Widget _buildContinuationPage(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        content.bodyText,
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 12.5,
          height: 1.6,
          color: Color(0xFF2A231C),
        ),
      ),
    );
  }
}

/// Custom painter for soft ruled notebook paper lines
class _NotebookLinesPainter extends CustomPainter {
  final bool isLeftPage;

  _NotebookLinesPainter({required this.isLeftPage});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFDED6C4).withAlpha(45)
      ..strokeWidth = 0.8;

    const lineSpacing = 22.0;
    const startY = 40.0;

    for (double y = startY; y < size.height - 30; y += lineSpacing) {
      canvas.drawLine(
        Offset(isLeftPage ? 20 : 16, y),
        Offset(size.width - (isLeftPage ? 16 : 20), y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NotebookLinesPainter oldDelegate) => false;
}
