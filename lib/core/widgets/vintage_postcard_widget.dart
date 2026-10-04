import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'postal_stamp.dart';

/// Authentic vintage postcard widget reproducing reference Image 1:
/// - Top: Photographic scenic print with retro orange date stamp
/// - Bottom: Classic Postcard with "POST CARD" serif header, cursive message,
///   scalloped postage stamp, cancellation postmark stamp with wavy lines,
///   and address ruled lines.
class VintagePostcardWidget extends StatelessWidget {
  final String? imagePath;
  final String message;
  final DateTime date;
  final String location;
  final String? recipient;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const VintagePostcardWidget({
    super.key,
    this.imagePath,
    required this.message,
    required this.date,
    this.location = 'MIORA POST',
    this.recipient = 'To: Dear Future Self',
    this.isEditable = false,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF7EE), // Vintage cream cardstock
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Photographic Print (Image 1 top half)
              _buildPhotoSection(context),

              // Subtle aged card divider seam
              Container(height: 1.5, color: const Color(0xFFDED6C4)),

              // 2. Bottom Postcard Writing Section (Image 1 bottom half)
              _buildPostcardCardBack(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo or Atmospheric Scenic Placeholder
          if (imagePath != null && File(imagePath!).existsSync())
            Image.file(File(imagePath!), fit: BoxFit.cover)
          else
            _buildScenicPlaceholder(),

          // Vintage color grading overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(20),
                  Colors.transparent,
                  Colors.black.withAlpha(45),
                ],
              ),
            ),
          ),

          // Retro Orange Digital Date Stamp (lower right of photo, e.g. "98 10 24")
          Positioned(
            bottom: 10,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                DateFormat("''yy  MM  dd").format(date),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF8A00), // Vintage amber LED date stamp
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Color(0xFFFF5500), blurRadius: 6)],
                ),
              ),
            ),
          ),

          // Location badge top left
          if (location.isNotEmpty)
            Positioned(
              top: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScenicPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B7E98), // Atmospheric misty blue
            Color(0xFF7E97A6), // Soft mountain horizon
            Color(0xFFB5A895), // Warm foreground meadow
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: 40,
              color: Colors.white.withAlpha(180),
            ),
            const SizedBox(height: 4),
            Text(
              'MEMORIES & VIEWS',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostcardCardBack(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F5EA), // Authentic aged postcard cream
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centered "POST CARD" vintage typography header with optional Edit button
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 1,
                          color: const Color(0xFF9E9282),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'POST CARD',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: Color(0xFF2C2621),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 1,
                          color: const Color(0xFF9E9282),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'UNIVERSAL POSTAL UNION • CARTE POSTALE',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 7.5,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A7F73),
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditable || onEdit != null)
                Positioned(
                  right: 0,
                  top: -8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      size: 22,
                      color: Color(0xFF8B2635),
                    ),
                    tooltip: 'Edit Postcard',
                    onPressed: onEdit,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Two-column Postcard body (Message on left, Address & Stamps on right)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Handwritten Cursive Message
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This space for writing messages',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 8.5,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF9A8F83),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message.isEmpty
                            ? 'A quiet moment captured in time. Remembering the gentle morning sunlight and the warmth of a peaceful day.'
                            : message,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF2A231C), // Authentic dark sepia ink
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Center vertical line divider
                Container(width: 1, color: const Color(0xFFD4C8B5)),

                const SizedBox(width: 10),

                // Right Column: Scalloped Postage Stamp, Cancellation, and Address Lines
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Postage Stamp + Cancellation Mark
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cancellation Stamp overlapping towards the left
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: PostalStamp(
                                dateText: DateFormat('dd.MM.yy').format(date),
                                locationText: location.toUpperCase(),
                                size: 44,
                                color: AppColors.postalStampBlue,
                              ),
                            ),
                          ),
                          // Scalloped Postage Stamp
                          _buildPostageStamp(),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Address Section header
                      Text(
                        'The address only to be written here',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 8.5,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF5E544C),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Ruled Address Lines (matching Image 1)
                      _buildAddressLine(recipient ?? 'To: Dear Future Self'),
                      _buildAddressLine('Miora Archive, Vol. 1'),
                      _buildAddressLine(
                        '${location.isEmpty ? "Quiet Thoughts" : location}, Planet Earth',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostageStamp() {
    return Container(
      width: 44,
      height: 54,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3E8),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFFB55D4C),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB55D4C).withAlpha(20),
          border: Border.all(color: const Color(0xFFB55D4C), width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text(
              'POSTAGE',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 6.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Color(0xFFB55D4C),
              ),
            ),
            Icon(
              Icons.local_florist_rounded,
              size: 13,
              color: Color(0xFFB55D4C),
            ),
            Text(
              '15¢',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB55D4C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF423B33),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Container(height: 0.8, color: const Color(0xFFD4C8B5)),
        ],
      ),
    );
  }
}
