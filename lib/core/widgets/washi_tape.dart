import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WashiTape extends StatelessWidget {
  final double width;
  final double height;
  final double rotationDegrees;
  final Color color;

  const WashiTape({
    super.key,
    this.width = 90.0,
    this.height = 24.0,
    this.rotationDegrees = -3.0,
    this.color = AppColors.washiTapeKraft,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationDegrees * (math.pi / 180),
      child: CustomPaint(
        size: Size(width, height),
        painter: _WashiTapePainter(color: color),
      ),
    );
  }
}

class _WashiTapePainter extends CustomPainter {
  final Color color;

  _WashiTapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Left jagged edge
    path.moveTo(4, 0);
    path.lineTo(size.width - 4, 0);

    // Right jagged edge
    const jaggedSteps = 6;
    final stepH = size.height / jaggedSteps;
    for (int i = 0; i <= jaggedSteps; i++) {
      final x = (i % 2 == 0) ? size.width : size.width - 4;
      path.lineTo(x, i * stepH);
    }

    // Bottom edge
    path.lineTo(4, size.height);

    // Left jagged edge back up
    for (int i = jaggedSteps; i >= 0; i--) {
      final x = (i % 2 == 0) ? 0.0 : 4.0;
      path.lineTo(x, i * stepH);
    }
    path.close();

    // Subtle drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path.shift(const Offset(1, 2)), shadowPaint);

    canvas.drawPath(path, paint);

    // Subtle paper fiber lines across tape
    final fiberPaint = Paint()
      ..color = Colors.white.withAlpha(50)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.25, size.height),
      fiberPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.65, size.height),
      fiberPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WashiTapePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
