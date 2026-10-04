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

/// Realistic stacked paper edges indicating hundreds of bound pages
/// along the outer left and outer right margins of the open physical book.
class StackedPageEdges extends StatelessWidget {
  final bool isLeftEdge;
  final double thickness;
  final Color paperBaseColor;

  const StackedPageEdges({
    super.key,
    required this.isLeftEdge,
    this.thickness = 7.0,
    this.paperBaseColor = const Color(0xFFF7F2E4),
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: thickness,
        decoration: BoxDecoration(
          color: paperBaseColor,
          borderRadius: BorderRadius.horizontal(
            left: isLeftEdge ? const Radius.circular(2) : Radius.zero,
            right: !isLeftEdge ? const Radius.circular(2) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isLeftEdge ? 35 : 45),
              blurRadius: 3,
              offset: Offset(isLeftEdge ? -2 : 2, 0),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _StackedPaperLeavesPainter(
            isLeft: isLeftEdge,
            baseColor: paperBaseColor,
          ),
        ),
      ),
    );
  }
}

class _StackedPaperLeavesPainter extends CustomPainter {
  final bool isLeft;
  final Color baseColor;

  _StackedPaperLeavesPainter({required this.isLeft, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Outer shade gradient
    final gradient = LinearGradient(
      begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      colors: [
        baseColor,
        baseColor.withAlpha(220),
        const Color(0xFFDFD4BD),
        const Color(0xFFC8B89C),
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Fine paper stratification lines simulating individual page layers
    final linePaint = Paint()
      ..color = const Color(0xFF9E8B70).withAlpha(55)
      ..strokeWidth = 0.5;

    final step = isLeft ? 1.4 : 1.4;
    for (double y = 4.0; y < size.height - 4.0; y += step) {
      canvas.drawLine(
        Offset(isLeft ? 0.8 : 0.0, y),
        Offset(isLeft ? size.width : size.width - 0.8, y),
        linePaint,
      );
    }

    // Top and bottom curvature edge shading
    final cornerShade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withAlpha(40),
          Colors.transparent,
          Colors.transparent,
          Colors.black.withAlpha(50),
        ],
        stops: const [0.0, 0.05, 0.95, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, cornerShade);
  }

  @override
  bool shouldRepaint(covariant _StackedPaperLeavesPainter oldDelegate) =>
      oldDelegate.isLeft != isLeft || oldDelegate.baseColor != baseColor;
}

/// Realistic spine gutter depth with central thread depression,
/// woven headband accents, and soft bilateral paper curve shadow.
class SpineGutter extends StatelessWidget {
  final double width;

  const SpineGutter({super.key, this.width = 44.0});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft bilateral gradient spreading outward onto left and right pages
          Container(
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withAlpha(45),
                  Colors.black.withAlpha(18),
                  Colors.transparent,
                  Colors.black.withAlpha(18),
                  Colors.black.withAlpha(45),
                ],
                stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
              ),
            ),
          ),

          // Deep center stitch crease
          Container(
            width: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(75),
                  Colors.black.withAlpha(130),
                  Colors.black.withAlpha(75),
                ],
              ),
            ),
          ),

          // Top woven headband fabric accent
          Positioned(
            top: 0,
            child: Container(
              width: 14,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC5A059),
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // Bottom woven headband fabric accent
          Positioned(
            bottom: 0,
            child: Container(
              width: 14,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC5A059),
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
