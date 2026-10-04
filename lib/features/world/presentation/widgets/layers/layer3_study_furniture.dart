import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer3StudyFurniture extends StatelessWidget {
  final double parallaxOffset;

  const Layer3StudyFurniture({super.key, this.parallaxOffset = 0.0});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _FurniturePainter(parallaxOffset: parallaxOffset),
      ),
    );
  }
}

class _FurniturePainter extends CustomPainter {
  final double parallaxOffset;

  _FurniturePainter({required this.parallaxOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. ARCHED BOOKSHELF CABINET (Positioned on the right wall)
    final shelfWidth = size.width * 0.30;
    final shelfLeft = size.width * 0.72 + parallaxOffset * 22;
    final shelfTop = size.height * 0.18;
    final shelfBottom = size.height * 0.78;

    final shelfRect = Rect.fromLTRB(
      shelfLeft,
      shelfTop,
      shelfLeft + shelfWidth,
      shelfBottom,
    );

    // Shelf exterior frame
    final shelfPaint = Paint()..color = StudyAtmosphereColors.bookshelfWood;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        shelfRect,
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
      ),
      shelfPaint,
    );

    // Shelf interior shadow cavity
    final cavityPaint = Paint()..color = StudyAtmosphereColors.bookshelfShadow;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        shelfRect.deflate(8),
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
      ),
      cavityPaint,
    );

    // Shelves horizontal planks
    final plankPaint = Paint()
      ..color = StudyAtmosphereColors.woodDeskHighlight
      ..strokeWidth = 6.0;

    final shelfSlots = [0.38, 0.54, 0.70, 0.86];
    for (final frac in shelfSlots) {
      final y = shelfTop + (shelfBottom - shelfTop) * frac;
      canvas.drawLine(
        Offset(shelfLeft + 8, y),
        Offset(shelfLeft + shelfWidth - 8, y),
        plankPaint,
      );
    }

    // 2. VINTAGE STUDY CHAIR (Behind the desk)
    final chairCenterX = size.width * 0.50 + parallaxOffset * 25;
    final chairY = size.height * 0.52;
    final chairBackPaint = Paint()..color = const Color(0xFF382315);
    final chairCushionPaint = Paint()..color = const Color(0xFF5E2727);

    // Curved wooden chair back
    final chairPath = Path()
      ..moveTo(chairCenterX - 28, chairY + 40)
      ..cubicTo(
        chairCenterX - 30,
        chairY - 30,
        chairCenterX + 30,
        chairY - 30,
        chairCenterX + 28,
        chairY + 40,
      )
      ..close();
    canvas.drawPath(chairPath, chairBackPaint);

    // Velvet upholstered oval insert
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(chairCenterX, chairY + 8),
        width: 38,
        height: 46,
      ),
      chairCushionPaint,
    );

    // 3. HEAVY WRITING DESK (Centerpiece)
    final deskLeft = size.width * 0.08 + parallaxOffset * 28;
    final deskRight = size.width * 0.78 + parallaxOffset * 28;
    final deskTop = size.height * 0.60;
    final deskThickness = 24.0;

    // Turned wooden desk legs
    final legPaint = Paint()..color = StudyAtmosphereColors.woodDeskMahogany;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          deskLeft + 18,
          deskTop + deskThickness,
          16,
          size.height * 0.28,
        ),
        const Radius.circular(4),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          deskRight - 34,
          deskTop + deskThickness,
          16,
          size.height * 0.28,
        ),
        const Radius.circular(4),
      ),
      legPaint,
    );

    // Desk apron & drawers
    final apronPaint = Paint()..color = const Color(0xFF53321C);
    final apronRect = Rect.fromLTRB(
      deskLeft + 12,
      deskTop + deskThickness,
      deskRight - 12,
      deskTop + deskThickness + 38,
    );
    canvas.drawRect(apronRect, apronPaint);

    // Brass drawer knobs
    final brassPaint = Paint()..color = StudyAtmosphereColors.vintageBrass;
    canvas.drawCircle(
      Offset(
        deskLeft + (deskRight - deskLeft) * 0.32,
        deskTop + deskThickness + 19,
      ),
      4.5,
      brassPaint,
    );
    canvas.drawCircle(
      Offset(
        deskLeft + (deskRight - deskLeft) * 0.68,
        deskTop + deskThickness + 19,
      ),
      4.5,
      brassPaint,
    );

    // Desk Surface Top (bevelled wooden slab)
    final deskSurfacePaint = Paint()
      ..color = StudyAtmosphereColors.woodDeskSurface;
    final deskBevel = Path()
      ..moveTo(deskLeft - 10, deskTop + deskThickness)
      ..lineTo(deskLeft, deskTop)
      ..lineTo(deskRight, deskTop)
      ..lineTo(deskRight + 10, deskTop + deskThickness)
      ..close();
    canvas.drawPath(deskBevel, deskSurfacePaint);

    // Top highlight rim
    final rimPaint = Paint()
      ..color = StudyAtmosphereColors.woodDeskHighlight
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(deskLeft - 10, deskTop + deskThickness),
      Offset(deskRight + 10, deskTop + deskThickness),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FurniturePainter oldDelegate) {
    return oldDelegate.parallaxOffset != parallaxOffset;
  }
}
