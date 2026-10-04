import 'package:chronicle/features/journal_reader/presentation/widgets/codex_audio_memo_page.dart';
import 'package:chronicle/features/journal_reader/presentation/widgets/codex_photo_dossier_page.dart';
import 'package:chronicle/features/journal_reader/presentation/widgets/codex_tab_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Codex & Notebook Navigation Tests', () {
    testWidgets(
      'CodexTabHeader renders all protruding tabs and handles selection',
      (tester) async {
        CodexTab selected = CodexTab.story;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CodexTabHeader(
                activeTab: selected,
                onTabSelected: (tab) => selected = tab,
              ),
            ),
          ),
        );

        expect(find.text('STORY'), findsOneWidget);
        expect(find.text('MEDIA'), findsOneWidget);
        expect(find.text('TROPHY'), findsOneWidget);
        expect(find.text('CASSETTE'), findsOneWidget);

        await tester.tap(find.text('MEDIA'));
        await tester.pump();
        expect(selected, equals(CodexTab.photos));

        await tester.tap(find.text('TROPHY'));
        await tester.pump();
        expect(selected, equals(CodexTab.achievements));
      },
    );

    testWidgets('CodexPhotoDossierPage renders empty state and photo counts', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CodexPhotoDossierPage(entries: [])),
        ),
      );

      expect(find.text('MEDIA • DOSSIER'), findsOneWidget);
      expect(find.text('0 PHOTOS'), findsOneWidget);
      expect(find.text('No photo keepsakes attached yet'), findsOneWidget);
    });

    testWidgets('CodexAudioMemoPage renders empty state and tape header', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CodexAudioMemoPage(entries: [])),
        ),
      );

      expect(find.text('VOICE ARCHIVE • CASSETTE'), findsOneWidget);
      expect(find.text('0 TAPES'), findsOneWidget);
      expect(find.text('No cassette voice memos recorded yet'), findsOneWidget);
    });
  });
}
