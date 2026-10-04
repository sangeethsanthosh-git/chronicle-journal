import '../models/now_playing.dart';

/// Platform-independent abstraction for querying currently playing music
/// from the host operating system.
///
/// Follows strict privacy guidelines: never continuously polls or records listening
/// history in the background. Only invoked on explicit user actions.
abstract class MusicService {
  /// Query the active media session right now.
  /// Returns null if no media is playing, permission is denied, or feature is unavailable.
  Future<NowPlaying?> getCurrentTrack();

  /// Stream of now-playing updates when actively queried.
  Stream<NowPlaying?> get nowPlayingStream;

  /// Check whether the platform supports media session inspection.
  Future<bool> isAvailable();

  /// Check whether the user has granted necessary notification/media permissions.
  Future<bool> hasPermission();

  /// Trigger the OS permission request or open system notification settings.
  Future<bool> requestPermission();
}
