import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ring Binder Journal Frame matching reference Image 4:
/// - Slate-blue or deep timber desk surface
/// - Realistic open 3-ring metallic binder mechanism in spine
/// - Punched paper holes on left and right pages
/// - Bottom desk reminder quote bar: "reminder: progress matters more than perfection."
class RingBinderFrame extends StatelessWidget {
  final Widget child;
  final bool isDualSpread;
  final Color deskColor;
  final Color paperColor;
  final String reminderQuote;
  final bool showReminderBar;
  final VoidCallback? onReminderTap;

  const RingBinderFrame({
    super.key,
    required this.child,
    this.isDualSpread = true,
    this.deskColor = const Color(0xFF384756), // Slate blue desk
    this.paperColor = const Color(0xFFFAF7EE),
    this.reminderQuote = 'reminder: progress matters more than perfection.',
    this.showReminderBar = true,
    this.onReminderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: deskColor,
      child: Stack(
        children: [
          // 1. Subtle Desk Texture & Vignette
          Positioned.fill(
            child: CustomPaint(
              painter: _SlateDeskPainter(deskColor: deskColor),
            ),
          ),

          // 2. Open Ring Binder Book Area
          Positioned.fill(
            bottom: showReminderBar ? 56 : 12,
            top: 8,
            left: 10,
            right: 10,
            child: _buildBinderStructure(context),
          ),

          // 3. Desk Reminder Bar (Image 4 bottom quote)
          if (showReminderBar)
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: onReminderTap,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(45),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            reminderQuote,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2621),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBinderStructure(BuildContext context) {
    return Stack(
      children: [
        // Binder Cover Shadow on desk
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(90),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        // Binder Cover Outer Material (Warm charcoal / dark leather rim)
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF25221F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3F3A33), width: 1.5),
            ),
          ),
        ),

        // Paper Block
        Positioned.fill(
          top: 12,
          bottom: 12,
          left: 10,
          right: 10,
          child: Container(
            decoration: BoxDecoration(
              color: paperColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(45),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Page Content
                  Positioned.fill(child: child),

                  // Center Spine Shadow Gutter
                  if (isDualSpread)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Row(
                          children: [
                            const Spacer(),
                            Container(
                              width: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(45),
                                    Colors.black.withAlpha(70),
                                    Colors.black.withAlpha(45),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Center 3-Ring Binder Mechanism (Silver metal plate + 3 rings)
        if (isDualSpread)
          Positioned.fill(
            top: 8,
            bottom: 8,
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 36,
                  child: CustomPaint(
                    size: const Size(36, double.infinity),
                    painter: _ThreeRingBinderPainter(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Paints the slate-blue desk surface with subtle grain and light falloff
class _SlateDeskPainter extends CustomPainter {
  final Color deskColor;

  _SlateDeskPainter({required this.deskColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle radial light vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 1.1,
        colors: [
          deskColor.withAlpha(255),
          Color.lerp(deskColor, Colors.black, 0.28)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );

    // Fine organic slate texture lines
    final texturePaint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double y = 40; y < size.height; y += 60) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 80) {
        final dy = math.sin((x / size.width) * 6 * math.pi + y) * 2.0;
        path.lineTo(x, y + dy);
      }
      canvas.drawPath(path, texturePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SlateDeskPainter oldDelegate) =>
      oldDelegate.deskColor != deskColor;
}

/// Paints the 3-ring binder metal spine mechanism with:
/// - Chrome mounting rail with rivets
/// - 3 metallic binder rings with realistic reflections and punched holes
class _ThreeRingBinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // 1. Silver chrome mounting bar down the spine
    final barRect = Rect.fromLTWH(centerX - 5, 8, 10, size.height - 16);
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8A939C),
          Color(0xFFE2E7EC),
          Color(0xFFB5BDC5),
          Color(0xFF6B727A),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(barRect);

    // Bar drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        barRect.shift(const Offset(1, 2)),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
      barPaint,
    );

    // Mounting rivets at top and bottom of metal bar
    final rivetPaint = Paint()..color = const Color(0xFF4A4E54);
    final rivetHighlight = Paint()..color = Colors.white.withAlpha(200);

    canvas.drawCircle(Offset(centerX, 16), 2.2, rivetPaint);
    canvas.drawCircle(Offset(centerX - 0.5, 15.5), 0.8, rivetHighlight);

    canvas.drawCircle(Offset(centerX, size.height - 16), 2.2, rivetPaint);
    canvas.drawCircle(
      Offset(centerX - 0.5, size.height - 16.5),
      0.8,
      rivetHighlight,
    );

    // 2. The 3 sturdy binder rings (Top, Center, Bottom)
    final ringYPositions = [
      size.height * 0.20,
      size.height * 0.50,
      size.height * 0.80,
    ];

    final holeFill = Paint()..color = const Color(0xFF221F1C);
    final holeRim = Paint()
      ..color = const Color(0xFFB5BDC5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final ringStroke = Paint()
      ..color = const Color(0xFF9EA7B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final ringHighlight = Paint()
      ..color = Colors.white.withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final ringShadow = Paint()
      ..color = Colors.black.withAlpha(75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    for (final ringY in ringYPositions) {
      // Punched holes on left & right paper pages
      const holeDistance = 14.0;
      final leftHole = Offset(centerX - holeDistance, ringY);
      final rightHole = Offset(centerX + holeDistance, ringY);

      canvas.drawCircle(leftHole, 3.2, holeFill);
      canvas.drawCircle(leftHole, 3.2, holeRim);

      canvas.drawCircle(rightHole, 3.2, holeFill);
      canvas.drawCircle(rightHole, 3.2, holeRim);

      // Curved Metallic Binder Ring Arched Over Center
      final ringPath = Path();
      ringPath.moveTo(leftHole.dx, leftHole.dy);
      ringPath.cubicTo(
        centerX - 8,
        ringY - 14,
        centerX + 8,
        ringY - 14,
        rightHole.dx,
        rightHole.dy,
      );

      // Shadow cast onto right page
      canvas.drawPath(ringPath.shift(const Offset(2.5, 3.0)), ringShadow);

      // Main metallic ring
      canvas.drawPath(ringPath, ringStroke);

      // Shiny specular highlight streak on apex of the ring
      final highlightPath = Path();
      highlightPath.moveTo(centerX - 5, ringY - 11.5);
      highlightPath.lineTo(centerX + 5, ringY - 11.5);
      canvas.drawPath(highlightPath, ringHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
