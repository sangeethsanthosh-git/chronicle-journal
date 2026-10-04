import 'package:flutter_riverpod/flutter_riverpod.dart';
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
