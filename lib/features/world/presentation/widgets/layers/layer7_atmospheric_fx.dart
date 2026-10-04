import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer7AtmosphericFX extends StatelessWidget {
  final int hour;
  final bool isLampOn;
  final double particleTick; // 0.0 to 1.0 continuously looping
  final double parallaxOffset;

  const Layer7AtmosphericFX({
    super.key,
    required this.hour,
    required this.isLampOn,
    required this.particleTick,
    this.parallaxOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AtmosphericFXPainter(
          hour: hour,
          isLampOn: isLampOn,
          particleTick: particleTick,
          parallaxOffset: parallaxOffset,
        ),
      ),
    );
  }
}

class _AtmosphericFXPainter extends CustomPainter {
  final int hour;
  final bool isLampOn;
  final double particleTick;
  final double parallaxOffset;

  _AtmosphericFXPainter({
    required this.hour,
    required this.isLampOn,
    required this.particleTick,
    required this.parallaxOffset,
  });

  // Pre-configured deterministic seeds for exactly 20 dust particles (Zero GC allocation)
  static const int _particleCount = 20;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. AMBIENT COLOR TEMPERATURE FILTER
    final ambientFilter = StudyAtmosphereColors.getAmbientLightingFilter(
      hour,
      isLampOn,
    );
    if (ambientFilter != Colors.transparent) {
      canvas.drawRect(Offset.zero & size, Paint()..color = ambientFilter);
    }

    // 2. WARM LAMPLIGHT VOLUMETRIC CONE (If lamp is illuminated)
    if (isLampOn) {
      final lampOrigin = Offset(
        size.width * 0.22 + parallaxOffset * 28,
        size.height * 0.50,
      );
      final lampBloom = Paint()
        ..shader =
            RadialGradient(
              colors: [
                StudyAtmosphereColors.lampLightGlow.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: lampOrigin, radius: size.width * 0.55),
            );

      canvas.drawCircle(lampOrigin, size.width * 0.55, lampBloom);
    }

    // 3. FLOATING AMBIENT DUST MOTES
    final dustPaint = Paint()..color = StudyAtmosphereColors.dustMote;

    for (int i = 0; i < _particleCount; i++) {
      // Deterministic particle trajectory based on index and particleTick
      final seed = i * 137.5;
      final speed = 0.6 + (i % 4) * 0.2;
      final t = (particleTick * speed + (i / _particleCount)) % 1.0;

      // Drift upward and oscillate gently side to side
      final x =
          ((sin(seed + t * 4) * 45) +
              (size.width * (0.15 + (i * 0.038))) +
              parallaxOffset * 35) %
          size.width;
      final y = size.height * (0.25 + (1.0 - t) * 0.55);

      final radius = 1.0 + (i % 3) * 0.7;
      final alpha = (sin(t * pi) * 0.7).clamp(0.0, 1.0);

      dustPaint.color = Color.fromRGBO(255, 244, 207, alpha);
      canvas.drawCircle(Offset(x, y), radius, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericFXPainter oldDelegate) {
    return oldDelegate.particleTick != particleTick ||
        oldDelegate.isLampOn != isLampOn ||
        oldDelegate.hour != hour ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
