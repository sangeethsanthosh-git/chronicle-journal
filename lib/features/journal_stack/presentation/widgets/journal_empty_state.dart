import 'package:flutter/material.dart';

/// Illustrated cozy empty shelf state:
/// - Friendly illustrated companion sprite / message
/// - "+ Create Journal" prompt inviting the user to place their first volume
class JournalEmptyState extends StatelessWidget {
  final VoidCallback onCreateJournal;
  final bool isArchivedMode;

  const JournalEmptyState({
    super.key,
    required this.onCreateJournal,
    this.isArchivedMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cozy animated companion illustration badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAE1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDD6C7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isArchivedMode
                      ? Icons.inventory_2_outlined
                      : Icons.auto_stories_outlined,
                  size: 38,
                  color: const Color(0xFF8C7355),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Warm storybook message
            Text(
              isArchivedMode
                  ? 'No Archived Volumes Yet'
                  : 'Your shelf is waiting for its first story.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2218),
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isArchivedMode
                  ? 'When you complete a journal, you can archive it here to preserve your memories.'
                  : 'Gather your thoughts, reflections, and photographs into handcrafted personal volumes.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: Color(0xFF7A6B5D),
              ),
            ),

            const SizedBox(height: 22),

            if (!isArchivedMode)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2218),
                  foregroundColor: const Color(0xFFFAF7EE),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'CREATE FIRST JOURNAL',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                onPressed: onCreateJournal,
              ),
          ],
        ),
      ),
    );
  }
}
