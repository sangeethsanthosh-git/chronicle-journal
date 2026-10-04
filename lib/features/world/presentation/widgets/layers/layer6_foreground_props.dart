import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer6ForegroundProps extends StatelessWidget {
  final double steamTick; // oscillating steam animation tick (0.0 to 1.0)
  final double parallaxOffset;

  const Layer6ForegroundProps({
    super.key,
    required this.steamTick,
    this.parallaxOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ForegroundPropsPainter(
          steamTick: steamTick,
          parallaxOffset: parallaxOffset,
        ),
      ),
    );
  }
}

class _ForegroundPropsPainter extends CustomPainter {
  final double steamTick;
  final double parallaxOffset;

  _ForegroundPropsPainter({
    required this.steamTick,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. STEAMING TEACUP & CORK COASTER (Lower-Left foreground)
    final mugX = size.width * 0.32 + parallaxOffset * 32;
    final mugY = size.height * 0.64;

    // Cork Coaster
    final coasterPaint = Paint()..color = const Color(0xFFC7A87A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(mugX, mugY + 14), width: 34, height: 10),
      coasterPaint,
    );

    // Ceramic Teacup (Vintage ivory porcelain with gold rim)
    final cupPaint = Paint()..color = const Color(0xFFFAF7EE);
    final cupPath = Path()
      ..moveTo(mugX - 12, mugY - 6)
      ..lineTo(mugX - 9, mugY + 12)
      ..lineTo(mugX + 9, mugY + 12)
      ..lineTo(mugX + 12, mugY - 6)
      ..close();
    canvas.drawPath(cupPath, cupPaint);

    // Gold Rim
    final goldPaint = Paint()
      ..color = StudyAtmosphereColors.vintageBrass
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(mugX - 12, mugY - 6),
      Offset(mugX + 12, mugY - 6),
      goldPaint,
    );

    // Teacup Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFFAF7EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final handlePath = Path()
      ..moveTo(mugX + 11, mugY - 2)
      ..cubicTo(mugX + 20, mugY, mugX + 18, mugY + 8, mugX + 9, mugY + 9);
    canvas.drawPath(handlePath, handlePaint);

    // Curled Steam Particles Rising
    final steamPaint = Paint()
      ..color = const Color(0x35FAF7EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2; i++) {
      final t = (steamTick + (i * 0.5)) % 1.0;
      final steamY = (mugY - 10) - (t * 28);
      final steamWave = sin((t * 2 * pi) + (i * 1.5)) * 4.0;
      final alpha = ((1.0 - t) * 0.45).clamp(0.0, 1.0);

      steamPaint.color = Color.fromRGBO(250, 247, 238, alpha);
      final steamPath = Path()
        ..moveTo(mugX + (i == 0 ? -3 : 3), steamY + 8)
        ..quadraticBezierTo(
          mugX + steamWave + (i == 0 ? -4 : 4),
          steamY + 2,
          mugX - steamWave + (i == 0 ? -2 : 2),
          steamY - 4,
        );
      canvas.drawPath(steamPath, steamPaint);
    }

    // 2. VINTAGE INKWELL & BRASS NIB HOLDER (Desk right foreground)
    final inkX = size.width * 0.60 + parallaxOffset * 32;
    final inkY = size.height * 0.66;

    // Glass Ink Bottle (Deep Amber Glass)
    final inkPaint = Paint()..color = const Color(0xCC301D0E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(inkX - 9, inkY, 18, 16),
        const Radius.circular(3),
      ),
      inkPaint,
    );

    // Brass Bottle Cap
    final capPaint = Paint()..color = StudyAtmosphereColors.vintageBrass;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(inkX - 6, inkY - 5, 12, 5),
        const Radius.circular(2),
      ),
      capPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ForegroundPropsPainter oldDelegate) {
    return oldDelegate.steamTick != steamTick ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
