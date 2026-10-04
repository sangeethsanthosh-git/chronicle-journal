import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/desk_theme.dart';

/// Layered illustrated cozy study room environment matching "Rebecca Mock.gif" inspiration:
/// - Multi-pane window with soft sky light
/// - Vintage brass desk lamp with warm amber illumination cone
/// - Bookshelves, potted plant, ceramic tea mug, and desk accessories
/// - Floating subtle dust motes in the light beam
/// - Depth scaling when journal opens/closes
class IllustratedStudyEnvironment extends StatefulWidget {
  final Widget child; // The journal resting on the desk
  final bool isJournalOpen;
  final DeskThemeData deskTheme;
  final VoidCallback? onTapOutside;
  final VoidCallback? onTapBookshelf;

  const IllustratedStudyEnvironment({
    super.key,
    required this.child,
    required this.isJournalOpen,
    required this.deskTheme,
    this.onTapOutside,
    this.onTapBookshelf,
  });

  @override
  State<IllustratedStudyEnvironment> createState() =>
      _IllustratedStudyEnvironmentState();
}

class _IllustratedStudyEnvironmentState
    extends State<IllustratedStudyEnvironment>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Environmental camera zoom: scales slightly down when journal is focused
    final envScale = widget.isJournalOpen ? 0.98 : 1.0;

    return GestureDetector(
      onTap: widget.isJournalOpen ? widget.onTapOutside : null,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: envScale,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Room Background Wall & Window
            CustomPaint(
              painter: _StudyRoomPainter(deskTheme: widget.deskTheme),
            ),

            // 2. Animated Floating Dust Particles in the Lamp Light
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _DustMotesPainter(
                    animationValue: _ambientController.value,
                  ),
                );
              },
            ),

            // 3. Desk Props (Brass lamp, tea mug, potted plant, inkwell)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DeskPropsIllustratedPainter(
                    deskTheme: widget.deskTheme,
                  ),
                ),
              ),
            ),

            // 3b. Interactive Bookshelf Prop on Top Right (Navigates to Journal Stack)
            if (widget.onTapBookshelf != null)
              Positioned(
                top: 15,
                right: 10,
                width: 150,
                height: 80,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.onTapBookshelf,
                    child: Tooltip(
                      message: 'Open Journal Stack',
                      child: Container(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 10,
                                color: Color(0xFFF7E7CE),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'SHELF',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF7E7CE),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Center Desk Area with Journal
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the cozy study room background (wall, bookshelf, and window light)
class _StudyRoomPainter extends CustomPainter {
  final DeskThemeData deskTheme;

  _StudyRoomPainter({required this.deskTheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Wall wallpaper gradient
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [deskTheme.coverColor.withAlpha(240), deskTheme.deskColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);

    // Subtle warm window pane on top left
    final windowRect = Rect.fromLTWH(24, 20, 110, 140);
    final windowGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          const Color(0xFFFFF2D6).withAlpha(140),
          const Color(0xFFC7AF8A).withAlpha(40),
          Colors.transparent,
        ],
      ).createShader(windowRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(8)),
      windowGlow,
    );

    // Window cross frames
    final framePaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(windowRect.left, windowRect.center.dy),
      Offset(windowRect.right, windowRect.center.dy),
      framePaint,
    );
    canvas.drawLine(
      Offset(windowRect.center.dx, windowRect.top),
      Offset(windowRect.center.dx, windowRect.bottom),
      framePaint,
    );

    // Bookshelf horizontal ledge on top right
    final shelfY = 85.0;
    final shelfPaint = Paint()
      ..color = Colors.black.withAlpha(60)
      ..strokeWidth = 4.0;
    canvas.drawLine(
      Offset(size.width - 150, shelfY),
      Offset(size.width - 10, shelfY),
      shelfPaint,
    );

    // Books on the shelf
    final bookColors = [
      const Color(0xFF8B2635),
      const Color(0xFF29382E),
      const Color(0xFFC5A059),
      const Color(0xFF384756),
    ];

    double bookX = size.width - 140;
    for (int i = 0; i < bookColors.length; i++) {
      final bPaint = Paint()..color = bookColors[i];
      final bHeight = 40.0 + (i % 2) * 10;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bookX, shelfY - bHeight, 14, bHeight),
          const Radius.circular(2),
        ),
        bPaint,
      );
      bookX += 18;
    }
  }

  @override
  bool shouldRepaint(covariant _StudyRoomPainter oldDelegate) =>
      oldDelegate.deskTheme != deskTheme;
}

/// Paints realistic illustrated desk accessories
class _DeskPropsIllustratedPainter extends CustomPainter {
  final DeskThemeData deskTheme;

  _DeskPropsIllustratedPainter({required this.deskTheme});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm lamp cone light beam from top-center onto the journal
    final lampConePath = Path();
    lampConePath.moveTo(size.width * 0.5, 0);
    lampConePath.lineTo(size.width * 0.95, size.height);
    lampConePath.lineTo(size.width * 0.05, size.height);
    lampConePath.close();

    final lampGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.8),
        radius: 1.2,
        colors: [
          const Color(0xFFFFECC2).withAlpha(55),
          const Color(0xFFFFDC99).withAlpha(20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(lampConePath, lampGlow);

    // 2. Ceramic Tea Mug (bottom left of desk)
    final mugOffset = Offset(36, size.height - 48);
    final mugPaint = Paint()..color = const Color(0xFFFAF7EE);
    final mugShadow = Paint()..color = Colors.black.withAlpha(50);

    canvas.drawOval(
      Rect.fromCenter(
        center: mugOffset.translate(0, 14),
        width: 28,
        height: 10,
      ),
      mugShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: mugOffset, width: 22, height: 26),
        const Radius.circular(5),
      ),
      mugPaint,
    );

    // Tea inside mug
    final teaPaint = Paint()..color = const Color(0xFF6B4423);
    canvas.drawOval(
      Rect.fromCenter(
        center: mugOffset.translate(0, -10),
        width: 18,
        height: 6,
      ),
      teaPaint,
    );

    // 3. Vintage Brass Pen resting on bottom right
    final penY = size.height - 35;
    final penX = size.width - 55;
    final penPaint = Paint()
      ..color = const Color(0xFFC5A059)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(penX, penY), Offset(penX + 35, penY + 8), penPaint);
  }

  @override
  bool shouldRepaint(covariant _DeskPropsIllustratedPainter oldDelegate) =>
      oldDelegate.deskTheme != deskTheme;
}

/// Floating ambient dust particles dancing in the study lamp beam
class _DustMotesPainter extends CustomPainter {
  final double animationValue;

  _DustMotesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..color = Colors.white.withAlpha(50);

    const int particleCount = 18;
    for (int i = 0; i < particleCount; i++) {
      final seed = (i * 997.0);
      final initialX =
          (math.sin(seed) * 0.5 + 0.5) * (size.width * 0.8) +
          (size.width * 0.1);
      final initialY =
          (math.cos(seed) * 0.5 + 0.5) * (size.height * 0.7) +
          (size.height * 0.15);

      final driftX = math.sin(animationValue * 2 * math.pi + i) * 12.0;
      final driftY = math.cos(animationValue * 2 * math.pi + i * 1.5) * 15.0;

      final radius = 1.0 + (i % 3) * 0.6;
      canvas.drawCircle(
        Offset(initialX + driftX, initialY + driftY),
        radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustMotesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
