import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/repositories/preferences_repository.dart';
import '../../../soundtrack/domain/models/now_playing.dart';
import '../../../soundtrack/presentation/providers/soundtrack_providers.dart';
import '../../../../presentation/providers/preferences_provider.dart';

/// Modal dialog for detecting and attaching currently playing music as a Soundtrack Memory.
class AttachSoundtrackDialog extends ConsumerStatefulWidget {
  const AttachSoundtrackDialog({super.key});

  static Future<NowPlaying?> show(BuildContext context) {
    return showDialog<NowPlaying>(
      context: context,
      builder: (context) => const AttachSoundtrackDialog(),
    );
  }

  @override
  ConsumerState<AttachSoundtrackDialog> createState() =>
      _AttachSoundtrackDialogState();
}

class _AttachSoundtrackDialogState
    extends ConsumerState<AttachSoundtrackDialog> {
  bool _isLoading = true;
  NowPlaying? _detectedTrack;
  bool _isManualEntry = false;
  final _manualTitleController = TextEditingController();
  final _manualArtistController = TextEditingController();
  final _manualAlbumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detectCurrentMusic();
  }

  @override
  void dispose() {
    _manualTitleController.dispose();
    _manualArtistController.dispose();
    _manualAlbumController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentMusic() async {
    setState(() => _isLoading = true);

    final prefs = ref.read(preferencesProvider);
    final musicService = ref.read(musicServiceProvider);

    // If music integration is not enabled in preferences, prompt
    if (!prefs.isMusicIntegrationEnabled) {
      final isAvailable = await musicService.isAvailable();
      if (!isAvailable) {
        setState(() {
          _isLoading = false;
          _detectedTrack = null;
        });
        return;
      }
    }

    try {
      final track = await musicService.getCurrentTrack();
      if (mounted) {
        setState(() {
          _detectedTrack = track;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectedTrack = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark
          ? AppColors.paperSurfaceDark
          : AppColors.paperSurfaceLight,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.vintageGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: AppColors.vintageGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOUNDTRACK MEMORY',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.vintageGold,
                        ),
                      ),
                      Text(
                        'Attach current music to your entry',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Content Body
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.vintageGold),
                    SizedBox(height: 16),
                    Text(
                      'Detecting active media session...',
                      style: TextStyle(fontFamily: 'serif', fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (_isManualEntry)
              _buildManualEntryForm()
            else if (_detectedTrack != null)
              _buildDetectedTrackPreview()
            else
              _buildNoMusicFallback(prefs),

            const SizedBox(height: 16),

            // Action Buttons
            if (!_isLoading) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedTrackPreview() {
    final track = _detectedTrack!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.vintageGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.vintageGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Artwork / icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE5D8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.album_rounded,
                  color: AppColors.vintageGold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (track.applicationName != null)
                      Text(
                        '♫ ${track.applicationName!.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.vintageGold,
                        ),
                      ),
                    Text(
                      track.title ?? 'Unknown Track',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      track.artist ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                track.isPlaying ? '▶ Currently Playing' : '⏸ Paused',
                style: TextStyle(
                  fontSize: 11,
                  color: track.isPlaying ? Colors.green : Colors.grey,
                ),
              ),
              Text(
                'Captured at ${TimeOfDay.fromDateTime(track.capturedAt).format(context)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoMusicFallback(UserPreferences prefs) {
    return Column(
      children: [
        Icon(
          Icons.music_off_outlined,
          size: 44,
          color: Colors.grey.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        const Text(
          'No music is currently playing.',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Play a song on Spotify, YouTube Music, or any media app, or add a manual soundtrack note below.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => setState(() => _isManualEntry = true),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Add Manual Soundtrack Note'),
        ),
      ],
    );
  }

  Widget _buildManualEntryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _manualTitleController,
          decoration: const InputDecoration(
            labelText: 'Song Title *',
            hintText: 'e.g. Clair de Lune',
            prefixIcon: Icon(Icons.music_note_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualArtistController,
          decoration: const InputDecoration(
            labelText: 'Artist Name',
            hintText: 'e.g. Claude Debussy',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualAlbumController,
          decoration: const InputDecoration(
            labelText: 'Album or Vinyl Record',
            hintText: 'e.g. Suite Bergamasque',
            prefixIcon: Icon(Icons.album_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        if (_isManualEntry)
          ElevatedButton(
            onPressed: () {
              final title = _manualTitleController.text.trim();
              if (title.isEmpty) return;
              final track = NowPlaying(
                title: title,
                artist: _manualArtistController.text.trim().isNotEmpty
                    ? _manualArtistController.text.trim()
                    : null,
                album: _manualAlbumController.text.trim().isNotEmpty
                    ? _manualAlbumController.text.trim()
                    : null,
                capturedAt: DateTime.now(),
              );
              Navigator.pop(context, track);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vintageGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Attach Note'),
          )
        else if (_detectedTrack != null)
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, _detectedTrack),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vintageGold,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Attach'),
          )
        else
          TextButton.icon(
            onPressed: _detectCurrentMusic,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry Detection'),
          ),
      ],
    );
  }
}
