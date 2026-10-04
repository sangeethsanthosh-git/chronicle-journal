enum PaperStyle {
  plain,
  ruled,
  grid,
  vintage;

  String get label {
    switch (this) {
      case PaperStyle.plain:
        return 'Plain Parchment';
      case PaperStyle.ruled:
        return 'Ruled Notebook';
      case PaperStyle.grid:
        return 'Dot Grid';
      case PaperStyle.vintage:
        return 'Aged Antique';
    }
  }

  static PaperStyle fromString(String? name) {
    if (name == null) return PaperStyle.plain;
    return PaperStyle.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => PaperStyle.plain,
    );
  }
}
