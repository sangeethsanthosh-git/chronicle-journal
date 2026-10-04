import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MoodType {
  happy,
  calm,
  excited,
  grateful,
  neutral,
  sad,
  angry,
  anxious,
  tired,
  loved,
}

class Mood {
  final MoodType type;
  final String label;
  final String emoji;
  final Color color;

  const Mood({
    required this.type,
    required this.label,
    required this.emoji,
    required this.color,
  });

  static const List<Mood> all = [
    Mood(
      type: MoodType.happy,
      label: 'Happy',
      emoji: '☀️',
      color: AppColors.moodHappy,
    ),
    Mood(
      type: MoodType.calm,
      label: 'Calm',
      emoji: '🌿',
      color: AppColors.moodCalm,
    ),
    Mood(
      type: MoodType.excited,
      label: 'Excited',
      emoji: '✨',
      color: AppColors.moodExcited,
    ),
    Mood(
      type: MoodType.grateful,
      label: 'Grateful',
      emoji: '🌸',
      color: AppColors.moodGrateful,
    ),
    Mood(
      type: MoodType.neutral,
      label: 'Neutral',
      emoji: '☁️',
      color: AppColors.moodNeutral,
    ),
    Mood(
      type: MoodType.sad,
      label: 'Sad',
      emoji: '🌧️',
      color: AppColors.moodSad,
    ),
    Mood(
      type: MoodType.angry,
      label: 'Angry',
      emoji: '⚡',
      color: AppColors.moodAngry,
    ),
    Mood(
      type: MoodType.anxious,
      label: 'Anxious',
      emoji: '🍂',
      color: AppColors.moodAnxious,
    ),
    Mood(
      type: MoodType.tired,
      label: 'Tired',
      emoji: '🌙',
      color: AppColors.moodTired,
    ),
    Mood(
      type: MoodType.loved,
      label: 'Loved',
      emoji: '💌',
      color: AppColors.moodLoved,
    ),
  ];

  static Mood fromString(String? name) {
    if (name == null) return all[0];
    return all.firstWhere(
      (m) =>
          m.type.name.toLowerCase() == name.toLowerCase() ||
          m.label.toLowerCase() == name.toLowerCase(),
      orElse: () => all[0],
    );
  }
}
