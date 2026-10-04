import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/local/app_database.dart';
import '../../../../domain/models/journal_entry_with_details.dart';

/// Investigator photo dossier & scrapbook media page matching Reference 4:
/// - Pinned Polaroids with 45° washi tape strips
/// - Authentic ink cancellation seals
/// - Handwritten captions and entry dates
class CodexPhotoDossierPage extends StatelessWidget {
  final List<JournalEntryWithDetails> entries;

  const CodexPhotoDossierPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Collect all photo attachments across all entries
    final List<({Attachment attachment, JournalEntryWithDetails entry})>
    photoKeepsakes = [];

    for (final e in entries) {
      for (final a in e.photoAttachments) {
        photoKeepsakes.add((attachment: a, entry: e));
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDED6C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Media - Photos" matching Reference 4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: Color(0xFF3D6B7D),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MEDIA • DOSSIER',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF2C2218),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D6B7D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${photoKeepsakes.length} PHOTOS',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAF7EE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (photoKeepsakes.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE5D5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4C8B5)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 28,
                          color: Color(0xFF8C7E6D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No photo keepsakes attached yet',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3E31),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Attach photos in your journal to pin them onto this dossier spread.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: Color(0xFF7A6B5D),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemCount: photoKeepsakes.length,
                itemBuilder: (context, index) {
                  final item = photoKeepsakes[index];
                  return _buildDossierPolaroid(
                    item.attachment,
                    item.entry,
                    index,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDossierPolaroid(
    Attachment attachment,
    JournalEntryWithDetails entry,
    int index,
  ) {
    // Subtle rotation: -1.5° or +1.5° alternating
    final angle = (index % 2 == 0) ? -0.025 : 0.025;

    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFDDD4C1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(1, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Polaroid layout
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: _buildPhoto(attachment.uri),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Handwritten caption
                  Text(
                    attachment.caption ??
                        (entry.entry.title.isNotEmpty
                            ? entry.entry.title
                            : 'Journal Photo'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2218),
                    ),
                  ),
                  Text(
                    '${entry.entry.entryDate.day}/${entry.entry.entryDate.month}/${entry.entry.entryDate.year}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8.5,
                      color: Color(0xFF8C7E6D),
                    ),
                  ),
                ],
              ),
            ),

            // Top-center washi tape strip
            Positioned(
              top: -6,
              left: 28,
              right: 28,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
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

  Widget _buildPhoto(String uri) {
    if (uri.startsWith('http')) {
      return Image.network(
        uri,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => _buildPlaceholder(),
      );
    }
    final file = File(uri);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE2DDD1),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 20,
          color: Color(0xFF8C7E6D),
        ),
      ),
    );
  }
}
