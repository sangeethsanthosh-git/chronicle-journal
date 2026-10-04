import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer0Skybox extends StatelessWidget {
  final int hour;
  final double parallaxOffset;

  const Layer0Skybox({
    super.key,
    required this.hour,
    this.parallaxOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SkyboxPainter(hour: hour, parallaxOffset: parallaxOffset),
      ),
    );
  }
}

class _SkyboxPainter extends CustomPainter {
  final int hour;
  final double parallaxOffset;

  _SkyboxPainter({required this.hour, required this.parallaxOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final skyColors = StudyAtmosphereColors.getSkyGradient(hour);
    final isNight = hour < 6 || hour >= 20;

    // Background gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: skyColors,
    );

    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Stars at night
    if (isNight) {
      final starPaint = Paint()..color = StudyAtmosphereColors.starSparkle;
      final rng = Random(42); // deterministic seed for starfield
      for (int i = 0; i < 45; i++) {
        final x =
            (rng.nextDouble() * size.width + parallaxOffset * 5) % size.width;
        final y = rng.nextDouble() * size.height * 0.45;
        final radius = rng.nextDouble() * 1.5 + 0.5;
        canvas.drawCircle(Offset(x, y), radius, starPaint);
      }

      // Crescent moon
      final moonCenter = Offset(
        size.width * 0.78 + parallaxOffset * 8,
        size.height * 0.16,
      );
      final moonPaint = Paint()..color = StudyAtmosphereColors.nightMoonGlow;
      canvas.drawCircle(moonCenter, 18, moonPaint);

      // Cutout for crescent
      final shadowPaint = Paint()..color = skyColors.first;
      canvas.drawCircle(moonCenter.translate(6, -4), 16, shadowPaint);
    } else {
      // Warm sun glow in morning/afternoon
      final sunCenter = Offset(
        size.width * 0.72 + parallaxOffset * 8,
        size.height * 0.18,
      );
      final sunGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            StudyAtmosphereColors.dawnSunGlow.withValues(alpha: 0.8),
            StudyAtmosphereColors.dawnSunGlow.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: 45));
      canvas.drawCircle(sunCenter, 45, sunGlow);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyboxPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
