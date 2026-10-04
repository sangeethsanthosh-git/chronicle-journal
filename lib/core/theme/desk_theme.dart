import 'package:flutter/material.dart';

enum DeskThemeType {
  slateBlue,
  walnutTimber,
  cozyStudy,
  vintageGreen,
  midnightCharcoal,
}

class DeskThemeData {
  final DeskThemeType type;
  final String name;
  final String description;
  final Color deskColor;
  final Color paperColor;
  final Color coverColor;
  final List<Color> gradientColors;

  const DeskThemeData({
    required this.type,
    required this.name,
    required this.description,
    required this.deskColor,
    required this.paperColor,
    required this.coverColor,
    required this.gradientColors,
  });

  static const Map<DeskThemeType, DeskThemeData> themes = {
    DeskThemeType.slateBlue: DeskThemeData(
      type: DeskThemeType.slateBlue,
      name: 'Slate Blue Desk',
      description: 'Calm studio slate-blue surface (Reference Image 4 & AURA)',
      deskColor: Color(0xFF384756),
      paperColor: Color(0xFFFAF7EE),
      coverColor: Color(0xFF25221F),
      gradientColors: [Color(0xFF3F4E5E), Color(0xFF2C3844)],
    ),
    DeskThemeType.walnutTimber: DeskThemeData(
      type: DeskThemeType.walnutTimber,
      name: 'Walnut Timber',
      description: 'Deep warm wood planks with authentic grain',
      deskColor: Color(0xFF3E2718),
      paperColor: Color(0xFFFBF8EE),
      coverColor: Color(0xFF2A190E),
      gradientColors: [Color(0xFF533824), Color(0xFF2C1B10)],
    ),
    DeskThemeType.cozyStudy: DeskThemeData(
      type: DeskThemeType.cozyStudy,
      name: 'Cozy Study Amber',
      description: 'Warm morning light across polished honey oak',
      deskColor: Color(0xFF533B28),
      paperColor: Color(0xFFFFFDF8),
      coverColor: Color(0xFF382315),
      gradientColors: [Color(0xFF6E4D34), Color(0xFF3E2616)],
    ),
    DeskThemeType.vintageGreen: DeskThemeData(
      type: DeskThemeType.vintageGreen,
      name: 'Library Felt Green',
      description: 'Classic British reading room felt mat and dark mahogany',
      deskColor: Color(0xFF29382E),
      paperColor: Color(0xFFFAF6EB),
      coverColor: Color(0xFF1B261F),
      gradientColors: [Color(0xFF364B3D), Color(0xFF1E2A22)],
    ),
    DeskThemeType.midnightCharcoal: DeskThemeData(
      type: DeskThemeType.midnightCharcoal,
      name: 'Midnight Charcoal',
      description: 'Deep nocturnal stone with muted aged parchment',
      deskColor: Color(0xFF1E2126),
      paperColor: Color(0xFFF2ECE1),
      coverColor: Color(0xFF16181C),
      gradientColors: [Color(0xFF2B2E34), Color(0xFF15171A)],
    ),
  };

  static DeskThemeData getTheme(DeskThemeType type) =>
      themes[type] ?? themes[DeskThemeType.slateBlue]!;
}
