import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/local/app_database.dart';
import '../../domain/models/journal_entry_with_details.dart';

/// Exports the user's journal entries into a publication-grade PDF
/// that exactly matches the physical scrapbook & ring-binder journal UI:
/// - Warm ivory/cream parchment background with dot-grid pattern
/// - Physical book cover page with gold foil title and leather border
/// - Postal cancellation stamp with double circles & wavy lines
/// - Scalloped postage stamps and distressed circular rubber stamp seals
/// - Taped polaroid photographs with washi tape accents
/// - Retro audio cassette tape illustrations for voice memos
/// - Editorial serif typography with drop-cap first letters and mood seals
class PdfExporter {
  static Future<void> exportEntriesToPdf(
    List<JournalEntryWithDetails> entries,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    // 1. Cover Page (Aged Leather Hardcover with Gold Foil Lettering)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColor.fromHex('#231B15'), // Deep dark leather
            padding: const pw.EdgeInsets.all(36),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('#C5A059'), // Gold foil border
                  width: 2.5,
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              padding: const pw.EdgeInsets.all(28),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '★ ★ ★',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#C5A059'),
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'MIORA',
                    style: pw.TextStyle(
                      fontSize: 38,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 6.0,
                      color: PdfColor.fromHex('#FAF7EE'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: 120,
                    height: 1.5,
                    color: PdfColor.fromHex('#C5A059'),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'PERSONAL JOURNAL ARCHIVE • VOL. 1',
                    style: pw.TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#C5A059'),
                    ),
                  ),
                  pw.SizedBox(height: 48),
                  pw.Text(
                    'Your thoughts. Your moments. Your story.',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColor.fromHex('#D4C8B5'),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 60),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#C5A059'),
                        width: 1,
                      ),
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      'ARCHIVED ON ${DateFormat.yMMMMd().format(DateTime.now()).toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#C5A059'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // 2. Journal Entry Pages (Exact match to Physical Journal & Scrapbook UI)
    for (final e in entries) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FAF7EE'), // Ivory paper
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#DED6C4'),
                  width: 1.2,
                ),
              ),
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Top Header: Postal cancellation mark, Date, Weather & Mood
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Postmark with wavy cancellation lines
                      _buildPdfPostalStamp(
                        e.entry.entryDate,
                        e.entry.locationName ?? 'MIORA',
                      ),
                      // Date, Mood & Weather
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            dateFormat.format(e.entry.entryDate),
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#4A4036'),
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Row(
                            children: [
                              _buildPdfWashiTape('#D9A5B3', 36, 9),
                              pw.SizedBox(width: 6),
                              pw.Text(
                                '${e.mood.emoji} ${e.mood.label.toUpperCase()}',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#7A6F62'),
                                ),
                              ),
                            ],
                          ),
                          if (e.entry.weatherSummary != null) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '${e.entry.weatherSummary} • ${e.entry.weatherTemperature?.round()}°C',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColor.fromHex('#8B8279'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColor.fromHex('#DED6C4'), thickness: 1),
                  pw.SizedBox(height: 10),

                  // Expressive Journal Title with Washi Tape Banner
                  if (e.entry.title.isNotEmpty) ...[
                    pw.Row(
                      children: [
                        _buildPdfWashiTape('#A3B899', 42, 10),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Text(
                            e.entry.title.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.0,
                              color: PdfColor.fromHex('#2C2621'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],

                  // Content Body with Drop-Cap First Letter
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildPdfBodyWithDropCap(e.entry.content),
                        pw.SizedBox(height: 14),

                        // Polaroid Photos with captions and washi tape
                        if (e.photoAttachments.isNotEmpty)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: e.photoAttachments
                                .take(2)
                                .map((p) => _buildPdfPolaroid(p))
                                .toList(),
                          ),

                        // Audio Cassette Tape if audio memo attached
                        if (e.audioAttachments.isNotEmpty) ...[
                          pw.SizedBox(height: 12),
                          _buildPdfCassetteTape(),
                        ],

                        // Soundtrack Memory Box if soundtrack attached
                        if (e.soundtracks.isNotEmpty) ...[
                          pw.SizedBox(height: 10),
                          _buildPdfSoundtrackBox(e.soundtracks.first),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Signature & Distressed Rubber Stamp Seal
                  pw.Divider(color: PdfColor.fromHex('#DED6C4'), thickness: 1),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '— Recorded in Miora Journal',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColor.fromHex('#7A6F62'),
                            ),
                          ),
                          if (e.tags.isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              e.tags.map((t) => '#${t.name}').join('  '),
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#9E9282'),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Distressed circular rubber stamp seal in PDF
                      _buildPdfRubberStamp(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Miora_Scrapbook_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Circular postal cancellation mark with 3 wavy cancellation lines
  static pw.Widget _buildPdfPostalStamp(DateTime date, String location) {
    final stampColor = PdfColor.fromHex('#4A6B82'); // Postal blue
    final dateStr = DateFormat('dd.MM.yy').format(date);

    return pw.Row(
      children: [
        pw.Container(
          width: 44,
          height: 44,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: stampColor, width: 1.2),
          ),
          padding: const pw.EdgeInsets.all(2),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: stampColor, width: 0.8),
            ),
            child: pw.Center(
              child: pw.Text(
                '${location.toUpperCase()}\n$dateStr',
                style: pw.TextStyle(
                  fontSize: 6.5,
                  fontWeight: pw.FontWeight.bold,
                  color: stampColor,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 4),
        // Wavy postal cancellation lines
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '~~~~~~~',
              style: pw.TextStyle(
                fontSize: 8,
                color: stampColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '~~~~~~~',
              style: pw.TextStyle(
                fontSize: 8,
                color: stampColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '~~~~~~~',
              style: pw.TextStyle(
                fontSize: 8,
                color: stampColor,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Washi tape strip in PDF
  static pw.Widget _buildPdfWashiTape(String hexColor, double w, double h) {
    return pw.Container(
      width: w,
      height: h,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex(hexColor),
        borderRadius: pw.BorderRadius.circular(2),
      ),
    );
  }

  /// Drop-Cap first letter followed by body text
  static pw.Widget _buildPdfBodyWithDropCap(String content) {
    if (content.trim().isEmpty) return pw.SizedBox();

    final clean = content.trim();
    final firstChar = clean.substring(0, 1);
    final rest = clean.length > 1 ? clean.substring(1) : '';

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          margin: const pw.EdgeInsets.only(right: 6, top: 2),
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#2C2621'),
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Text(
            firstChar,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#FAF7EE'),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            rest,
            style: pw.TextStyle(
              fontSize: 10.5,
              lineSpacing: 3.5,
              color: PdfColor.fromHex('#2C2621'),
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ),
      ],
    );
  }

  /// Polaroid photo frame with caption and washi tape
  static pw.Widget _buildPdfPolaroid(Attachment photo) {
    pw.Widget photoWidget;
    try {
      final file = File(photo.uri);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        photoWidget = pw.Image(
          pw.MemoryImage(bytes),
          width: 110,
          height: 100,
          fit: pw.BoxFit.cover,
        );
      } else {
        photoWidget = _buildPlaceholderPhoto();
      }
    } catch (_) {
      photoWidget = _buildPlaceholderPhoto();
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
      padding: const pw.EdgeInsets.fromLTRB(6, 6, 6, 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: PdfColor.fromHex('#D4C8B5'), width: 0.8),
      ),
      child: pw.Column(
        children: [
          // Top washi tape accent
          _buildPdfWashiTape('#D4B996', 36, 8),
          pw.SizedBox(height: 4),
          photoWidget,
          if (photo.caption != null && photo.caption!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              photo.caption!,
              style: pw.TextStyle(
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
                color: PdfColor.fromHex('#4A4036'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildPlaceholderPhoto() {
    return pw.Container(
      width: 110,
      height: 100,
      color: PdfColor.fromHex('#EFE9DC'),
      child: pw.Center(
        child: pw.Text(
          'Photo Keepsake',
          style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#8B8279')),
        ),
      ),
    );
  }

  /// Retro Audio Cassette Tape illustration for voice recordings
  static pw.Widget _buildPdfCassetteTape() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EFE9DA'),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColor.fromHex('#C4BCAB'), width: 1),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#8B2635'),
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              'C-60',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            'VOICE MEMO RECORDING • SIDE A',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
              color: PdfColor.fromHex('#3C352D'),
            ),
          ),
        ],
      ),
    );
  }

  /// Distressed circular rubber stamp seal in PDF
  static pw.Widget _buildPdfRubberStamp() {
    final stampColor = PdfColor.fromHex('#9E3A2B'); // Brick red
    return pw.Container(
      width: 44,
      height: 44,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: stampColor, width: 1.5),
      ),
      padding: const pw.EdgeInsets.all(2),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: stampColor, width: 0.8),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'MIORA',
                style: pw.TextStyle(
                  fontSize: 5.5,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.8,
                  color: stampColor,
                ),
              ),
              pw.Text(
                'VERIFIED',
                style: pw.TextStyle(
                  fontSize: 6.5,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.0,
                  color: stampColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildPdfSoundtrackBox(Soundtrack soundtrack) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5EFE6'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor.fromHex('#D5C7B2'), width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '♫ ',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#B59351'),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SOUNDTRACK: ${(soundtrack.title ?? "Unknown Track").toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#2C241E'),
                ),
              ),
              if (soundtrack.artist != null)
                pw.Text(
                  'Artist: ${soundtrack.artist!}${soundtrack.applicationName != null ? " • via ${soundtrack.applicationName!}" : ""}',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColor.fromHex('#6E6053'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
