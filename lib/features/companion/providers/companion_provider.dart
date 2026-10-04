import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/providers/progression_provider.dart';
import '../domain/models/companion_dialogue.dart';
import '../domain/models/companion_state.dart';

class CompanionNotifier extends Notifier<CompanionState> {
  @override
  CompanionState build() {
    final hour = DateTime.now().hour;
    final progress = ref.watch(userProgressProvider);
    final daysElapsed = progress.lastJournalDate != null
        ? DateTime.now().difference(progress.lastJournalDate!).inDays
        : null;

    final initialGreeting = CompanionDialogue.getGreeting(
      hour: hour,
      daysSinceLastJournal: daysElapsed,
      totalEntries: progress.totalEntriesWritten,
    );

    return CompanionState(
      moodState: CompanionMoodState.idle,
      activeSpeech: initialGreeting,
      isSpeechBubbleVisible: false,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Triggered when the user taps on companion Fable.
  void tapCompanion() {
    final hour = DateTime.now().hour;
    final progress = ref.read(userProgressProvider);
    final daysElapsed = progress.lastJournalDate != null
        ? DateTime.now().difference(progress.lastJournalDate!).inDays
        : null;

    final speech = state.isSpeechBubbleVisible
        ? CompanionDialogue.getRandomPrompt()
        : CompanionDialogue.getGreeting(
            hour: hour,
            daysSinceLastJournal: daysElapsed,
            totalEntries: progress.totalEntriesWritten,
          );

    state = state.copyWith(
      moodState: CompanionMoodState.happy,
      activeSpeech: speech,
      isSpeechBubbleVisible: true,
      lastInteractionTime: DateTime.now(),
    );
  }

  /// Triggers celebration dialogue when user saves a journal or memory.
  void celebrateMemory() {
    state = state.copyWith(
      moodState: CompanionMoodState.celebrating,
      activeSpeech: CompanionDialogue.getCelebrationSpeech(),
      isSpeechBubbleVisible: true,
      lastInteractionTime: DateTime.now(),
    );
  }

  void dismissSpeechBubble() {
    state = state.copyWith(
      isSpeechBubbleVisible: false,
      moodState: CompanionMoodState.idle,
    );
  }

  void setMood(CompanionMoodState mood) {
    state = state.copyWith(moodState: mood);
  }
}

final companionProvider = NotifierProvider<CompanionNotifier, CompanionState>(
  () {
    return CompanionNotifier();
  },
);
