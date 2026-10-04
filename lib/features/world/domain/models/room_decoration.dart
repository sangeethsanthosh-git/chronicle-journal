/// Represents a decor or interactive object located inside the Cozy Study.
class RoomDecoration {
  final String id;
  final String title;
  final String description;
  final int unlockLevel;
  final bool isEquipped;
  final double posX; // Normalized position (0.0 to 1.0)
  final double posY; // Normalized position (0.0 to 1.0)

  const RoomDecoration({
    required this.id,
    required this.title,
    required this.description,
    this.unlockLevel = 1,
    this.isEquipped = true,
    this.posX = 0.5,
    this.posY = 0.5,
  });

  RoomDecoration copyWith({
    String? id,
    String? title,
    String? description,
    int? unlockLevel,
    bool? isEquipped,
    double? posX,
    double? posY,
  }) {
    return RoomDecoration(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockLevel: unlockLevel ?? this.unlockLevel,
      isEquipped: isEquipped ?? this.isEquipped,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
    );
  }

  /// Default room decor items in the study.
  static List<RoomDecoration> get defaultDecorations => const [
    RoomDecoration(
      id: 'desk_journal',
      title: 'Leather-Bound Journal',
      description: 'Your primary book of thoughts, ink and memories.',
      unlockLevel: 1,
      isEquipped: true,
      posX: 0.48,
      posY: 0.65,
    ),
    RoomDecoration(
      id: 'desk_lamp',
      title: 'Brass Banker\'s Lamp',
      description: 'Casts a gentle, warm amber illumination across the desk.',
      unlockLevel: 1,
      isEquipped: true,
      posX: 0.22,
      posY: 0.46,
    ),
    RoomDecoration(
      id: 'bookshelf_archive',
      title: 'Carved Bookshelf',
      description: 'House bound volumes of your past months and years.',
      unlockLevel: 1,
      isEquipped: true,
      posX: 0.82,
      posY: 0.38,
    ),
    RoomDecoration(
      id: 'desk_plant',
      title: 'Terracotta Potted Ivy',
      description: 'Thrives and grows greener with each reflection you write.',
      unlockLevel: 1,
      isEquipped: true,
      posX: 0.14,
      posY: 0.58,
    ),
    RoomDecoration(
      id: 'gallery_wall',
      title: 'Memory Gallery Frames',
      description:
          'Framed polaroids highlighting cherished memories on the wall.',
      unlockLevel: 2,
      isEquipped: true,
      posX: 0.48,
      posY: 0.24,
    ),
    RoomDecoration(
      id: 'brass_clock',
      title: 'Pendulum Mantel Clock',
      description: 'Gently marks the passage of quiet, thoughtful time.',
      unlockLevel: 3,
      isEquipped: true,
      posX: 0.72,
      posY: 0.22,
    ),
    RoomDecoration(
      id: 'steaming_mug',
      title: 'Curling Teacup',
      description: 'Warm chamomile tea always ready during study sessions.',
      unlockLevel: 1,
      isEquipped: true,
      posX: 0.35,
      posY: 0.62,
    ),
  ];
}
