import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/core/widgets/cassette_tape_widget.dart';
import 'package:chronicle/core/widgets/paperclip_widget.dart';
import 'package:chronicle/core/widgets/polaroid_card.dart';
import 'package:chronicle/core/widgets/ring_binder_frame.dart';
import 'package:chronicle/core/widgets/torn_paper_card.dart';
import 'package:chronicle/core/widgets/vintage_postcard_widget.dart';
import 'package:chronicle/core/widgets/vintage_rubber_stamp.dart';

void main() {
  group('Tactile Stationery & Binder Widgets Tests', () {
    testWidgets('Renders PaperclipWidget with custom colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PaperclipWidget(
                color: PaperclipColor.silver,
                width: 20,
                height: 50,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PaperclipWidget), findsOneWidget);
    });

    testWidgets('Renders RingBinderFrame with spine rings and reminder quote', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RingBinderFrame(
              reminderQuote: 'reminder: progress matters more than perfection.',
              child: Text('Binder Page Inside'),
            ),
          ),
        ),
      );

      expect(find.byType(RingBinderFrame), findsOneWidget);
      expect(find.text('Binder Page Inside'), findsOneWidget);
      expect(
        find.text('reminder: progress matters more than perfection.'),
        findsOneWidget,
      );
    });

    testWidgets('Renders VintageRubberStamp with circular stars and text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VintageRubberStamp(
                text: 'MIORA ARCHIVE • BESPOKE QUALITY',
                centerText: 'VERIFIED',
                size: 80,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VintageRubberStamp), findsOneWidget);
    });

    testWidgets('Renders VintagePostcardWidget with photo and postal back', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VintagePostcardWidget(
                message: 'A quiet sunset by the hills.',
                date: DateTime(2026, 10, 4),
                location: 'HIGHLANDS',
                recipient: 'To: Dear Future Self',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VintagePostcardWidget), findsOneWidget);
      expect(find.text('POST CARD'), findsOneWidget);
      expect(find.text('A quiet sunset by the hills.'), findsOneWidget);
      expect(find.text('HIGHLANDS'), findsOneWidget);
      expect(find.text('To: Dear Future Self'), findsOneWidget);
    });

    testWidgets('Renders CassetteTapeWidget with spools and title', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CassetteTapeWidget(
                audioPath: '/fake/path/audio.m4a',
                label: 'VOICE MEMO • SIDE A',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CassetteTapeWidget), findsOneWidget);
      expect(find.text('C-60'), findsOneWidget);
      expect(find.text('VOICE MEMO • SIDE A'), findsOneWidget);
    });

    testWidgets('Renders TornPaperCard pinned with PaperclipWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TornPaperCard(
                pinnedWithPaperclip: true,
                child: Text('Torn Note Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TornPaperCard), findsOneWidget);
      expect(find.byType(PaperclipWidget), findsOneWidget);
      expect(find.text('Torn Note Content'), findsOneWidget);
    });

    testWidgets('Renders PolaroidCard pinned with PaperclipWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PolaroidCard(
                imagePath: 'https://example.com/photo.jpg',
                caption: 'Memories of the afternoon',
                pinnedWithPaperclip: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PolaroidCard), findsOneWidget);
      expect(find.byType(PaperclipWidget), findsOneWidget);
      expect(find.text('Memories of the afternoon'), findsOneWidget);
    });
  });
}
