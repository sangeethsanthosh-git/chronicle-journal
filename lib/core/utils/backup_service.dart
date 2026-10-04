import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/journal_entry_with_details.dart';

class BackupService {
  static Future<String> generateJsonBackup(
    List<JournalEntryWithDetails> entries,
  ) async {
    final list = entries.map((e) {
      return {
        'id': e.entry.id,
        'title': e.entry.title,
        'content': e.entry.content,
        'createdAt': e.entry.createdAt.toIso8601String(),
        'updatedAt': e.entry.updatedAt.toIso8601String(),
        'entryDate': e.entry.entryDate.toIso8601String(),
        'mood': e.entry.mood,
        'moodIntensity': e.entry.moodIntensity,
        'isFavorite': e.entry.isFavorite,
        'locationName': e.entry.locationName,
        'latitude': e.entry.latitude,
        'longitude': e.entry.longitude,
        'weatherSummary': e.entry.weatherSummary,
        'weatherTemperature': e.entry.weatherTemperature,
        'layout': e.entry.layout,
        'paperStyle': e.entry.paperStyle,
        'tags': e.tags
            .map((t) => {'id': t.id, 'name': t.name, 'colorHex': t.colorHex})
            .toList(),
      };
    }).toList();

    final data = {
      'app': 'Chronicle',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': list,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> shareJsonBackup(
    List<JournalEntryWithDetails> entries,
  ) async {
    final jsonStr = await generateJsonBackup(entries);
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'chronicle_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Chronicle Journal Backup ($fileName)',
      ),
    );
  }

  static Future<void> exportAsPlainText(
    List<JournalEntryWithDetails> entries,
  ) async {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy • h:mm a');

    buffer.writeln('========================================');
    buffer.writeln('CHRONICLE JOURNAL ARCHIVE');
    buffer.writeln('Generated: ${DateFormat.yMMMMd().format(DateTime.now())}');
    buffer.writeln('Total Entries: ${entries.length}');
    buffer.writeln('========================================\n\n');

    for (final e in entries) {
      buffer.writeln('----------------------------------------');
      buffer.writeln(dateFormat.format(e.entry.entryDate));
      if (e.entry.title.isNotEmpty) {
        buffer.writeln('TITLE: ${e.entry.title}');
      }
      buffer.writeln(
        'MOOD: ${e.mood.emoji} ${e.mood.label} (Intensity: ${e.entry.moodIntensity}/5)',
      );
      if (e.entry.locationName != null) {
        buffer.writeln('LOCATION: ${e.entry.locationName}');
      }
      if (e.entry.weatherSummary != null) {
        buffer.writeln(
          'WEATHER: ${e.entry.weatherSummary} (${e.entry.weatherTemperature?.round()}°C)',
        );
      }
      if (e.tags.isNotEmpty) {
        buffer.writeln('TAGS: ${e.tags.map((t) => '#${t.name}').join(', ')}');
      }
      buffer.writeln('\n${e.entry.content}\n');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'chronicle_journal_${DateFormat('yyyyMMdd').format(DateTime.now())}.txt';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Chronicle Journal Plaintext Archive',
      ),
    );
  }
}
