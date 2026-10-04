import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum DoodleType { star, sparkle, heart, sun, leaf }

class DoodleSticker extends StatelessWidget {
  final DoodleType type;
  final double size;
  final Color color;

  const DoodleSticker({
    super.key,
    required this.type,
    this.size = 28.0,
    this.color = AppColors.vintageGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DoodlePainter(type: type, color: color),
    );
  }
}

class _DoodlePainter extends CustomPainter {
  final DoodleType type;
  final Color color;

  _DoodlePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case DoodleType.star:
        _drawStar(canvas, center, size.width * 0.45, paint);
        break;
      case DoodleType.sparkle:
        _drawSparkle(canvas, center, size.width * 0.45, paint);
        break;
      case DoodleType.heart:
        _drawHeart(canvas, size, paint);
        break;
      case DoodleType.sun:
        _drawSun(canvas, center, size.width * 0.22, paint);
        break;
      case DoodleType.leaf:
        _drawLeaf(canvas, center, size.width * 0.45, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = -math.pi / 2 + i * 4 * math.pi / 5;
      final x = center.dx + radius * math.cos(outerAngle);
      final y = center.dy + radius * math.sin(outerAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    // 4-point sparkle cross
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, h * 0.3);
    path.cubicTo(w * 0.2, 0, 0, h * 0.4, w * 0.5, h * 0.85);
    path.moveTo(w * 0.5, h * 0.3);
    path.cubicTo(w * 0.8, 0, w, h * 0.4, w * 0.5, h * 0.85);
    canvas.drawPath(path, paint);
  }

  void _drawSun(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    const rays = 8;
    for (int i = 0; i < rays; i++) {
      final angle = i * 2 * math.pi / rays;
      final start = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 6) * math.cos(angle),
        center.dy + (radius + 6) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - radius * 0.5, center.dy + radius * 0.5);
    path.quadraticBezierTo(
      center.dx - radius * 0.5,
      center.dy - radius * 0.5,
      center.dx + radius * 0.5,
      center.dy - radius * 0.5,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.5,
      center.dy + radius * 0.5,
      center.dx - radius * 0.5,
      center.dy + radius * 0.5,
    );
    canvas.drawPath(path, paint);
    // Leaf vein
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
