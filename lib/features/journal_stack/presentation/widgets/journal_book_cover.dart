import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';

/// Renders the prominent physical illustrated front cover of a journal volume
/// with perspective frame, gold foil embossing, paper texture, and book cloth border.
class JournalBookCover extends StatelessWidget {
  final JournalStackItem item;
  final double width;
  final double height;
  final bool hasPerspective;

  const JournalBookCover({
    super.key,
    required this.item,
    this.width = 200,
    this.height = 280,
    this.hasPerspective = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = item.spineColor;
    final darkerTone = Color.lerp(baseColor, Colors.black, 0.35)!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          // Spine crease shadow on the left
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(-4, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(8, 12),
            blurRadius: 18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: Stack(
          children: [
            // 1. Cover Background (Cloth texture gradient)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [baseColor, darkerTone],
                  ),
                ),
              ),
            ),

            // 2. Custom Cover Artwork or Storybook Preset
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                  top: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildCoverArt(item),
                ),
              ),
            ),

            // 3. Vintage Book Cloth / Leather Frame & Debossed Border
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Left Spine Hinge / Crease Shadow (gives physical depth to the book cover)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 12,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 5. Editorial Content Overlay (Title, Category, Dates)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Category Emblem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.category.icon,
                          size: 14,
                          color: const Color(0xFFFAF7EE).withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.category.label.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 10,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFFFAF7EE,
                            ).withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // Central Journal Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFFFFFDF8),
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.description!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 10,
                                color: const Color(
                                  0xFFE8DFCE,
                                ).withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Bottom Date Range & Entry count tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7EE).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.entryCount} ENTRIES • ${item.dateRangeText}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B2E21),
                          letterSpacing: 0.5,
                        ),
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

  Widget _buildCoverArt(JournalStackItem item) {
    if (item.coverImage != null && item.coverImage!.isNotEmpty) {
      if (item.coverImage!.startsWith('http')) {
        return Image.network(
          item.coverImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _buildFallbackArt(item),
        );
      }
      final file = File(item.coverImage!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _buildFallbackArt(item),
        );
      }
    }
    return _buildFallbackArt(item);
  }

  Widget _buildFallbackArt(JournalStackItem item) {
    // Elegant procedural storybook background
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            item.spineColor.withValues(alpha: 0.9),
            Color.lerp(item.spineColor, Colors.black, 0.45)!,
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.15,
          child: Icon(item.category.icon, size: 110, color: Colors.white),
        ),
      ),
    );
  }
}
