/// Enum defining the animated and emotional state of companion Fable.
enum CompanionMoodState {
  idle,
  reading,
  writing,
  happy,
  curious,
  celebrating,
  greeting,
}

/// Domain model representing the companion character's active status.
class CompanionState {
  final CompanionMoodState moodState;
  final String activeSpeech;
  final bool isSpeechBubbleVisible;
  final DateTime lastInteractionTime;

  const CompanionState({
    this.moodState = CompanionMoodState.idle,
    this.activeSpeech = 'Welcome to our quiet study.',
    this.isSpeechBubbleVisible = false,
    required this.lastInteractionTime,
  });

  CompanionState copyWith({
    CompanionMoodState? moodState,
    String? activeSpeech,
    bool? isSpeechBubbleVisible,
    DateTime? lastInteractionTime,
  }) {
    return CompanionState(
      moodState: moodState ?? this.moodState,
      activeSpeech: activeSpeech ?? this.activeSpeech,
      isSpeechBubbleVisible:
          isSpeechBubbleVisible ?? this.isSpeechBubbleVisible,
      lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
    );
  }
}
