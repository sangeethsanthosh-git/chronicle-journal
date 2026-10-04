class NowPlaying {
  final String? title;
  final String? artist;
  final String? album;
  final String? artworkUri;
  final String? applicationName;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final DateTime capturedAt;

  const NowPlaying({
    this.title,
    this.artist,
    this.album,
    this.artworkUri,
    this.applicationName,
    this.isPlaying = false,
    this.duration,
    this.position,
    required this.capturedAt,
  });

  factory NowPlaying.fromMap(Map<dynamic, dynamic> map) {
    return NowPlaying(
      title: map['title'] as String?,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      artworkUri: map['artworkUri'] as String?,
      applicationName: map['applicationName'] as String?,
      isPlaying: map['isPlaying'] as bool? ?? false,
      duration: map['durationMs'] != null
          ? Duration(milliseconds: (map['durationMs'] as num).toInt())
          : null,
      position: map['positionMs'] != null
          ? Duration(milliseconds: (map['positionMs'] as num).toInt())
          : null,
      capturedAt: map['capturedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['capturedAt'] as num).toInt(),
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUri': artworkUri,
      'applicationName': applicationName,
      'isPlaying': isPlaying,
      'durationMs': duration?.inMilliseconds,
      'positionMs': position?.inMilliseconds,
      'capturedAt': capturedAt.millisecondsSinceEpoch,
    };
  }

  NowPlaying copyWith({
    String? title,
    String? artist,
    String? album,
    String? artworkUri,
    String? applicationName,
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    DateTime? capturedAt,
  }) {
    return NowPlaying(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUri: artworkUri ?? this.artworkUri,
      applicationName: applicationName ?? this.applicationName,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
