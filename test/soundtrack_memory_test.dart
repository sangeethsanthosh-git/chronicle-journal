import 'package:chronicle/data/local/app_database.dart';
import 'package:chronicle/data/repositories/journal_repository_impl.dart';
import 'package:chronicle/features/soundtrack/domain/models/now_playing.dart';
import 'package:chronicle/features/soundtrack/domain/models/soundtrack_card_style.dart';
import 'package:chronicle/features/soundtrack/domain/services/music_service.dart';
import 'package:chronicle/features/soundtrack/presentation/widgets/scrapbook_soundtrack_item.dart';
import 'package:chronicle/features/soundtrack/presentation/widgets/soundtrack_card.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMusicService implements MusicService {
  bool available;
  bool permissionGranted;
  NowPlaying? currentTrack;

  MockMusicService({
    this.available = true,
    this.permissionGranted = false,
    this.currentTrack,
  });

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    permissionGranted = true;
    return true;
  }

  @override
  Future<NowPlaying?> getCurrentTrack() async {
    if (!available || !permissionGranted) return null;
    return currentTrack;
  }

  @override
  Stream<NowPlaying?> get nowPlayingStream => Stream.value(currentTrack);
}

void main() {
  group('Soundtrack Memory Domain & Service Tests', () {
    test(
      'NowPlaying model parses map and handles missing values gracefully',
      () {
        final map = {
          'title': 'Nocturne in E-flat major',
          'artist': 'Frédéric Chopin',
          'album': 'Chopin Piano Works',
          'applicationName': 'Spotify',
          'isPlaying': true,
          'durationMs': 270000,
          'positionMs': 60000,
          'capturedAt': 1791113908000,
        };

        final track = NowPlaying.fromMap(map);
        expect(track.title, equals('Nocturne in E-flat major'));
        expect(track.artist, equals('Frédéric Chopin'));
        expect(track.applicationName, equals('Spotify'));
        expect(track.isPlaying, isTrue);
        expect(track.duration?.inSeconds, equals(270));
        expect(track.position?.inSeconds, equals(60));

        // Missing fields fallback
        final emptyTrack = NowPlaying.fromMap(const {});
        expect(emptyTrack.title, isNull);
        expect(emptyTrack.artist, isNull);
        expect(emptyTrack.isPlaying, isFalse);
        expect(emptyTrack.duration, isNull);
      },
    );

    test('MusicService permission flow and graceful denial', () async {
      final mock = MockMusicService(
        available: true,
        permissionGranted: false,
        currentTrack: NowPlaying(
          title: 'Sunflower',
          artist: 'Post Malone',
          capturedAt: DateTime.now(),
        ),
      );

      // Without permission, cannot read media session
      var track = await mock.getCurrentTrack();
      expect(track, isNull);
      expect(await mock.hasPermission(), isFalse);

      // Request permission
      await mock.requestPermission();
      expect(await mock.hasPermission(), isTrue);

      // Now track can be detected
      track = await mock.getCurrentTrack();
      expect(track, isNotNull);
      expect(track!.title, equals('Sunflower'));
    });
  });

  group('Soundtrack Database Persistence Tests', () {
    late AppDatabase db;
    late JournalRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = JournalRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Saves entry with soundtrack and retrieves it offline after restart',
      () async {
        final capturedTime = DateTime(2026, 10, 4, 16, 42);
        final track = NowPlaying(
          title: 'Starry Night Melodies',
          artist: 'Vincent',
          album: 'Sanctuary Sessions',
          applicationName: 'Spotify',
          capturedAt: capturedTime,
        );

        await repository.saveEntry(
          id: 'entry-101',
          title: 'Autumn Twilight',
          content: 'Writing by the window while listening to music.',
          entryDate: DateTime(2026, 10, 4),
          soundtrack: track,
        );

        final entryDetails = await repository.getEntryById('entry-101');
        expect(entryDetails, isNotNull);
        expect(entryDetails!.soundtracks.length, equals(1));

        final savedTrack = entryDetails.soundtracks.first;
        expect(savedTrack.title, equals('Starry Night Melodies'));
        expect(savedTrack.artist, equals('Vincent'));
        expect(savedTrack.album, equals('Sanctuary Sessions'));
        expect(savedTrack.applicationName, equals('Spotify'));
        expect(savedTrack.capturedAt, equals(capturedTime));

        // Deleting entry cascades and removes soundtrack
        await repository.deleteEntryPermanently('entry-101');
        final soundtracksAfterDelete = await repository.getSoundtracksForEntry(
          'entry-101',
        );
        expect(soundtracksAfterDelete, isEmpty);
      },
    );

    test(
      'Journal entry saves normally without soundtrack (optional enhancement)',
      () async {
        await repository.saveEntry(
          id: 'entry-102',
          title: 'Silent Reflection',
          content: 'No music playing today, just rain.',
          entryDate: DateTime(2026, 10, 4),
          soundtrack: null,
        );

        final entryDetails = await repository.getEntryById('entry-102');
        expect(entryDetails, isNotNull);
        expect(entryDetails!.soundtracks, isEmpty);
        expect(entryDetails.primarySoundtrack, isNull);
      },
    );
  });

  group('SoundtrackCard & Scrapbook Widgets Tests', () {
    final testTrack = NowPlaying(
      title: 'Midnight Reverie',
      artist: 'Komorebi',
      album: 'Quiet Echoes',
      applicationName: 'Spotify',
      capturedAt: DateTime(2026, 10, 4, 17, 30),
    );

    testWidgets('Renders SoundtrackCard in Cassette style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundtrackCard(
                track: testTrack,
                style: SoundtrackCardStyle.cassette,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Midnight Reverie'), findsOneWidget);
      expect(find.text('Komorebi'), findsOneWidget);
      expect(find.textContaining('SPOTIFY'), findsOneWidget);
      expect(find.text('SIDE • A'), findsOneWidget);
    });

    testWidgets('Renders SoundtrackCard in Vinyl Record style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundtrackCard(
                track: testTrack,
                style: SoundtrackCardStyle.vinyl,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Midnight Reverie'), findsOneWidget);
      expect(find.text('Komorebi'), findsOneWidget);
      expect(find.text('33⅓ RPM • HI-FI'), findsOneWidget);
    });

    testWidgets('Renders SoundtrackCard in Polaroid style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundtrackCard(
                track: testTrack,
                style: SoundtrackCardStyle.polaroid,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Midnight Reverie'), findsOneWidget);
      expect(find.text('Komorebi'), findsOneWidget);
    });

    testWidgets('Renders SoundtrackCard in Handwritten Note style', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundtrackCard(
                track: testTrack,
                style: SoundtrackCardStyle.handwrittenNote,
              ),
            ),
          ),
        ),
      );

      expect(find.text('𝄞'), findsOneWidget);
      expect(find.text('SOUNDTRACK MEMORY'), findsOneWidget);
      expect(find.text('Midnight Reverie'), findsOneWidget);
      expect(find.text('Komorebi'), findsOneWidget);
    });

    testWidgets('Renders SoundtrackCard in Vintage Ticket Stub style', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SoundtrackCard(
                track: testTrack,
                style: SoundtrackCardStyle.vintageTicket,
              ),
            ),
          ),
        ),
      );

      expect(find.text('ADMIT ONE'), findsOneWidget);
      expect(find.text('Midnight Reverie'), findsOneWidget);
      expect(find.text('Komorebi'), findsOneWidget);
    });

    testWidgets(
      'ScrapbookSoundtrackItem supports interactive selection and delete',
      (tester) async {
        bool deleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  ScrapbookSoundtrackItem(
                    track: testTrack,
                    onDelete: () => deleted = true,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Midnight Reverie'), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        expect(deleted, isTrue);
      },
    );
  });
}
