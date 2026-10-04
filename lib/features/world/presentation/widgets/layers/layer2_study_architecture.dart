import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer2StudyArchitecture extends StatelessWidget {
  final bool isDarkTheme;
  final double parallaxOffset;

  const Layer2StudyArchitecture({
    super.key,
    this.isDarkTheme = false,
    this.parallaxOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ArchitecturePainter(
          isDarkTheme: isDarkTheme,
          parallaxOffset: parallaxOffset,
        ),
      ),
    );
  }
}

class _ArchitecturePainter extends CustomPainter {
  final bool isDarkTheme;
  final double parallaxOffset;

  _ArchitecturePainter({
    required this.isDarkTheme,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.58;

    // 1. WALLPAPER (Upper section)
    final wallColor = isDarkTheme
        ? StudyAtmosphereColors.wallPaperDark
        : StudyAtmosphereColors.wallPaperCream;
    final patternColor = isDarkTheme
        ? StudyAtmosphereColors.wallPaperDarkPattern
        : StudyAtmosphereColors.wallPaperDamask;

    final wallPaint = Paint()..color = wallColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY), wallPaint);

    // Subtle wallpaper vertical stripes
    final stripePaint = Paint()
      ..color = patternColor.withValues(alpha: 0.4)
      ..strokeWidth = 2.0;

    const stripeSpacing = 28.0;
    final stripeStartX = (parallaxOffset * 15) % stripeSpacing;
    for (double x = stripeStartX; x < size.width; x += stripeSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, horizonY), stripePaint);
    }

    // 2. WAINSCOTING / BASEBOARD MOULDING
    final mouldingPaint = Paint()..color = const Color(0xFF3B2718);
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 14, size.width, 14),
      mouldingPaint,
    );

    final highlightPaint = Paint()
      ..color = const Color(0xFF5A3E29)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, horizonY - 14),
      Offset(size.width, horizonY - 14),
      highlightPaint,
    );

    // 3. HARDWOOD FLOORBOARDS (Lower section)
    final floorPaint = Paint()..color = StudyAtmosphereColors.woodFloorPlank;
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      floorPaint,
    );

    // Plank perspective lines
    final plankPaint = Paint()
      ..color = StudyAtmosphereColors.woodFloorGrain
      ..strokeWidth = 1.2;

    const plankHeight = 32.0;
    for (double y = horizonY; y < size.height; y += plankHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankPaint);

      // Vertical plank seam breaks
      final seamX = ((y * 3.7) + parallaxOffset * 20) % size.width;
      canvas.drawLine(
        Offset(seamX, y),
        Offset(seamX, y + plankHeight),
        plankPaint,
      );
    }

    // 4. AREA RUG (Woven Ornamental Rug beneath the desk)
    final rugRect = Rect.fromCenter(
      center: Offset(
        size.width * 0.5 + parallaxOffset * 18,
        size.height * 0.82,
      ),
      width: size.width * 0.88,
      height: size.height * 0.32,
    );

    // Rug border fringe
    final fringePaint = Paint()..color = StudyAtmosphereColors.areaRugFringe;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rugRect.inflate(6), const Radius.circular(12)),
      fringePaint,
    );

    // Rug base field
    final rugBasePaint = Paint()..color = StudyAtmosphereColors.areaRugNavy;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rugRect, const Radius.circular(10)),
      rugBasePaint,
    );

    // Rug inner medallion / ornamental border
    final rugInnerPaint = Paint()
      ..color = StudyAtmosphereColors.areaRugCrimson
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rugRect.deflate(12), const Radius.circular(6)),
      rugInnerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchitecturePainter oldDelegate) {
    return oldDelegate.isDarkTheme != isDarkTheme ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
