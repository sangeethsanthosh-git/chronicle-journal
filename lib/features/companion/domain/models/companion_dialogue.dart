import 'dart:math';

/// Gentle, non-guilt storybook dialogue generator for companion "Fable".
class CompanionDialogue {
  CompanionDialogue._();

  static final Random _rng = Random();

  /// Welcoming greeting when the user taps Fable or enters the study.
  static String getGreeting({
    required int hour,
    int? daysSinceLastJournal,
    int totalEntries = 0,
  }) {
    // If returning after an absence, respond with pure warmth and zero guilt!
    if (daysSinceLastJournal != null && daysSinceLastJournal >= 3) {
      final absenceGreetings = [
        "Welcome back! The study has been waiting warmly for you. Take all the time you need.",
        "It's so good to see you again. The kettle is always warm here.",
        "A peaceful day to return. There is no rush, only quiet pages waiting when you're ready.",
        "Hello, friend. Whenever you feel like writing, the ink is ready.",
      ];
      return absenceGreetings[_rng.nextInt(absenceGreetings.length)];
    }

    if (totalEntries == 0) {
      return "Hello! I'm Fable. Whenever you have a memory or thought, our journal is right here on the desk.";
    }

    // Time-based warm greetings
    if (hour >= 5 && hour < 12) {
      final morningGreetings = [
        "Good morning! The morning light looks lovely across the desk today.",
        "A fresh morning. May today bring you small moments worth remembering.",
        "Morning tea is poured. How did you sleep?",
      ];
      return morningGreetings[_rng.nextInt(morningGreetings.length)];
    } else if (hour >= 12 && hour < 17) {
      final afternoonGreetings = [
        "Good afternoon. How is your day unfolding?",
        "Taking a quiet pause in the middle of the day is always a good idea.",
        "The light through the window is so calming right now.",
      ];
      return afternoonGreetings[_rng.nextInt(afternoonGreetings.length)];
    } else if (hour >= 17 && hour < 21) {
      final sunsetGreetings = [
        "Golden hour has arrived. The sky outside is painted in amber.",
        "Good evening. It's time to unwind and let your thoughts settle.",
        "The lamp is lit, and the evening breeze is gentle.",
      ];
      return sunsetGreetings[_rng.nextInt(sunsetGreetings.length)];
    } else {
      final nightGreetings = [
        "The stars are quiet tonight. A peaceful hour for reflection.",
        "Rest well tonight. Your thoughts are safe and preserved here.",
        "The lamp glow is soft. Even writing just one sentence can bring peace.",
      ];
      return nightGreetings[_rng.nextInt(nightGreetings.length)];
    }
  }

  /// Gentle journaling prompts to inspire thought.
  static String getRandomPrompt() {
    const prompts = [
      "What was a small sound or scent that caught your attention today?",
      "Did someone say something today that made you pause or smile?",
      "If today had a color or texture, what would it be?",
      "What is something simple you felt grateful for today?",
      "Describe the view from a window you looked through recently.",
      "What gave you energy today, even if just for a moment?",
      "What is one thing you would tell your past self from this morning?",
      "What kind of memory would you like tomorrow to hold?",
    ];
    return prompts[_rng.nextInt(prompts.length)];
  }

  /// Response when user finishes a journal entry or adds a photo.
  static String getCelebrationSpeech() {
    const celebrations = [
      "A wonderful reflection. Another piece of your story is safe in the study.",
      "Your words bring such life to this room! Look how the study shines.",
      "Beautifully captured. I'll take good care of this page.",
      "Memories are like little lanterns in the heart. Thank you for sharing that.",
    ];
    return celebrations[_rng.nextInt(celebrations.length)];
  }
}
