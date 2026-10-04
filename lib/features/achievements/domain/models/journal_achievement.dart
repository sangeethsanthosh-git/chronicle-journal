import 'package:flutter/material.dart';

enum AchievementCategory {
  streak('Writing Rhythm', Icons.local_fire_department_outlined),
  volume('Chapters & Volume', Icons.menu_book_outlined),
  visual('Visual Memories', Icons.camera_alt_outlined),
  audio('Audio Memos', Icons.mic_none_outlined),
  explorer('World Exploration', Icons.explore_outlined),
  library('Bookshelf Library', Icons.shelves);

  final String label;
  final IconData icon;
  const AchievementCategory(this.label, this.icon);
}

class JournalAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color sealColor;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final AchievementCategory category;
  final String stampSymbol;

  const JournalAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.sealColor,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.category,
    required this.stampSymbol,
  });

  double get progressRatio =>
      targetValue == 0 ? 1.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  JournalAchievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? sealColor,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    AchievementCategory? category,
    String? stampSymbol,
  }) {
    return JournalAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      sealColor: sealColor ?? this.sealColor,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category ?? this.category,
      stampSymbol: stampSymbol ?? this.stampSymbol,
    );
  }
}
