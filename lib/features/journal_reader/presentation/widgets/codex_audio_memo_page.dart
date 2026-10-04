import 'package:flutter/material.dart';
import '../../../../data/local/app_database.dart';
import '../../../../domain/models/journal_entry_with_details.dart';

/// Audio memo & cassette player codex page spread matching Reference 2:
/// - Pinned cassette tape memory cards
/// - Handwritten memo titles
/// - Lined paper track list
class CodexAudioMemoPage extends StatelessWidget {
  final List<JournalEntryWithDetails> entries;

  const CodexAudioMemoPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final List<({Attachment attachment, JournalEntryWithDetails entry})>
    audioMemos = [];

    for (final e in entries) {
      for (final a in e.audioAttachments) {
        audioMemos.add((attachment: a, entry: e));
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFD7C5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Cassette Audio Memos"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.mic_none_outlined,
                    size: 18,
                    color: Color(0xFF7E5B6E),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'VOICE ARCHIVE • CASSETTE',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF2C2218),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7E5B6E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${audioMemos.length} TAPES',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAF7EE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (audioMemos.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE5D5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4C8B5)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.album_outlined,
                          size: 28,
                          color: Color(0xFF8C7E6D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No cassette voice memos recorded yet',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3E31),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Record audio memories in the editor to listen to them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: Color(0xFF7A6B5D),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: audioMemos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = audioMemos[index];
                  return _buildCassetteTile(item.attachment, item.entry);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCassetteTile(
    Attachment attachment,
    JournalEntryWithDetails entry,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2218),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Spool animation icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF423427),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFAF7EE), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note_rounded,
                size: 18,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.caption ??
                      (entry.entry.title.isNotEmpty
                          ? entry.entry.title
                          : 'Voice Memory'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAF7EE),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recorded on ${entry.entry.entryDate.day}/${entry.entry.entryDate.month}/${entry.entry.entryDate.year}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFFC7BCAE),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill_rounded,
              size: 32,
              color: Color(0xFFD4AF37),
            ),
            onPressed: () {
              // Audio preview trigger
            },
          ),
        ],
      ),
    );
  }
}
