import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/now_playing.dart';
import '../../domain/models/soundtrack_card_style.dart';

/// Tactile, physical Soundtrack Card memory object for Journal entries,
/// Book reader spreads, and Scrapbook canvases.
class SoundtrackCard extends StatelessWidget {
  final NowPlaying track;
  final SoundtrackCardStyle style;
  final VoidCallback? onDelete;
  final ValueChanged<SoundtrackCardStyle>? onStyleChanged;
  final VoidCallback? onTap;
  final double width;
  final bool isInteractive;

  const SoundtrackCard({
    super.key,
    required this.track,
    this.style = SoundtrackCardStyle.cassette,
    this.onDelete,
    this.onStyleChanged,
    this.onTap,
    this.width = 320,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardBody;
    switch (style) {
      case SoundtrackCardStyle.cassette:
        cardBody = _buildCassetteStyle(context);
        break;
      case SoundtrackCardStyle.vinyl:
        cardBody = _buildVinylStyle(context);
        break;
      case SoundtrackCardStyle.polaroid:
        cardBody = _buildPolaroidStyle(context);
        break;
      case SoundtrackCardStyle.handwrittenNote:
        cardBody = _buildHandwrittenStyle(context);
        break;
      case SoundtrackCardStyle.vintageTicket:
        cardBody = _buildTicketStyle(context);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          cardBody,
          if (onDelete != null)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC04A49),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          if (onStyleChanged != null)
            Positioned(
              bottom: 6,
              right: 6,
              child: PopupMenuButton<SoundtrackCardStyle>(
                tooltip: 'Change Soundtrack Card Style',
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.vintageGold,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                onSelected: onStyleChanged,
                itemBuilder: (context) => SoundtrackCardStyle.values.map((s) {
                  return PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(
                          s == style
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 16,
                          color: AppColors.vintageGold,
                        ),
                        const SizedBox(width: 8),
                        Text(s.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // 1. CASSETTE TAPE STYLE
  Widget _buildCassetteStyle(BuildContext context) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName;
    final timeStr = DateFormat('h:mm a').format(track.capturedAt);

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2725),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF423B37), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cassette Header with App Source & Screw Marks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScrewHole(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.audiotrack,
                      size: 12,
                      color: Color(0xFFC5A059),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        app != null
                            ? '♫ ${app.toUpperCase()}'
                            : '♫ SOUNDTRACK MEMORY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFFC5A059),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildScrewHole(),
            ],
          ),
          const SizedBox(height: 8),

          // Paper Tape Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1E6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD6C8B2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildArtworkThumbnail(size: 46),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF2C241E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: Color(0xFF6B584B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Center Cassette Spool Window
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSpoolHub(),
                      Container(
                        width: 48,
                        height: 7,
                        color: const Color(0xFF4A3423), // Magnetic tape
                      ),
                      _buildSpoolHub(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Timestamp & SIDE A Mark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SIDE • A',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9E8E81),
                ),
              ),
              Text(
                'CAPTURED $timeStr',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 9,
                  letterSpacing: 0.8,
                  color: Color(0xFF9E8E81),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. VINYL RECORD JACKET STYLE
  Widget _buildVinylStyle(BuildContext context) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName;
    final timeStr = DateFormat('h:mm a').format(track.capturedAt);

    return Container(
      width: width,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD3C5AE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 10,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vinyl record slipping out on the right
          Positioned(
            right: 12,
            top: 10,
            bottom: 10,
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _VinylRecordPainter(),
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB5483B),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9F5EC),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Jacket Card Content (Left side covers)
          Container(
            width: width - 65,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              border: Border(
                right: BorderSide(color: const Color(0xFFD3C5AE), width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildArtworkThumbnail(size: 42),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (app != null)
                            Text(
                              '♫ ${app.toUpperCase()}',
                              style: const TextStyle(
                                fontFamily: 'serif',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB5483B),
                              ),
                            ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF2C241E),
                            ),
                          ),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                              color: Color(0xFF6B584B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '33⅓ RPM • HI-FI',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        color: Color(0xFF8C7B6B),
                      ),
                    ),
                    Text(
                      '♪ $timeStr',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 9,
                        color: Color(0xFF8C7B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. POLAROID MUSIC KEEPSAKE STYLE
  Widget _buildPolaroidStyle(BuildContext context) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName;
    final timeStr = DateFormat('h:mm a').format(track.capturedAt);

    return Container(
      width: width * 0.85,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5DDD0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 10,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 45-degree Washi Tape Strip
          Positioned(
            top: -26,
            left: 20,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 60,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xCCBF9E7A),
                  border: Border.all(color: const Color(0x44A08260)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Square Album Cover / Artwork
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5D8),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFFD6CAB8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: _buildArtworkImage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Handwritten Title and Artist
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2C241E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Color(0xFF6B584B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '♪ ${app ?? "Soundtrack"} • $timeStr',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 9,
                  color: Color(0xFF9E8E81),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. HANDWRITTEN MUSIC NOTE STYLE
  Widget _buildHandwrittenStyle(BuildContext context) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName;
    final timeStr = DateFormat('h:mm a').format(track.capturedAt);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9CCB7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '𝄞',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC5A059),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text(
                        'SOUNDTRACK MEMORY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Color(0xFF8C7355),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  color: Color(0xFF8C7355),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2D6C3), height: 16),
          Row(
            children: [
              _buildArtworkThumbnail(size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2C241E),
                      ),
                    ),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Color(0xFF5E4B3E),
                      ),
                    ),
                    if (app != null)
                      Text(
                        'via $app',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 10,
                          color: Color(0xFF8C7B6B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. VINTAGE TICKET STUB STYLE
  Widget _buildTicketStyle(BuildContext context) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName;
    final timeStr = DateFormat('h:mm a').format(track.capturedAt);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCFBFAB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Stub
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE6DDCF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADMIT ONE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Color(0xFF7A6858),
                    ),
                  ),
                  const Icon(Icons.confirmation_number_outlined, size: 20),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: Color(0xFF7A6858),
                    ),
                  ),
                ],
              ),
            ),

