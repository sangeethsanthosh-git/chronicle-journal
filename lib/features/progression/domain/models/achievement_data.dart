/// Model for collectible sanctuary achievement tokens.
class AchievementData {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int requiredXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.requiredXp = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementData copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? requiredXp,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      requiredXp: requiredXp ?? this.requiredXp,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Preset default achievements for Living Journal.
  static List<AchievementData> get defaults => const [
    AchievementData(
      id: 'first_word',
      title: 'First Ink',
      description: 'Wrote your very first thought in the study journal.',
      iconName: 'feather',
      requiredXp: 25,
    ),
    AchievementData(
      id: 'photo_keeper',
      title: 'Window to Memory',
      description: 'Preserved a photograph inside a journal entry.',
      iconName: 'photo',
      requiredXp: 50,
    ),
    AchievementData(
      id: 'scrapbook_artist',
      title: 'Scrapbook Weaver',
      description: 'Arranged your first freeform tactile scrapbook canvas.',
      iconName: 'palette',
      requiredXp: 80,
    ),
    AchievementData(
      id: 'audio_echo',
      title: 'Echo of the Heart',
      description: 'Recorded a spoken voice note reflection.',
      iconName: 'mic',
      requiredXp: 120,
    ),
    AchievementData(
      id: 'sanctuary_flourishing',
      title: 'The Flourishing Study',
      description: 'Reached Sanctuary Level 5 and nurtured study botanicals.',
      iconName: 'plant',
      requiredXp: 500,
    ),
    AchievementData(
      id: 'cozy_night',
      title: 'Starlight Scholar',
      description: 'Penned a reflection under the evening starlight.',
      iconName: 'moon',
      requiredXp: 250,
    ),
  ];
}
