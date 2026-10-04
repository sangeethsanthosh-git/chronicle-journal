import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PostalStamp extends StatelessWidget {
  final String dateText;
  final String locationText;
  final Color color;
  final double size;

  const PostalStamp({
    super.key,
    required this.dateText,
    this.locationText = 'PARIS',
    this.color = AppColors.postalStampBlue,
    this.size = 72.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -8 * (math.pi / 180),
      child: CustomPaint(
        size: Size(size * 1.8, size),
        painter: _PostalStampPainter(
          dateText: dateText,
          locationText: locationText,
          color: color,
        ),
      ),
    );
  }
}

class _PostalStampPainter extends CustomPainter {
  final String dateText;
  final String locationText;
  final Color color;

  _PostalStampPainter({
    required this.dateText,
    required this.locationText,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stampPaint = Paint()
      ..color = color.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final circleRadius = size.height * 0.45;
    final circleCenter = Offset(circleRadius + 4, size.height * 0.5);

    // Outer and inner circles
    canvas.drawCircle(circleCenter, circleRadius, stampPaint);
    canvas.drawCircle(circleCenter, circleRadius - 4, stampPaint);

    // Text inside postmark circle
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$locationText\n$dateText',
        style: TextStyle(
          color: color.withAlpha(200),
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          fontFamily: 'serif',
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: circleRadius * 1.8);

    textPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - textPainter.width * 0.5,
        circleCenter.dy - textPainter.height * 0.5,
      ),
    );

    // Wavy postal cancellation lines
    final waveStartX = circleCenter.dx + circleRadius + 6;
    final waveEndX = size.width;
    const waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      final y = size.height * 0.3 + (i * 8.0);
      final wavePath = Path();
      wavePath.moveTo(waveStartX, y);

      double x = waveStartX;
      while (x < waveEndX) {
        wavePath.relativeQuadraticBezierTo(6, -3, 12, 0);
        wavePath.relativeQuadraticBezierTo(6, 3, 12, 0);
        x += 24;
      }
      canvas.drawPath(wavePath, stampPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PostalStampPainter oldDelegate) {
    return oldDelegate.dateText != dateText ||
        oldDelegate.locationText != locationText ||
        oldDelegate.color != color;
  }
}
