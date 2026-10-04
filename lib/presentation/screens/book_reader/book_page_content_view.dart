import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/book_margin_doodles.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/polaroid_card.dart';
import '../../../core/widgets/postal_stamp.dart';
import '../../../core/widgets/washi_tape.dart';
import 'book_page_data.dart';

/// Renders the contents of an individual physical book page with editorial
/// typography, drop caps, taped photos, postal stamps, margin doodles,
/// and bottom page numerals.
class BookPageContentView extends StatelessWidget {
  final BookPageData page;
  final bool isLeftPage;

  const BookPageContentView({
    super.key,
    required this.page,
    this.isLeftPage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBF8EE), // Cream paper
      padding: EdgeInsets.only(
        top: 20,
        bottom: 22,
        left: isLeftPage ? 22 : 18,
        right: isLeftPage ? 18 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row (Stamp, Date, Mood, Doodles)
          _buildPageHeader(context),

          const SizedBox(height: 12),

          // Main Page Content (Expanded scrollable or flex)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (page.type == BookPageType.chapterOpening) ...[
                    // Large Expressive Journal Title (inspired by reference image)
                    _buildExpressiveTitle(),
                    const SizedBox(height: 14),
                  ] else if (page.title.isNotEmpty &&
                      page.pageNumber % 2 == 0) ...[
                    // Subtitle / Page Header
                    _buildSubHeader(),
                    const SizedBox(height: 12),
                  ],

                  // Body Text with optional Drop Cap
                  _buildBodyText(),

                  const SizedBox(height: 16),

                  // Taped Photo (Polaroid with Washi Tape)
                  if (page.photoPath != null) ...[
                    Center(
                      child: PolaroidCard(
                        imagePath: page.photoPath!,
                        caption: page.caption,
                        width: 175,
                        rotationDegrees: isLeftPage ? -2.5 : 2.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Audio Recording Player
                  if (page.audioPath != null) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(180),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.paperCardBorderLight,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: AudioPlayerWidget(audioPath: page.audioPath!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Epilogue / Tags & Signatures
                  if (page.type == BookPageType.epilogueAndTags &&
                      page.tags.isNotEmpty) ...[
                    _buildTagsSection(),
                    const SizedBox(height: 12),
                  ],

                  // Closing Signature & Quote
                  if (page.type == BookPageType.epilogueAndTags)
                    _buildClosingSignature(),
                ],
              ),
            ),
          ),

          // Bottom Page Numerals & Margin Doodle
          _buildPageFooter(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    if (page.type == BookPageType.chapterOpening) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 240;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PostalStamp(
                      dateText: DateFormat('dd.MM.yy').format(page.date),
                      locationText: (page.location ?? 'JOURNAL').toUpperCase(),
                      size: 38,
                      color: AppColors.postalStampRed,
                    ),
                    MoodBadge(mood: page.mood, intensity: page.moodIntensity),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(page.date),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E655F),
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Postal Stamp with date & location
              PostalStamp(
                dateText: DateFormat('dd.MM.yy').format(page.date),
                locationText: (page.location ?? 'JOURNAL').toUpperCase(),
                size: 52,
                color: AppColors.postalStampRed,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(page.date),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E655F),
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (page.weather != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '⛅ ${page.weather}',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF8B8279),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Mood Badge with washi tape strip
              Column(
                children: [
                  WashiTape(
                    width: 44,
                    height: 12,
                    rotationDegrees: 3,
                    color: AppColors.washiTapeSage,
                  ),
                  const SizedBox(height: 2),
                  MoodBadge(mood: page.mood, intensity: page.moodIntensity),
                ],
              ),
            ],
          );
        },
      );
    }

    // Header for continuation pages
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMM d, yyyy').format(page.date).toUpperCase(),
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9E958D),
          ),
        ),
        if (page.doodle != null)
          BookMarginDoodle(
            type: page.doodle!,
            size: 26,
            color: const Color(0xFF7A6D60),
          ),
      ],
    );
  }

  Widget _buildExpressiveTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Handwritten / Bold editorial title inspired by reference image
            Text(
              page.title.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                height: 1.2,
                color: Color(0xFF1E1610),
                shadows: [
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
            // Washi tape accent on title corner
            Positioned(
              top: -8,
              right: 4,
              child: WashiTape(
                width: 48,
                height: 13,
                rotationDegrees: -8,
                color: AppColors.washiTapeKraft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1.5, width: 80, color: const Color(0xFFC5A059)),
      ],
    );
  }

  Widget _buildSubHeader() {
    return Row(
      children: [
        Container(width: 4, height: 16, color: const Color(0xFFC5A059)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            page.title,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2621),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyText() {
    if (page.text.isEmpty) return const SizedBox.shrink();

    if (page.hasDropCap && page.text.isNotEmpty) {
      final firstLetter = page.text.substring(0, 1);
      final remainingFirstPara = page.text.substring(1);

      return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.only(right: 6, bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2621),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFBF8EE),
                  ),
                ),
              ),
            ),
            TextSpan(
              text: remainingFirstPara,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 14.5,
                height: 1.65,
                color: Color(0xFF2C2621),
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      page.text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 14.5,
        height: 1.65,
        color: Color(0xFF2C2621),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: page.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFE9DA),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFDCD2C0)),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5E544A),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClosingSignature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFDED6C4), thickness: 1, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '— Recorded in Chronicle',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF7A6D60),
              ),
            ),
            if (page.isFavorite)
              const Icon(
                Icons.star_rounded,
                color: AppColors.vintageGold,
                size: 20,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isLeftPage && page.doodle != null)
            BookMarginDoodle(
              type: page.doodle!,
              size: 24,
              color: const Color(0xFF8B7E72),
            )
          else
            const SizedBox(width: 24),

          // Authentic printed page numeral: "— 3 —"
          Text(
            '— ${page.pageNumber} —',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF7A6D60),
            ),
          ),

          if (!isLeftPage && page.doodle != null)
            BookMarginDoodle(
              type: page.doodle!,
              size: 24,
              color: const Color(0xFF8B7E72),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}
