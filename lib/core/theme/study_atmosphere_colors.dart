import 'package:flutter/material.dart';

/// Atmospheric color palettes and material tokens for the Living Journal study world.
class StudyAtmosphereColors {
  StudyAtmosphereColors._();

  // --- TIME OF DAY SKYBOX GRADIENTS ---
  // Dawn / Morning (06:00 - 10:00)
  static const Color dawnSkyTop = Color(0xFF6B7B9E);
  static const Color dawnSkyBottom = Color(0xFFE8B896);
  static const Color dawnSunGlow = Color(0xFFFFF2D6);

  // Day / Afternoon (10:00 - 17:00)
  static const Color daySkyTop = Color(0xFF5D8AA8);
  static const Color daySkyBottom = Color(0xFFCBE3F5);
  static const Color daySunGlow = Color(0xFFFFFBE8);

  // Golden Hour / Sunset (17:00 - 20:00)
  static const Color sunsetSkyTop = Color(0xFF3E3D60);
  static const Color sunsetSkyMiddle = Color(0xFFC86D58);
  static const Color sunsetSkyBottom = Color(0xFFF3B367);
  static const Color sunsetSunGlow = Color(0xFFFFD48F);

  // Night / Starlight (20:00 - 06:00)
  static const Color nightSkyTop = Color(0xFF0F1424);
  static const Color nightSkyBottom = Color(0xFF1E2842);
  static const Color nightMoonGlow = Color(0xFFE1E8F5);

  // --- ROOM INTERIOR MATERIALS & WOODWORK ---
  static const Color woodDeskMahogany = Color(0xFF4A2E1B);
  static const Color woodDeskSurface = Color(0xFF6B4226);
  static const Color woodDeskHighlight = Color(0xFF8B5A33);
  static const Color woodFloorDark = Color(0xFF382316);
  static const Color woodFloorPlank = Color(0xFF4E3220);
  static const Color woodFloorGrain = Color(0xFF2C1B10);

  static const Color wallPaperCream = Color(0xFFEDE3D0);
  static const Color wallPaperDamask = Color(0xFFDFD4BE);
  static const Color wallPaperDark = Color(0xFF242220);
  static const Color wallPaperDarkPattern = Color(0xFF1C1A18);

  static const Color areaRugNavy = Color(0xFF2E3D4D);
  static const Color areaRugCrimson = Color(0xFF782C2C);
  static const Color areaRugFringe = Color(0xFFE2D6BE);

  // --- FURNITURE & ARCHITECTURAL ACCENTS ---
  static const Color bookshelfWood = Color(0xFF3D2718);
  static const Color bookshelfShadow = Color(0xFF24160E);
  static const Color windowFrame = Color(0xFF422C1D);
  static const Color windowSill = Color(0xFF573B28);
  static const Color windowGlassTint = Color(0x33A6C8E0);

  // --- METALS, LIGHTING & AMBIENT GLOW ---
  static const Color vintageBrass = Color(0xFFD4AF37);
  static const Color antiqueBronze = Color(0xFF916C36);
  static const Color lampShadeGreen = Color(0xFF1E4620);
  static const Color lampShadeAmber = Color(0xFFE5A823);
  static const Color lampLightCore = Color(0xFFFFF7D6);
  static const Color lampLightGlow = Color(0x55FFC857);
  static const Color candleFlame = Color(0xFFFF9E1B);
  static const Color candleFlameCore = Color(0xFFFFFDE3);

  // --- BOTANICALS & NATURE ---
  static const Color plantLeafDeepGreen = Color(0xFF2D5A27);
  static const Color plantLeafSpring = Color(0xFF4E853C);
  static const Color plantLeafHighlight = Color(0xFF7CB342);
  static const Color terracottaPot = Color(0xFFB85D36);
  static const Color terracottaRim = Color(0xFFD4784F);

  // --- COMPANION CHARACTER "FABLE" PALETTE ---
  static const Color fableSkinTone = Color(0xFFFBE8D3);
  static const Color fableCheekBlush = Color(0xFFF7B5A0);
  static const Color fableHairChestnut = Color(0xFF4A3324);
  static const Color fableHairHighlight = Color(0xFF6B4C35);
  static const Color fableEyeHazel = Color(0xFF5A4833);
  static const Color fableScarfMustard = Color(0xFFDCA134);
  static const Color fableScarfKnitDark = Color(0xFFB88220);
  static const Color fableSweaterCream = Color(0xFFF4EDE2);
  static const Color fableSpectaclesBrass = Color(0xFFC59F4E);
  static const Color fableBrassQuill = Color(0xFFE0BB53);
  static const Color fableQuillFeather = Color(0xFF5A728A);

  // --- PARTICLES & ATMOSPHERE ---
  static const Color dustMote = Color(0x77FFF4CF);
  static const Color rainStreak = Color(0x44D1E8FF);
  static const Color starSparkle = Color(0xCCFFFEE8);
  static const Color thoughtXpGold = Color(0xFFFFD700);

  // --- UTILITY METHODS ---
  /// Selects skybox gradient colors based on the current hour of the day.
  static List<Color> getSkyGradient(int hour) {
    if (hour >= 5 && hour < 9) {
      return [dawnSkyTop, dawnSkyBottom];
    } else if (hour >= 9 && hour < 17) {
      return [daySkyTop, daySkyBottom];
    } else if (hour >= 17 && hour < 20) {
      return [sunsetSkyTop, sunsetSkyMiddle, sunsetSkyBottom];
    } else {
      return [nightSkyTop, nightSkyBottom];
    }
  }

  /// Ambient light overlay color and opacity based on time of day.
  static Color getAmbientLightingFilter(int hour, bool lampOn) {
    if (lampOn) {
      return const Color(0x15FFB74D); // Soft warm amber interior wash
    }
    if (hour >= 5 && hour < 9) {
      return const Color(0x12FFA726); // Morning golden hue
    } else if (hour >= 9 && hour < 17) {
      return Colors.transparent; // Neutral day
    } else if (hour >= 17 && hour < 20) {
      return const Color(0x20E65100); // Sunset amber wash
    } else {
      return const Color(0x350D1B2A); // Night cool blue filter
    }
  }
}
