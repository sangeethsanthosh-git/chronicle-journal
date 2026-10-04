import 'package:flutter/material.dart';

/// CustomPainter for the warm illustrated wooden bookshelf matching the editorial aesthetic
/// of reference image media_1791113864516.jpg:
/// - Honey-oak / warm walnut wooden planks with depth bevels
/// - Soft diagonal cast shadow falling down and to the left (~45°)
/// - Fine wood grain texture accents
class JournalShelfPainter extends CustomPainter {
  final double shelfY;
  final double shelfThickness;
  final double shelfDepth;
  final Color woodTopColor;
  final Color woodFrontColor;
  final Color woodShadowColor;

  const JournalShelfPainter({
    required this.shelfY,
    this.shelfThickness = 14.0,
    this.shelfDepth = 12.0,
    this.woodTopColor = const Color(0xFFC48E60),
    this.woodFrontColor = const Color(0xFFA16B40),
    this.woodShadowColor = const Color(0x33000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    // 1. Diagonal Soft Cast Shadow on the wall (down-left angle from warm top-right light)
    final shadowPath = Path();
    final shadowDropY = shelfY + shelfThickness;
    const shadowOffsetX = -32.0;
    const shadowOffsetY = 36.0;

    shadowPath.moveTo(0, shelfY + 2);
    shadowPath.lineTo(width, shelfY + 2);
    shadowPath.lineTo(width + shadowOffsetX, shadowDropY + shadowOffsetY);
    shadowPath.lineTo(shadowOffsetX, shadowDropY + shadowOffsetY);
    shadowPath.close();

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          woodShadowColor.withValues(alpha: 0.35),
          woodShadowColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, shelfY, width, shadowOffsetY + 10));

    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Shelf Top Surface (slight perspective slant)
    final topSurfacePath = Path();
    topSurfacePath.moveTo(0, shelfY - shelfDepth);
    topSurfacePath.lineTo(width, shelfY - shelfDepth);
    topSurfacePath.lineTo(width, shelfY);
    topSurfacePath.lineTo(0, shelfY);
    topSurfacePath.close();

    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [woodTopColor.withValues(alpha: 0.85), woodTopColor],
      ).createShader(Rect.fromLTWH(0, shelfY - shelfDepth, width, shelfDepth));

    canvas.drawPath(topSurfacePath, topPaint);

    // Top highlight rim (fine light edge)
    final highlightPaint = Paint()
      ..color = const Color(0xFFECC29C).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, shelfY - shelfDepth),
      Offset(width, shelfY - shelfDepth),
      highlightPaint,
    );

    // 3. Shelf Front Facing Plank
    final frontRect = Rect.fromLTWH(0, shelfY, width, shelfThickness);
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          woodFrontColor,
          Color.lerp(woodFrontColor, Colors.black, 0.25)!,
        ],
      ).createShader(frontRect);

    canvas.drawRect(frontRect, frontPaint);

    // Front bottom dark rim
    final bottomRimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, shelfY + shelfThickness),
      Offset(width, shelfY + shelfThickness),
      bottomRimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant JournalShelfPainter oldDelegate) =>
      oldDelegate.shelfY != shelfY ||
      oldDelegate.shelfThickness != shelfThickness ||
      oldDelegate.woodTopColor != woodTopColor;
}
