import 'package:flutter/material.dart';

/// Predefined categories for journal volumes
enum JournalCategory {
  personal('Personal', Icons.person_outline, Color(0xFFC86D51)),
  travel('Travel', Icons.flight_takeoff_outlined, Color(0xFF3D6B7D)),
  study('Study', Icons.school_outlined, Color(0xFF4A6B5B)),
  project('Project', Icons.folder_outlined, Color(0xFFC99A3E)),
  health('Health', Icons.favorite_outline, Color(0xFFC0787A)),
  memories('Memories', Icons.photo_library_outlined, Color(0xFF7E5B6E)),
  dreams('Dreams', Icons.nights_stay_outlined, Color(0xFF414B66)),
  reading('Reading', Icons.menu_book_outlined, Color(0xFF8A5E44)),
  custom('Custom', Icons.auto_stories_outlined, Color(0xFF8C7355));

  final String label;
  final IconData icon;
  final Color defaultColor;

  const JournalCategory(this.label, this.icon, this.defaultColor);

  static JournalCategory fromString(String? val) {
    if (val == null) return JournalCategory.personal;
    final normalized = val.trim().toLowerCase();
    for (final cat in JournalCategory.values) {
      if (cat.name.toLowerCase() == normalized ||
          cat.label.toLowerCase() == normalized) {
        return cat;
      }
    }
    return JournalCategory.custom;
  }
}

/// Sorting options for the physical bookshelf
enum JournalStackSort {
  recent('Recent', Icons.history),
  oldest('Oldest', Icons.arrow_upward),
  mostEntries('Most Entries', Icons.format_list_numbered),
  recentlyUpdated('Recently Updated', Icons.update),
  alphabetical('Alphabetical', Icons.sort_by_alpha);

  final String label;
  final IconData icon;

  const JournalStackSort(this.label, this.icon);
}

/// Rich domain model representing an illustrated book volume on the Journal Stack shelf
class JournalStackItem {
  final String id;
  final String title;
  final String? description;
  final String? coverImage;
  final JournalCategory category;
  final Color spineColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int entryCount;
  final int photoCount;
  final bool isArchived;
  final String? moodSummary;
  final List<String> entryIds;

  // Physical variation parameters calculated deterministically
  final double tiltAngle;
  final double spineHeight;
  final double spineThickness;
  final int spineBandCount;

  JournalStackItem({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    required this.category,
    required this.spineColor,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    this.entryCount = 0,
    this.photoCount = 0,
    this.isArchived = false,
    this.moodSummary,
    this.entryIds = const [],
  }) : tiltAngle = _computeTilt(id),
       spineHeight = _computeHeight(id),
       spineThickness = _computeThickness(id),
       spineBandCount = _computeBands(id);

  static double _computeTilt(String id) {
    // Subtle tilt between -0.035 and +0.035 radians (-2° to +2°)
    final hash = id.hashCode.abs();
    final step = (hash % 7) - 3; // -3, -2, -1, 0, 1, 2, 3
    return step * 0.012;
  }

  static double _computeHeight(String id) {
    // Height between 145 and 185
    final hash = id.hashCode.abs();
    return 150.0 + (hash % 35);
  }

  static double _computeThickness(String id) {
    // Width / thickness between 28 and 38
    final hash = id.hashCode.abs();
    return 28.0 + (hash % 10);
  }

  static int _computeBands(String id) {
    final hash = id.hashCode.abs();
    return (hash % 3) + 1; // 1 to 3 gold/paper bands on spine
  }

  /// Human-readable date range string
  String get dateRangeText {
    if (startDate == null && endDate == null) {
      return 'Created ${_formatDate(createdAt)}';
    }
    if (startDate != null && endDate != null) {
      if (startDate!.year == endDate!.year &&
          startDate!.month == endDate!.month &&
          startDate!.day == endDate!.day) {
        return _formatDate(startDate!);
      }
      return '${_formatMonthYear(startDate!)} — ${_formatMonthYear(endDate!)}';
    }
    if (startDate != null) return 'Since ${_formatDate(startDate!)}';
    return 'Until ${_formatDate(endDate!)}';
  }

  /// Semantic accessibility description
  String get semanticLabel {
    final updateStr = _formatDate(updatedAt);
    return '$title journal, $entryCount entries, $photoCount photos, category ${category.label}, last updated $updateStr';
  }

  JournalStackItem copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    JournalCategory? category,
    Color? spineColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    int? entryCount,
    int? photoCount,
    bool? isArchived,
    String? moodSummary,
    List<String>? entryIds,
  }) {
    return JournalStackItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      category: category ?? this.category,
      spineColor: spineColor ?? this.spineColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      entryCount: entryCount ?? this.entryCount,
      photoCount: photoCount ?? this.photoCount,
      isArchived: isArchived ?? this.isArchived,
      moodSummary: moodSummary ?? this.moodSummary,
      entryIds: entryIds ?? this.entryIds,
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _formatMonthYear(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}
