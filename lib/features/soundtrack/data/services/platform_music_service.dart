import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/now_playing.dart';
import '../../domain/services/music_service.dart';

class PlatformMusicService implements MusicService {
  static const MethodChannel _channel = MethodChannel(
    'com.chronicle.journal/music_service',
  );

  final _nowPlayingController = StreamController<NowPlaying?>.broadcast();

  @override
  Stream<NowPlaying?> get nowPlayingStream => _nowPlayingController.stream;

  @override
  Future<bool> isAvailable() async {
    // Only Android currently supports direct media session reading via NotificationListenerService
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<bool>('isAvailable');
        return result ?? false;
      } catch (e) {
        debugPrint('MusicService isAvailable error: $e');
        return false;
      }
    }
    return false;
  }

  @override
  Future<bool> hasPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<bool>('hasPermission');
        return result ?? false;
      } catch (e) {
        debugPrint('MusicService hasPermission error: $e');
        return false;
      }
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<bool>('requestPermission');
        return result ?? false;
      } catch (e) {
        debugPrint('MusicService requestPermission error: $e');
        return false;
      }
    }
    return false;
  }

  @override
  Future<NowPlaying?> getCurrentTrack() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getCurrentTrack',
        );
        if (result != null) {
          final track = NowPlaying.fromMap(result);
          _nowPlayingController.add(track);
          return track;
        }
      } catch (e) {
        debugPrint('MusicService getCurrentTrack error: $e');
      }
    }
    _nowPlayingController.add(null);
    return null;
  }

  void dispose() {
    _nowPlayingController.close();
  }
}
