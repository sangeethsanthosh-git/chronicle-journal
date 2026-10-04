import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PaperclipColor { silver, brassGold, roseGold, matteBlack }

/// A realistic metallic paperclip widget that visually clasps onto cards,
/// notes, or polaroids, casting an authentic drop shadow.
class PaperclipWidget extends StatelessWidget {
  final double width;
  final double height;
  final PaperclipColor color;
  final double rotationDegrees;

  const PaperclipWidget({
    super.key,
    this.width = 18.0,
    this.height = 48.0,
    this.color = PaperclipColor.silver,
    this.rotationDegrees = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * (math.pi / 180),
      child: CustomPaint(
        size: Size(width, height),
        painter: _PaperclipPainter(color: color),
      ),
    );
  }
}

class _PaperclipPainter extends CustomPainter {
  final PaperclipColor color;

  _PaperclipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Metallic colors
    final Color mainColor;
    final Color highlightColor;
    final Color darkEdgeColor;

    switch (color) {
      case PaperclipColor.silver:
        mainColor = const Color(0xFFC0C7CE);
        highlightColor = const Color(0xFFFFFFFF);
        darkEdgeColor = const Color(0xFF767F88);
        break;
      case PaperclipColor.brassGold:
        mainColor = const Color(0xFFD4AF37);
        highlightColor = const Color(0xFFFFF4B8);
        darkEdgeColor = const Color(0xFF8A6B1A);
        break;
      case PaperclipColor.roseGold:
        mainColor = const Color(0xFFDE9E9B);
        highlightColor = const Color(0xFFFFECEB);
        darkEdgeColor = const Color(0xFF8F5855);
        break;
      case PaperclipColor.matteBlack:
        mainColor = const Color(0xFF333333);
        highlightColor = const Color(0xFF666666);
        darkEdgeColor = const Color(0xFF111111);
        break;
    }

    const wireThickness = 2.4;

    // Shadow path (shifted down-right)
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wireThickness
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    // Dark edge path (gives cylindrical depth)
    final darkEdgePaint = Paint()
      ..color = darkEdgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = wireThickness
      ..strokeCap = StrokeCap.round;

    // Main metallic body
    final mainPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = wireThickness - 0.4
      ..strokeCap = StrokeCap.round;

    // Specular highlight line along center
    final highlightPaint = Paint()
      ..color = highlightColor.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Construct the continuous paperclip wire path
    // 1. Starts on inner small loop bottom
    // 2. Goes up to inner arch
    // 3. Down to bottom medium arch
    // 4. Up to top outer arch
    // 5. Down to outer bottom end
    final clipPath = Path();

    final rOuter = w * 0.46;
    final rInner = w * 0.28;

    // Bottom-left inner end
    clipPath.moveTo(w * 0.40, h * 0.65);
    // Up along inner segment
    clipPath.lineTo(w * 0.40, h * 0.32);
    // Inner top curve
    clipPath.arcToPoint(
      Offset(w * 0.40 + rInner, h * 0.32),
      radius: Radius.circular(rInner / 2),
      clockwise: true,
    );
    // Down to bottom loop
    clipPath.lineTo(w * 0.40 + rInner, h * 0.82);
    // Bottom curve
    clipPath.arcToPoint(
      Offset(w * 0.16, h * 0.82),
      radius: Radius.circular(w * 0.26),
      clockwise: true,
    );
    // Long side up to top outer curve
    clipPath.lineTo(w * 0.16, h * 0.16);
    // Top outer curve
    clipPath.arcToPoint(
      Offset(w * 0.16 + rOuter * 1.7, h * 0.16),
      radius: Radius.circular(rOuter),
      clockwise: true,
    );
    // Long outer side down to end
    clipPath.lineTo(w * 0.16 + rOuter * 1.7, h * 0.76);

    // Draw shadow
    canvas.drawPath(clipPath.shift(const Offset(1.5, 2.0)), shadowPaint);

    // Draw metallic body
    canvas.drawPath(clipPath, darkEdgePaint);
    canvas.drawPath(clipPath, mainPaint);
    canvas.drawPath(clipPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _PaperclipPainter oldDelegate) =>
      oldDelegate.color != color;
}
