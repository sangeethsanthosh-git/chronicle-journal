import 'package:chronicle/core/widgets/reader_atmosphere_background.dart';
import 'package:chronicle/domain/repositories/preferences_repository.dart';
import 'package:chronicle/features/journal/presentation/widgets/page_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reader Wallpaper & Atmosphere Tests', () {
    test('kReaderPresetWallpapers contains all four artistic presets', () {
      expect(kReaderPresetWallpapers.length, equals(4));

      final ids = kReaderPresetWallpapers.map((w) => w.id).toList();
      expect(ids, contains('botanical_deer'));
      expect(ids, contains('ethereal_goddess'));
      expect(ids, contains('cozy_portrait'));
      expect(ids, contains('artistic_study'));

      expect(
        kReaderPresetWallpapers.first.assetPath,
        equals('assets/botanical_deer.jpg'),
      );
    });

    test('UserPreferences has correct default reader background settings', () {
      const prefs = UserPreferences();
      expect(prefs.readerBackgroundMode, equals('asset'));
      expect(prefs.readerBackgroundAsset, equals('assets/botanical_deer.jpg'));
      expect(prefs.readerCustomImagePath, isNull);

      final updated = prefs.copyWith(
        readerBackgroundMode: 'custom',
        readerCustomImagePath: '/data/user/0/custom.jpg',
      );
      expect(updated.readerBackgroundMode, equals('custom'));
      expect(updated.readerCustomImagePath, equals('/data/user/0/custom.jpg'));
    });

    testWidgets('ReaderAtmosphereBackground renders child and desk fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReaderAtmosphereBackground(
              mode: 'desk',
              child: Text('Journal Book Inside'),
            ),
          ),
        ),
      );

      expect(find.text('Journal Book Inside'), findsOneWidget);
    });

    testWidgets('StackedPageEdges and SpineGutter widgets render cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: StackedPageEdges(isLeftEdge: true),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: StackedPageEdges(isLeftEdge: false),
                ),
                Positioned(
                  left: 100,
                  top: 0,
                  bottom: 0,
                  child: SpineGutter(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StackedPageEdges), findsNWidgets(2));
      expect(find.byType(SpineGutter), findsOneWidget);
    });
  });
}
