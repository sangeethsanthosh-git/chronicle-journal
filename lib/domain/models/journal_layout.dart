enum JournalLayout {
  classic,
  scrapbook,
  postcard,
  ringBinder,
  sanctuaryPanorama,
  minimal,
  photoDiary;

  String get label {
    switch (this) {
      case JournalLayout.classic:
        return 'Classic Postmark';
      case JournalLayout.scrapbook:
        return 'Washi Scrapbook';
      case JournalLayout.postcard:
        return 'Vintage Postcard';
      case JournalLayout.ringBinder:
        return 'Open Ring Binder';
      case JournalLayout.sanctuaryPanorama:
        return 'Sanctuary Panorama';
      case JournalLayout.minimal:
        return 'Minimal Editorial';
      case JournalLayout.photoDiary:
        return 'Polaroid Photo Story';
    }
  }

  static JournalLayout fromString(String? name) {
    if (name == null) return JournalLayout.classic;
    return JournalLayout.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => JournalLayout.classic,
    );
  }
}
