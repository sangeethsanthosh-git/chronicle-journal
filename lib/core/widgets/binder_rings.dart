import 'package:flutter/material.dart';

class BinderRings extends StatelessWidget {
  final double height;
  final int ringCount;

  const BinderRings({super.key, required this.height, this.ringCount = 6});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(32, height),
      painter: _BinderRingsPainter(ringCount: ringCount),
    );
  }
}

class _BinderRingsPainter extends CustomPainter {
  final int ringCount;

  _BinderRingsPainter({required this.ringCount});

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0xFF8A847C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final holePaint = Paint()
      ..color = Colors.black.withAlpha(160)
      ..style = PaintingStyle.fill;

    final spacing = size.height / (ringCount + 1);

    for (int i = 1; i <= ringCount; i++) {
      final centerY = spacing * i;

      // Draw punch holes on left and right
      canvas.drawCircle(Offset(4, centerY), 3.0, holePaint);
      canvas.drawCircle(Offset(size.width - 4, centerY), 3.0, holePaint);

      // Draw metallic curved ring connecting the holes
      final ringPath = Path();
      ringPath.moveTo(4, centerY);
      ringPath.cubicTo(
        size.width * 0.2,
        centerY - 10,
        size.width * 0.8,
        centerY - 10,
        size.width - 4,
        centerY,
      );

      // Shadow
      canvas.drawPath(
        ringPath.shift(const Offset(0, 1.5)),
        Paint()
          ..color = Colors.black.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );

      // Main metallic body
      canvas.drawPath(ringPath, ringPaint);

      // Metallic glare highlight
      final highlightPath = Path();
      highlightPath.moveTo(size.width * 0.35, centerY - 8.5);
      highlightPath.lineTo(size.width * 0.65, centerY - 8.5);
      canvas.drawPath(highlightPath, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BinderRingsPainter oldDelegate) {
    return oldDelegate.ringCount != ringCount;
  }
}
