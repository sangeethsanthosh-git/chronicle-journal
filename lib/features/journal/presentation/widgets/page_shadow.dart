import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders dynamic realistic paper shadows during 3D physical page turns:
/// - Spine crease shadow
/// - Dynamic cast shadow on the flat page underneath
/// - Paper curl specular highlight & underside gradient
class SpineShadow extends StatelessWidget {
  final double width;
  final double depth;

  const SpineShadow({super.key, this.width = 36.0, this.depth = 1.0});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withAlpha((55 * depth).toInt().clamp(0, 255)),
              Colors.black.withAlpha((20 * depth).toInt().clamp(0, 255)),
              Colors.transparent,
              Colors.black.withAlpha((20 * depth).toInt().clamp(0, 255)),
              Colors.black.withAlpha((55 * depth).toInt().clamp(0, 255)),
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Dynamic shadow cast on the page underneath by the lifting/turning page.
/// Changes width and opacity according to rotation angle progress.
class UnderPageCastShadow extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool
  isRightSide; // true if shadow cast on the right page, false for left

  const UnderPageCastShadow({
    super.key,
    required this.progress,
    required this.isRightSide,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01 || progress >= 0.99) {
      return const SizedBox.shrink();
    }

    // Shadow is strongest when page is lifted around 20-70 degrees
    final angle = progress * math.pi;
    final shadowIntensity = math.sin(angle);
    final alpha = (80 * shadowIntensity).toInt().clamp(0, 255);
    final shadowWidth = 30.0 + (90.0 * shadowIntensity);

    return IgnorePointer(
      child: Align(
        alignment: isRightSide ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: shadowWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isRightSide ? Alignment.centerLeft : Alignment.centerRight,
              end: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                Colors.black.withAlpha(alpha),
                Colors.black.withAlpha((alpha * 0.45).toInt()),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient overlay on the turning paper creating specular highlight along
/// the bend and soft self-shadow on the slope.
class PaperCurlLighting extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isBackFace;

  const PaperCurlLighting({
    super.key,
    required this.progress,
    this.isBackFace = false,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01 || progress >= 0.99) {
      return const SizedBox.shrink();
    }

    final curlIntensity = math.sin(progress * math.pi);
    final darkAlpha = (70 * curlIntensity).toInt().clamp(0, 255);
    final highlightAlpha = (45 * curlIntensity).toInt().clamp(0, 255);

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isBackFace
                ? [
                    Colors.black.withAlpha((darkAlpha * 0.7).toInt()),
                    Colors.white.withAlpha(highlightAlpha),
                    Colors.transparent,
                  ]
                : [
                    Colors.transparent,
                    Colors.white.withAlpha(highlightAlpha),
                    Colors.black.withAlpha(darkAlpha),
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Ambient page perimeter drop shadow onto the desk surface
class BookDropShadow extends StatelessWidget {
  final Widget child;

  const BookDropShadow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          // Ambient soft spread shadow
          BoxShadow(
            color: const Color(0xFF13192B).withAlpha(110),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
          // Crisp contact edge shadow
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
