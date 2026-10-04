import 'package:flutter/material.dart';

enum BookDoodleType {
  rocket,
  boombox,
  puzzleCube,
  handArrow,
  coffeeStainMini,
  smileyNotes,
}

class BookMarginDoodle extends StatelessWidget {
  final BookDoodleType type;
  final double size;
  final Color color;

  const BookMarginDoodle({
    super.key,
    required this.type,
    this.size = 36.0,
    this.color = const Color(0xFF2C2621),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BookMarginDoodlePainter(type: type, color: color),
    );
  }
}

class _BookMarginDoodlePainter extends CustomPainter {
  final BookDoodleType type;
  final Color color;

  _BookMarginDoodlePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case BookDoodleType.rocket:
        _drawRocket(canvas, size, pen);
        break;
      case BookDoodleType.boombox:
        _drawBoombox(canvas, size, pen);
        break;
      case BookDoodleType.puzzleCube:
        _drawPuzzleCube(canvas, size, pen);
        break;
      case BookDoodleType.handArrow:
        _drawHandArrow(canvas, size, pen);
        break;
      case BookDoodleType.coffeeStainMini:
        _drawMiniCoffee(canvas, size, pen);
        break;
      case BookDoodleType.smileyNotes:
        _drawSmiley(canvas, size, pen);
        break;
    }
  }

  // 1. Rocket doodle (like in top left of reference photo)
  void _drawRocket(Canvas canvas, Size size, Paint pen) {
    final w = size.width;
    final h = size.height;

    // Rocket body (fuselage)
    final body = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.75, h * 0.35, w * 0.75, h * 0.7, w * 0.5, h * 0.8)
      ..cubicTo(w * 0.25, h * 0.7, w * 0.25, h * 0.35, w * 0.5, h * 0.1)
      ..close();
    canvas.drawPath(body, pen);

    // Porthole window
    canvas.drawCircle(Offset(w * 0.5, h * 0.4), w * 0.12, pen);

    // Left fin
    final leftFin = Path()
      ..moveTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.1, h * 0.85)
      ..lineTo(w * 0.32, h * 0.78);
    canvas.drawPath(leftFin, pen);

    // Right fin
    final rightFin = Path()
      ..moveTo(w * 0.7, h * 0.6)
      ..lineTo(w * 0.9, h * 0.85)
      ..lineTo(w * 0.68, h * 0.78);
    canvas.drawPath(rightFin, pen);

    // Flame thrust
    final flame = Path()
      ..moveTo(w * 0.4, h * 0.82)
      ..lineTo(w * 0.5, h * 0.98)
      ..lineTo(w * 0.6, h * 0.82);
    canvas.drawPath(flame, pen);
  }

  // 2. Boombox radio doodle (like in top right of reference photo)
  void _drawBoombox(Canvas canvas, Size size, Paint pen) {
    final w = size.width;
    final h = size.height;

    // Radio main box
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.8, h * 0.55),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, pen);

    // Handle
    final handle = Path()
      ..moveTo(w * 0.3, h * 0.3)
      ..lineTo(w * 0.3, h * 0.15)
      ..lineTo(w * 0.7, h * 0.15)
      ..lineTo(w * 0.7, h * 0.3);
    canvas.drawPath(handle, pen);

    // Left speaker
    canvas.drawCircle(Offset(w * 0.3, h * 0.58), w * 0.14, pen);
    canvas.drawCircle(Offset(w * 0.3, h * 0.58), w * 0.05, pen);

    // Right speaker
    canvas.drawCircle(Offset(w * 0.7, h * 0.58), w * 0.14, pen);
    canvas.drawCircle(Offset(w * 0.7, h * 0.58), w * 0.05, pen);

    // Cassette deck in middle
    canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.48, w * 0.18, h * 0.2), pen);
  }

  // 3. Mini Rubik's cube / puzzle doodle (like bottom left of reference photo)
  void _drawPuzzleCube(Canvas canvas, Size size, Paint pen) {
    final w = size.width;
    final h = size.height;

    final cubeRect = Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6);
    canvas.drawRect(cubeRect, pen);

    // Grid lines
    canvas.drawLine(Offset(w * 0.4, h * 0.2), Offset(w * 0.4, h * 0.8), pen);
    canvas.drawLine(Offset(w * 0.6, h * 0.2), Offset(w * 0.6, h * 0.8), pen);

    canvas.drawLine(Offset(w * 0.2, h * 0.4), Offset(w * 0.8, h * 0.4), pen);
    canvas.drawLine(Offset(w * 0.2, h * 0.6), Offset(w * 0.8, h * 0.6), pen);

    // Small caption or exclamation scribble
    final textLine = Path()
      ..moveTo(w * 0.15, h * 0.9)
      ..lineTo(w * 0.85, h * 0.9);
    canvas.drawPath(textLine, pen);
  }

  // 4. Hand-drawn doodle arrow
  void _drawHandArrow(Canvas canvas, Size size, Paint pen) {
    final w = size.width;
    final h = size.height;

    final arrow = Path()
      ..moveTo(w * 0.15, h * 0.7)
      ..cubicTo(w * 0.4, h * 0.8, w * 0.6, h * 0.3, w * 0.85, h * 0.4);
    canvas.drawPath(arrow, pen);

    // Arrowhead
    final head = Path()
      ..moveTo(w * 0.7, h * 0.28)
      ..lineTo(w * 0.88, h * 0.38)
      ..lineTo(w * 0.78, h * 0.55);
    canvas.drawPath(head, pen);
  }

  // 5. Mini coffee ring doodle
  void _drawMiniCoffee(Canvas canvas, Size size, Paint pen) {
    final cPaint = Paint()
      ..color = pen.color.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.35,
      cPaint,
    );
  }

  // 6. Smiley / sketch note
  void _drawSmiley(Canvas canvas, Size size, Paint pen) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, size.width * 0.35, pen);
    // Eyes
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.42), 1.8, pen);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.42), 1.8, pen);
    // Smile
    final smile = Path()
      ..moveTo(size.width * 0.35, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.72,
        size.width * 0.65,
        size.height * 0.58,
      );
    canvas.drawPath(smile, pen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
