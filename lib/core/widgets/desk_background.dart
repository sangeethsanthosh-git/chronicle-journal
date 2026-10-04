import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a warm wooden desk background complete with subtle wood grain,
/// plank lines, realistic desk props (sharpened pencil, eraser, coffee ring),
/// recreating the authentic physical writing desk from the reference image.
class DeskBackground extends StatelessWidget {
  final Widget child;
  final bool showProps;

  const DeskBackground({super.key, required this.child, this.showProps = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Wood grain desk surface
        Positioned.fill(child: CustomPaint(painter: _DeskWoodPainter())),

        // Realistic Desk Props (pencil, coffee ring, eraser)
        if (showProps)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DeskPropsPainter()),
            ),
          ),

        // Child content (the open book)
        Positioned.fill(child: child),
      ],
    );
  }
}

class _DeskWoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm timber base gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF533824), // Warm walnut
          Color(0xFF3E2718), // Deep amber wood
          Color(0xFF2C1B10), // Rich dark timber
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle horizontal wood plank seams
    final plankPaint = Paint()
      ..color = Colors.black.withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final plankHighlightPaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final plankCount = (size.height / 140).ceil();
    for (int i = 1; i <= plankCount; i++) {
      final y = i * 140.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankPaint);
      canvas.drawLine(
        Offset(0, y + 1),
        Offset(size.width, y + 1),
        plankHighlightPaint,
      );
    }

    // Organic wood grain ripples
    final grainPaint = Paint()
      ..color = const Color(0xFF6E4A32).withAlpha(35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double y = 20; y < size.height; y += 45) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 50) {
        final wave = math.sin((x / size.width) * 4 * math.pi + y) * 4.0;
        path.lineTo(x, y + wave);
      }
      canvas.drawPath(path, grainPaint);
    }

    // Ambient radial vignette (concentrates light toward center of desk)
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.1, -0.1),
        radius: 1.1,
        colors: [
          Colors.transparent,
          Colors.black.withAlpha(40),
          Colors.black.withAlpha(110),
        ],
        stops: const [0.5, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DeskPropsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Faint coffee cup ring stain on top-right of the desk
    _drawCoffeeRing(canvas, Offset(size.width - 45, 60), 38.0);

    // 2. Pink & blue beveled eraser sitting on desk near bottom right
    _drawEraser(canvas, Offset(size.width - 55, size.height - 75));

    // 3. Classic yellow wooden pencil resting at the bottom-left desk edge
    _drawPencil(canvas, Offset(35, size.height - 35), size.width * 0.42);
  }

  void _drawCoffeeRing(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = const Color(0xFF5D3A1A).withAlpha(32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Outer ring with slight irregularity
    final path = Path();
    for (int i = 0; i <= 360; i += 10) {
      final rad = i * (math.pi / 180);
      final r = radius + (math.sin(i * 3) * 1.5);
      final x = center.dx + r * math.cos(rad);
      final y = center.dy + r * math.sin(rad);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, ringPaint);

    // Inner lighter ring
    final innerPaint = Paint()
      ..color = const Color(0xFF5D3A1A).withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 4, innerPaint);
  }

  void _drawEraser(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(14 * (math.pi / 180));

    // Eraser shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, 4, 38, 20),
        const Radius.circular(3),
      ),
      shadowPaint,
    );

    // Pink half
    final pinkPaint = Paint()..color = const Color(0xFFE88A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 22, 20),
        const Radius.circular(3),
      ),
      pinkPaint,
    );

    // Blue/grey half
    final bluePaint = Paint()..color = const Color(0xFF6B8BA4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 0, 18, 20),
        const Radius.circular(3),
      ),
      bluePaint,
    );

    // White beveled border line between halves
    final splitPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(20, 0), const Offset(20, 20), splitPaint);

    canvas.restore();
  }

  void _drawPencil(Canvas canvas, Offset start, double length) {
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(-8 * (math.pi / 180));

    // Pencil soft shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 4, length, 7),
        const Radius.circular(2),
      ),
      shadowPaint,
    );

    // Yellow pencil body
    final bodyPaint = Paint()..color = const Color(0xFFE5A93C);
    canvas.drawRect(Rect.fromLTWH(18, 0, length - 36, 7), bodyPaint);

    // Darker stripe on pencil wood (hexagonal facet)
    final facetPaint = Paint()..color = const Color(0xFFD49228);
    canvas.drawRect(Rect.fromLTWH(18, 2.2, length - 36, 2.6), facetPaint);

    // Sharpened wood cone (tip)
    final tipWoodPaint = Paint()..color = const Color(0xFFEAD8B8);
    final tipPath = Path()
      ..moveTo(18, 0)
      ..lineTo(0, 3.5)
      ..lineTo(18, 7)
      ..close();
    canvas.drawPath(tipPath, tipWoodPaint);

    // Lead graphite point
    final leadPaint = Paint()..color = const Color(0xFF2C2C2C);
    final leadPath = Path()
      ..moveTo(6, 2.3)
      ..lineTo(0, 3.5)
      ..lineTo(6, 4.7)
      ..close();
    canvas.drawPath(leadPath, leadPaint);

    // Silver metal ferrule
    final ferrulePaint = Paint()..color = const Color(0xFFB0B0B0);
    canvas.drawRect(Rect.fromLTWH(length - 18, 0, 7, 7), ferrulePaint);

    // Pink eraser on the end
    final eraserPaint = Paint()..color = const Color(0xFFE88A8A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(length - 11, 0, 11, 7),
        const Radius.circular(3),
      ),
      eraserPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
