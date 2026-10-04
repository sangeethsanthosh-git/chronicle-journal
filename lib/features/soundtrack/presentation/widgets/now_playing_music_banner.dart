import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/now_playing.dart';
import '../providers/soundtrack_providers.dart';

/// An animated, tactile Music Banner that reacts dynamically to music currently
/// playing on the device (or active media sessions).
/// Features:
/// - Smooth spinning vinyl record / album artwork when music is playing
/// - Animated audio equalizer visualizer bars bouncing in real-time
/// - Song title, artist name, and music source badge
/// - Quick action: Tap to attach or open editor with this soundtrack
/// - Collapsible to compact pill / expandable to full illustrated banner
class NowPlayingMusicBanner extends ConsumerStatefulWidget {
  final VoidCallback? onAttach;
  final bool compact;
  final bool showHintWhenIdle;
  final String? customActionLabel;
  final VoidCallback? onCustomAction;

  const NowPlayingMusicBanner({
    super.key,
    this.onAttach,
    this.compact = false,
    this.showHintWhenIdle = false,
    this.customActionLabel,
    this.onCustomAction,
  });

  @override
  ConsumerState<NowPlayingMusicBanner> createState() =>
      _NowPlayingMusicBannerState();
}

class _NowPlayingMusicBannerState extends ConsumerState<NowPlayingMusicBanner>
    with TickerProviderStateMixin {
  late AnimationController _discRotateController;
  late AnimationController _eqController;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _discRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _discRotateController.dispose();
    _eqController.dispose();
    super.dispose();
  }

  void _trySampleTrack() {
    final sample = NowPlaying(
      title: 'Rain & Lo-Fi Vinyl',
      artist: 'Cozy Study Sanctuary',
      album: 'Autumn Memories Vol. 1',
      applicationName: 'Spotify',
      isPlaying: true,
      capturedAt: DateTime.now(),
    );
    ref.read(simulatedTrackProvider.notifier).setTrack(sample);
  }

  void _dismissTrack() {
    ref.read(simulatedTrackProvider.notifier).setTrack(null);
  }

  @override
  Widget build(BuildContext context) {
    final trackAsync = ref.watch(nowPlayingStreamProvider);
    final track = trackAsync.value;

    if (track == null || (track.title == null && track.artist == null)) {
      if (!widget.showHintWhenIdle) {
        return const SizedBox.shrink();
      }
      return _buildIdleMusicHint(context);
    }

    if (_isMinimized) {
      return _buildMinimizedPill(context, track);
    }

    return _buildExpandedBanner(context, track);
  }

  Widget _buildIdleMusicHint(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C241E).withAlpha(160),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5A059).withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.music_note_rounded,
            size: 16,
            color: Color(0xFFC5A059),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No music playing • Start Spotify or test soundtrack',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                color: Color(0xFFFAF7EE),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _trySampleTrack,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A059),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Demo Music',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimizedPill(BuildContext context, NowPlaying track) {
    return GestureDetector(
      onTap: () => setState(() => _isMinimized = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1813).withAlpha(220),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC5A059).withAlpha(140),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSpinningVinylDisc(track, size: 22),
            const SizedBox(width: 8),
            _buildEqualizerBars(height: 12),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                track.title ?? 'Playing Music',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFAF7EE),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.unfold_more_rounded,
              size: 14,
              color: Color(0xFFC5A059),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBanner(BuildContext context, NowPlaying track) {
    final title = track.title ?? 'Unknown Track';
    final artist = track.artist ?? 'Unknown Artist';
    final app = track.applicationName ?? 'Media Player';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF241D17).withAlpha(235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC5A059).withAlpha(140),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with "NOW PLAYING" badge & minimize button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059).withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFC5A059).withAlpha(100),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 11,
                      color: Color(0xFFE8D09B),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'NOW PLAYING SOUNDTRACK',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE8D09B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (app.isNotEmpty)
                Text(
                  '• $app',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 9.5,
                    color: Colors.white.withAlpha(140),
                  ),
                ),
              const Spacer(),
              // Equalizer visualizer
              _buildEqualizerBars(height: 14),
              const SizedBox(width: 8),
              // Minimize button
              InkWell(
                onTap: () => setState(() => _isMinimized = true),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.minimize_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Close demo or dismiss button
              InkWell(
                onTap: _dismissTrack,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Core content row: Spinning vinyl disc + track info + action button
          Row(
            children: [
              // Spinning Vinyl Disc
              _buildSpinningVinylDisc(track, size: 48),

              const SizedBox(width: 12),

              // Title and artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFAF7EE),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artist,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDED6C4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action button (Write Memory / Attach)
              _buildActionButton(context, track),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, NowPlaying track) {
    if (widget.onAttach != null) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5A059),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        onPressed: widget.onAttach,
        icon: const Icon(Icons.bookmark_add_rounded, size: 14),
        label: const Text(
          'Attach',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (widget.onCustomAction != null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5A059),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        onPressed: widget.onCustomAction,
        child: Text(
          widget.customActionLabel ?? 'Use',
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Default action: Create new journal entry with this soundtrack attached
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC5A059),
        foregroundColor: const Color(0xFF1E1813),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      onPressed: () {
        context.push('/editor');
      },
      icon: const Icon(Icons.edit_note_rounded, size: 15),
      label: const Text(
        'Journal',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSpinningVinylDisc(NowPlaying track, {required double size}) {
    return AnimatedBuilder(
      animation: _discRotateController,
      builder: (context, child) {
        return Transform.rotate(
          angle: track.isPlaying
              ? _discRotateController.value * 2 * 3.1415926535
              : 0.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111111),
              border: Border.all(
                color: const Color(0xFFC5A059).withAlpha(120),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric vinyl grooves
                Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                      width: 0.8,
                    ),
                  ),
                ),
                Container(
                  width: size * 0.55,
                  height: size * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(20),
                      width: 0.8,
                    ),
                  ),
                ),

                // Center Label or Artwork
                if (track.artworkUri != null &&
                    File(track.artworkUri!).existsSync())
                  ClipOval(
                    child: Image.file(
                      File(track.artworkUri!),
                      width: size * 0.45,
                      height: size * 0.45,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: size * 0.38,
                    height: size * 0.38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8B2635), // Burgundy center label
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note,
                        size: 11,
                        color: Color(0xFFE8D09B),
                      ),
                    ),
                  ),

                // Spindle hole
                Container(
                  width: size * 0.1,
                  height: size * 0.1,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2C241E),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEqualizerBars({required double height}) {
    return AnimatedBuilder(
      animation: _eqController,
      builder: (context, _) {
        final val = _eqController.value;
        final h1 = (height * (0.3 + 0.7 * val)).clamp(3.0, height);
        final h2 = (height * (0.9 - 0.6 * val)).clamp(3.0, height);
        final h3 = (height * (0.5 + 0.5 * (1.0 - val))).clamp(3.0, height);
        final h4 = (height * (0.4 + 0.5 * val)).clamp(3.0, height);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(h1, height),
            const SizedBox(width: 2),
            _buildBar(h2, height),
            const SizedBox(width: 2),
            _buildBar(h3, height),
            const SizedBox(width: 2),
            _buildBar(h4, height),
          ],
        );
      },
    );
  }

  Widget _buildBar(double h, double maxHeight) {
    return Container(
      width: 2.5,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFC5A059),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
