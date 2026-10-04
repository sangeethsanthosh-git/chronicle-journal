import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/models/journal_entry_with_details.dart';

class PdfExporter {
  static Future<void> exportEntriesToPdf(
    List<JournalEntryWithDetails> entries,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy • h:mm a');

    // Title / Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Chronicle',
                  style: pw.TextStyle(
                    fontSize: 42,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Personal Journal Archive',
                  style: const pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Generated on ${DateFormat.yMMMMd().format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Entries pages
    for (final e in entries) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        dateFormat.format(e.entry.entryDate),
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Mood: ${e.mood.emoji} ${e.mood.label}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  if (e.entry.title.isNotEmpty) ...[
                    pw.Text(
                      e.entry.title,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    e.entry.content,
                    style: const pw.TextStyle(fontSize: 13, lineSpacing: 4),
                  ),
                  pw.Spacer(),
                  if (e.entry.locationName != null ||
                      e.entry.weatherSummary != null) ...[
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        if (e.entry.locationName != null)
                          pw.Text(
                            '📍 ${e.entry.locationName}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        if (e.entry.weatherSummary != null)
                          pw.Text(
                            '🌤️ ${e.entry.weatherSummary} (${e.entry.weatherTemperature?.round()}°C)',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ],
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
          'Chronicle_Journal_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
