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

class SimulatedTrackNotifier extends Notifier<NowPlaying?> {
  @override
  NowPlaying? build() => null;

  void setTrack(NowPlaying? t) => state = t;
}

final simulatedTrackProvider =
    NotifierProvider<SimulatedTrackNotifier, NowPlaying?>(
      SimulatedTrackNotifier.new,
    );

final activeTrackProvider = FutureProvider.autoDispose<NowPlaying?>((
  ref,
) async {
  final sim = ref.watch(simulatedTrackProvider);
  if (sim != null) return sim;
  final service = ref.watch(musicServiceProvider);
  return service.getCurrentTrack();
});

/// Continuous Stream of currently playing music that polls active media sessions
/// every 3 seconds when music integration is enabled.
final nowPlayingStreamProvider = StreamProvider.autoDispose<NowPlaying?>((ref) async* {
  final sim = ref.watch(simulatedTrackProvider);
  if (sim != null) {
    yield sim;
    return;
  }

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
    final currentSim = ref.read(simulatedTrackProvider);
    if (currentSim != null) {
      yield currentSim;
    } else {
      final track = await service.getCurrentTrack();
      yield track;
    }
  }
});
