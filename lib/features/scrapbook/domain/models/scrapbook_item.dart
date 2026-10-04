enum ScrapbookItemType { photo, note, stamp, botanical, waxSeal }

/// An interactive item placed on the freeform tactile scrapbook canvas.
class ScrapbookItem {
  final String id;
  final ScrapbookItemType type;
  final double x; // Relative position X (0.0 to 1.0)
  final double y; // Relative position Y (0.0 to 1.0)
  final double scale;
  final double rotation; // in radians
  final int zIndex;
  final String content; // text content, asset path, or image uri
  final String? styleMeta; // tape style or paper color

  const ScrapbookItem({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    required this.content,
    this.styleMeta,
  });

  ScrapbookItem copyWith({
    String? id,
    ScrapbookItemType? type,
    double? x,
    double? y,
    double? scale,
    double? rotation,
    int? zIndex,
    String? content,
    String? styleMeta,
  }) {
    return ScrapbookItem(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      content: content ?? this.content,
      styleMeta: styleMeta ?? this.styleMeta,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
    'zIndex': zIndex,
    'content': content,
    'styleMeta': styleMeta,
  };

  factory ScrapbookItem.fromJson(Map<String, dynamic> json) {
    return ScrapbookItem(
      id: json['id'] as String,
      type: ScrapbookItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScrapbookItemType.note,
      ),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      zIndex: json['zIndex'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      styleMeta: json['styleMeta'] as String?,
    );
  }
}
