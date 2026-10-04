import 'package:flutter/material.dart';

/// Provides the physical book casing, multi-layer page stack thickness edges,
/// central curved spine crease shadow, and silk bookmark ribbon.
class BookSpreadFrame extends StatelessWidget {
  final Widget child;
  final bool isDualSpread;
  final bool isLeftPage; // In single-page mode: is spine on left or right?
  final Color paperColor;
  final Color coverColor;

  const BookSpreadFrame({
    super.key,
    required this.child,
    this.isDualSpread = false,
    this.isLeftPage = true,
    this.paperColor = const Color(0xFFFAF7EE),
    this.coverColor = const Color(0xFF1E140C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        // Hardcover book casing shadow on the desk
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Hardcover book backing (slightly larger than pages)
          Container(
            decoration: BoxDecoration(
              color: coverColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF382315), width: 2.0),
            ),
          ),

          // 2. Book paper block with page stack edges on outer borders
          Positioned.fill(
            top: 4,
            bottom: 4,
            left: 4,
            right: 4,
            child: CustomPaint(
              painter: _BookPageStackPainter(
                isDualSpread: isDualSpread,
                isLeftPage: isLeftPage,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: paperColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      // Page content
                      Positioned.fill(child: child),

                      // Central Spine Shadow (Curved Gutter)
                      if (isDualSpread)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Row(
                              children: [
                                const Spacer(),
                                Container(
                                  width: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withAlpha(55),
                                        Colors.black.withAlpha(95),
                                        Colors.black.withAlpha(55),
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
                        )
                      else
                        // Single page mode spine shadow along the hinge edge
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: isLeftPage ? null : 0,
                          right: isLeftPage ? 0 : null,
                          child: IgnorePointer(
                            child: Container(
                              width: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: isLeftPage
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  end: isLeftPage
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Silk bookmark ribbon extending from the top center spine
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: isDualSpread
                  ? Alignment.topCenter
                  : (isLeftPage ? Alignment.topRight : Alignment.topLeft),
              child: CustomPaint(
                size: const Size(18, 38),
                painter: _BookmarkRibbonPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the layered edge lines of physical paper pages stacked together
class _BookPageStackPainter extends CustomPainter {
  final bool isDualSpread;
  final bool isLeftPage;

  _BookPageStackPainter({required this.isDualSpread, required this.isLeftPage});

  @override
  void paint(Canvas canvas, Size size) {
    final pageLinePaint = Paint()
      ..color = const Color(0xFFDED6C4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final shadowEdgePaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw page stack on left edge if dual spread or if page is right-hinged
    if (isDualSpread || !isLeftPage) {
      for (double x = 0; x <= 4; x += 1.2) {
        canvas.drawLine(
          Offset(x, 6),
          Offset(x, size.height - 6),
          pageLinePaint,
        );
      }
      canvas.drawLine(
        const Offset(4.5, 6),
        Offset(4.5, size.height - 6),
        shadowEdgePaint,
      );
    }

    // Draw page stack on right edge if dual spread or if page is left-hinged
    if (isDualSpread || isLeftPage) {
      for (double x = size.width; x >= size.width - 4; x -= 1.2) {
        canvas.drawLine(
          Offset(x, 6),
          Offset(x, size.height - 6),
          pageLinePaint,
        );
      }
      canvas.drawLine(
        Offset(size.width - 4.5, 6),
        Offset(size.width - 4.5, size.height - 6),
        shadowEdgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints a rich crimson silk bookmark ribbon with a swallowtail notch
class _BookmarkRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ribbonPaint = Paint()
      ..color = const Color(0xFF9E2A2B)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 7)
      ..lineTo(0, size.height)
      ..close();

    // Shadow
    canvas.drawPath(path.shift(const Offset(1, 2)), shadowPaint);
    // Ribbon
    canvas.drawPath(path, ribbonPaint);

    // Subtle golden thread border on ribbon
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37).withAlpha(160)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
