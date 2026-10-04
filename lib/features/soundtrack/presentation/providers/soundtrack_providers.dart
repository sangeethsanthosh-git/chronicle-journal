import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/preferences_provider.dart';
import '../../data/services/platform_music_service.dart';
import '../../domain/models/now_playing.dart';
import '../../domain/services/music_service.dart';

final musicServiceProvider = Provider<MusicService>((ref) {
  final service = PlatformMusicService();
  ref.onDispose(() => service.dispose());
  return service;
});

final musicAvailabilityProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(musicServiceProvider);
  return service.isAvailable();
});

final musicPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(musicServiceProvider);
  return service.hasPermission();
});

final activeTrackProvider = FutureProvider.autoDispose<NowPlaying?>((
  ref,
) async {
  final service = ref.watch(musicServiceProvider);
  return service.getCurrentTrack();
});

/// Continuous Stream of currently playing music that polls active media sessions
/// every 3 seconds when music integration is enabled.
final nowPlayingStreamProvider = StreamProvider.autoDispose<NowPlaying?>((ref) async* {
  final prefs = ref.watch(preferencesProvider);
  if (!prefs.isMusicIntegrationEnabled) {
    yield null;
    return;
  }

  final service = ref.watch(musicServiceProvider);
  final initial = await service.getCurrentTrack();
  yield initial;

  // Poll active media sessions periodically while user is in the app
  final periodicStream = Stream.periodic(const Duration(seconds: 3));
  await for (final _ in periodicStream) {
    final track = await service.getCurrentTrack();
    yield track;
  }
});