            // Perforated Vertical Line
            CustomPaint(
              size: const Size(2, double.infinity),
              painter: _DashedLinePainter(),
            ),

            // Main Ticket Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildArtworkThumbnail(size: 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (app != null)
                            Text(
                              app.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9E846A),
                              ),
                            ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF2C241E),
                            ),
                          ),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                              color: Color(0xFF5E4B3E),
                            ),
                          ),
                        ],
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

  // Helper: Screws on cassette
  Widget _buildScrewHole() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A18),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF4A423D)),
      ),
    );
  }

  // Helper: Spool Hub on cassette
  Widget _buildSpoolHub() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8C7355), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1A18),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Helper: Artwork thumbnail with safe local/remote fallback
  Widget _buildArtworkThumbnail({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5D8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD6CAB8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: _buildArtworkImage(),
      ),
    );
  }

  Widget _buildArtworkImage() {
    final uri = track.artworkUri;
    if (uri != null && uri.isNotEmpty) {
      if (uri.startsWith('http://') || uri.startsWith('https://')) {
        return Image.network(
          uri,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackMusicIcon(),
        );
      } else {
        final file = File(uri);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackMusicIcon(),
          );
        }
      }
    }
    return _buildFallbackMusicIcon();
  }

  Widget _buildFallbackMusicIcon() {
    return Container(
      color: const Color(0xFFE2D6C3),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 22,
          color: Color(0xFF8C7355),
        ),
      ),
    );
  }
}

class _VinylRecordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final discPaint = Paint()
      ..color = const Color(0xFF161413)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, discPaint);

    // Grooves
    final groovePaint = Paint()
      ..color = const Color(0xFF2A2624)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = radius * 0.45; r < radius * 0.95; r += 5.0) {
      canvas.drawCircle(center, r, groovePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB5A795)
      ..strokeWidth = 1.5;

    double y = 4;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 4), paint);
      y += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
