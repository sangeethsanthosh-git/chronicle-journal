import '../../data/local/app_database.dart';
import 'mood.dart';
import 'paper_style.dart';
import 'journal_layout.dart';

class JournalEntryWithDetails {
  final JournalEntry entry;
  final List<Tag> tags;
  final List<Attachment> attachments;

  JournalEntryWithDetails({
    required this.entry,
    this.tags = const [],
    this.attachments = const [],
  });

  Mood get mood => Mood.fromString(entry.mood);
  PaperStyle get paperStyle => PaperStyle.fromString(entry.paperStyle);
  JournalLayout get layout => JournalLayout.fromString(entry.layout);

  List<Attachment> get photoAttachments =>
      attachments.where((a) => a.type == 'image').toList();

  List<Attachment> get audioAttachments =>
      attachments.where((a) => a.type == 'audio').toList();

  int get wordCount {
    if (entry.content.trim().isEmpty) return 0;
    return entry.content.trim().split(RegExp(r'\s+')).length;
  }
}
