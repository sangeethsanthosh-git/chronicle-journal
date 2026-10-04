import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Distressed circular rubber stamp seal inspired by reference Image 2
/// ("EXCELLENT QUALITY BESPOKE ARTWORK / MIORA ARCHIVE").
class VintageRubberStamp extends StatelessWidget {
  final String text;
  final String centerText;
  final Color color;
  final double size;
  final double rotationDegrees;

  const VintageRubberStamp({
    super.key,
    this.text = 'MIORA ARCHIVE • BESPOKE QUALITY',
    this.centerText = 'VERIFIED',
    this.color = const Color(0xFF9E3A2B), // Distressed brick red
    this.size = 80.0,
    this.rotationDegrees = -12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * (math.pi / 180),
      child: CustomPaint(
        size: Size(size, size),
        painter: _VintageRubberStampPainter(
          text: text,
          centerText: centerText,
          color: color,
        ),
      ),
    );
  }
}

class _VintageRubberStampPainter extends CustomPainter {
  final String text;
  final String centerText;
  final Color color;

  _VintageRubberStampPainter({
    required this.text,
    required this.centerText,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final stampPaint = Paint()
      ..color = color.withAlpha(190)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final innerCirclePaint = Paint()
      ..color = color.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer double ring
    canvas.drawCircle(center, radius - 2, stampPaint);
    canvas.drawCircle(center, radius - 6, innerCirclePaint);

    // Inner ring enclosing center text
    canvas.drawCircle(center, radius * 0.55, innerCirclePaint);

    // Center stars
    final starPaint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.fill;

    _drawTinyStar(
      canvas,
      Offset(center.dx - 14, center.dy - 12),
      2.5,
      starPaint,
    );
    _drawTinyStar(canvas, Offset(center.dx, center.dy - 14), 3.2, starPaint);
    _drawTinyStar(
      canvas,
      Offset(center.dx + 14, center.dy - 12),
      2.5,
      starPaint,
    );

    // Center Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText.toUpperCase(),
        style: TextStyle(
          color: color.withAlpha(220),
          fontSize: size.width * 0.12,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
          letterSpacing: 1.5,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 1.5);

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 + 3,
      ),
    );

    // Bottom decorative flourish / stars
    _drawTinyStar(
      canvas,
      Offset(center.dx - 12, center.dy + 14),
      2.2,
      starPaint,
    );
    _drawTinyStar(
      canvas,
      Offset(center.dx + 12, center.dy + 14),
      2.2,
      starPaint,
    );

    // Circular curved text along top & bottom ring
    _drawCurvedText(canvas, text, center, radius - 12);
  }

  void _drawCurvedText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
  ) {
    final charCount = text.length;
    if (charCount == 0) return;

    final sweepAngle = math.pi * 1.5;
    final startAngle = -math.pi * 0.75;
    final angleStep = sweepAngle / charCount;

    for (int i = 0; i < charCount; i++) {
      final char = text[i];
      final angle = startAngle + (i * angleStep);

      final charPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: color.withAlpha(180),
            fontSize: radius * 0.18,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2);
      charPainter.paint(
        canvas,
        Offset(-charPainter.width / 2, -charPainter.height / 2),
      );
      canvas.restore();
    }
  }

  void _drawTinyStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final rad1 = (i * 72 - 90) * (math.pi / 180);
      final rad2 = (i * 72 + 36 - 90) * (math.pi / 180);
      final p1 = Offset(
        center.dx + size * math.cos(rad1),
        center.dy + size * math.sin(rad1),
      );
      final p2 = Offset(
        center.dx + (size * 0.45) * math.cos(rad2),
        center.dy + (size * 0.45) * math.sin(rad2),
      );
      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.lineTo(p2.dx, p2.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VintageRubberStampPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.centerText != centerText ||
      oldDelegate.color != color;
}
