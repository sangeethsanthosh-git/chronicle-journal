import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer1WindowVista extends StatelessWidget {
  final int hour;
  final bool isRaining;
  final double parallaxOffset;

  const Layer1WindowVista({
    super.key,
    required this.hour,
    this.isRaining = false,
    this.parallaxOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _WindowVistaPainter(
          hour: hour,
          isRaining: isRaining,
          parallaxOffset: parallaxOffset,
        ),
      ),
    );
  }
}

class _WindowVistaPainter extends CustomPainter {
  final int hour;
  final bool isRaining;
  final double parallaxOffset;

  _WindowVistaPainter({
    required this.hour,
    required this.isRaining,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Window coordinates (positioned towards the upper center-left)
    final windowRect = Rect.fromCenter(
      center: Offset(
        size.width * 0.38 + parallaxOffset * 10,
        size.height * 0.28,
      ),
      width: size.width * 0.42,
      height: size.height * 0.36,
    );

    // Distant rolling hills silhouette through window
    final hillPaint = Paint()
      ..color = (hour >= 20 || hour < 6)
          ? const Color(0xFF131A2E)
          : const Color(0xFF4A6856).withValues(alpha: 0.85);

    final hillPath = Path()
      ..moveTo(windowRect.left - 20, windowRect.bottom)
      ..quadraticBezierTo(
        windowRect.left + windowRect.width * 0.3 + parallaxOffset * 15,
        windowRect.bottom - 45,
        windowRect.left + windowRect.width * 0.6 + parallaxOffset * 15,
        windowRect.bottom - 25,
      )
      ..quadraticBezierTo(
        windowRect.left + windowRect.width * 0.85 + parallaxOffset * 15,
        windowRect.bottom - 55,
        windowRect.right + 20,
        windowRect.bottom,
      )
      ..close();

    // Clip hills to window interior
    canvas.save();
    final archPath = Path()
      ..moveTo(windowRect.left, windowRect.bottom)
      ..lineTo(windowRect.left, windowRect.top + 30)
      ..arcToPoint(
        Offset(windowRect.right, windowRect.top + 30),
        radius: Radius.circular(windowRect.width / 2),
      )
      ..lineTo(windowRect.right, windowRect.bottom)
      ..close();

    canvas.clipPath(archPath);
    canvas.drawPath(hillPath, hillPaint);

    // Glass tint
    final glassPaint = Paint()..color = StudyAtmosphereColors.windowGlassTint;
    canvas.drawRect(windowRect, glassPaint);

    // Raindrops if raining
    if (isRaining) {
      final rainPaint = Paint()
        ..color = StudyAtmosphereColors.rainStreak
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 20; i++) {
        final rx = windowRect.left + (i * 19.0) % windowRect.width;
        final ry = windowRect.top + ((i * 31.0) % (windowRect.height - 20));
        canvas.drawLine(Offset(rx, ry), Offset(rx - 3, ry + 12), rainPaint);
      }
    }
    canvas.restore();

    // Window Wooden Frame & Muntins (Grid Bars)
    final framePaint = Paint()
      ..color = StudyAtmosphereColors.windowFrame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawPath(archPath, framePaint);

    // Vertical Muntin (center divider)
    final muntinPaint = Paint()
      ..color = StudyAtmosphereColors.windowFrame
      ..strokeWidth = 4.0;
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      muntinPaint,
    );

    // Horizontal Muntin (cross divider)
    canvas.drawLine(
      Offset(windowRect.left, windowRect.top + windowRect.height * 0.45),
      Offset(windowRect.right, windowRect.top + windowRect.height * 0.45),
      muntinPaint,
    );

    // Window Sill
    final sillPaint = Paint()..color = StudyAtmosphereColors.windowSill;
    final sillRect = Rect.fromLTWH(
      windowRect.left - 12,
      windowRect.bottom - 2,
      windowRect.width + 24,
      12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sillRect, const Radius.circular(3)),
      sillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WindowVistaPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.isRaining != isRaining ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
