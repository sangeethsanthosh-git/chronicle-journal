import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'book_page_content_view.dart';
import 'book_page_data.dart';

/// Implements a highly realistic 3D physical book page-turn animation and stage
/// inspired by the AURA Memory Book experience:
/// - 3D perspective stage with dual-page inward angle (rotateY)
/// - Deep ambient oval drop shadow beneath the book stage
/// - Realistic progressive page curl & bend with dynamic specular sheen and under-page shadow
/// - Tactile corner fold affordance on turnable edges
/// - Smooth haptic feedback and responsive dual/single page adaptation
class Book3DPageView extends StatefulWidget {
  final List<BookPageData> pages;
  final PageController controller;
  final ValueChanged<int>? onPageChanged;
  final bool isDualSpread;

  const Book3DPageView({
    super.key,
    required this.pages,
    required this.controller,
    this.onPageChanged,
    this.isDualSpread = false,
  });

  @override
  State<Book3DPageView> createState() => _Book3DPageViewState();
}

class _Book3DPageViewState extends State<Book3DPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  void _onPageSwiped(int index) {
    if (_lastReportedPage != index) {
      _lastReportedPage = index;
      HapticFeedback.lightImpact();
      widget.onPageChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const Center(child: Text('No book pages available.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide =
            widget.isDualSpread ||
            (constraints.maxWidth > 640 && widget.pages.length > 1);

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Ambient Oval Deep Drop Shadow beneath the book (matching AURA CSS line 11344)
            Positioned(
              bottom: 4,
              left: constraints.maxWidth * 0.12,
              right: constraints.maxWidth * 0.12,
              height: 48,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF13192B).withAlpha(140),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. The 3D Book Experience
            Positioned.fill(
              child: isWide
                  ? _buildAuraDualSpreadView(constraints)
                  : _buildAuraSinglePageFlipView(constraints),
            ),
          ],
        );
      },
    );
  }

  /// Single page view with realistic 3D spine-anchored page-curling animation
  Widget _buildAuraSinglePageFlipView(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        double currentPage = 0.0;
        if (widget.controller.hasClients &&
            widget.controller.position.haveDimensions) {
          currentPage = widget.controller.page ?? 0.0;
        } else {
          currentPage = widget.controller.initialPage.toDouble();
        }

        return PageView.builder(
          controller: widget.controller,
          itemCount: widget.pages.length,
          onPageChanged: _onPageSwiped,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final page = widget.pages[index];
            final diff = index - currentPage;

            // Page is currently in view or turning
            if (diff >= -1.0 && diff <= 1.0) {
              return _build3DTransformPage(
                page: page,
                diff: diff,
                index: index,
                constraints: constraints,
              );
            }

            // Off-screen page
            return BookPageContentView(page: page, isLeftPage: index % 2 == 0);
          },
        );
      },
    );
  }

  /// 3D transformed page with physical spine pivot, specular curl sheen, and fold shadows
  Widget _build3DTransformPage({
    required BookPageData page,
    required double diff,
    required int index,
    required BoxConstraints constraints,
  }) {
    final isLeftHinge = index % 2 == 0;

    // Rotation angle around the spine hinge
    // Maximum curl is roughly 75 degrees (-math.pi / 2.3)
    final rotationAngle = (-diff * (math.pi / 2.3)).clamp(
      -math.pi / 2,
      math.pi / 2,
    );

    // Realistic perspective matrix (setEntry(3, 2, 0.0014))
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0014) // Depth perspective
      ..rotateY(rotationAngle);

    // Spine anchor: if left-hinged, rotate around left edge; otherwise right edge
    final transformAlignment = isLeftHinge
        ? Alignment.centerLeft
        : Alignment.centerRight;

    // Under-page shadow intensity
    final shadowOpacity = (diff.abs() * 0.48).clamp(0.0, 0.48);

    return Transform(
      transform: matrix,
      alignment: transformAlignment,
      child: Stack(
        children: [
          // Underlying page content
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: isLeftHinge
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
                right: isLeftHinge
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
              ),
              child: BookPageContentView(page: page, isLeftPage: isLeftHinge),
            ),
          ),

          // Dynamic spine fold shadow during turn
          if (shadowOpacity > 0.01)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isLeftHinge
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      end: isLeftHinge
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      colors: [
                        Colors.black.withAlpha((shadowOpacity * 255).round()),
                        Colors.black.withAlpha((shadowOpacity * 120).round()),
                        Colors.transparent,
                        Colors.white.withAlpha((shadowOpacity * 80).round()),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // Tactile corner fold affordance on bottom corner
          if (diff.abs() < 0.1 && index < widget.pages.length - 1)
            Positioned(
              bottom: 4,
              right: isLeftHinge ? 4 : null,
              left: !isLeftHinge ? 4 : null,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _CornerFoldPainter(isRightCorner: isLeftHinge),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Two-page spread view (matching AURA ASUS v2 memory-book-stage):
  /// - Left Page: border-radius 22px 4px 4px 22px; transform rotateY(4deg)
  /// - Right Page: border-radius 4px 22px 22px 4px; transform rotateY(-4deg)
  /// - Central spine crease gutter shadows
  Widget _buildAuraDualSpreadView(BoxConstraints constraints) {
    final totalSpreads = (widget.pages.length / 2).ceil();

    return PageView.builder(
      controller: widget.controller,
      itemCount: totalSpreads,
      onPageChanged: (spreadIndex) {
        _onPageSwiped(spreadIndex * 2);
      },
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, spreadIndex) {
        final leftIndex = spreadIndex * 2;
        final rightIndex = leftIndex + 1;

        final leftPage = widget.pages[leftIndex];
        final rightPage = rightIndex < widget.pages.length
            ? widget.pages[rightIndex]
            : null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left open page (AURA Memory Book left page)
            Expanded(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateY(0.05), // ~3.0 degrees inward tilt
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(-4, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BookPageContentView(
                            page: leftPage,
                            isLeftPage: true,
                          ),
                        ),
                        // Inner spine shadow gutter (AURA line 11402)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          width: 32,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(45),
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

            // Center spine gutter seam
            Container(width: 2.0, color: const Color(0xFF2C2621).withAlpha(50)),

            // Right open page (AURA Memory Book right page)
            Expanded(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateY(-0.05), // ~-3.0 degrees inward tilt
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(4, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: rightPage != null
                              ? BookPageContentView(
                                  page: rightPage,
                                  isLeftPage: false,
                                )
                              : Container(
                                  color: const Color(0xFFFBF8EE),
                                  child: const Center(
                                    child: Text(
                                      '~ Miora Archive ~',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF453D37),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        // Inner spine shadow gutter (AURA line 11407)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          width: 32,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withAlpha(40),
                                    Colors.transparent,
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
          ],
        );
      },
    );
  }
}

/// Paints a subtle folded page corner triangular crease
class _CornerFoldPainter extends CustomPainter {
  final bool isRightCorner;

  _CornerFoldPainter({required this.isRightCorner});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (isRightCorner) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.close();
    }

    // Shadow underneath fold
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withAlpha(35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Folded parchment triangle
    canvas.drawPath(path, Paint()..color = const Color(0xFFE8DFCC));

    // Crease edge highlight
    final creasePaint = Paint()
      ..color = const Color(0xFFBFAF9B)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    if (isRightCorner) {
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, 0),
        creasePaint,
      );
    } else {
      canvas.drawLine(
        Offset(0, 0),
        Offset(size.width, size.height),
        creasePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CornerFoldPainter oldDelegate) =>
      oldDelegate.isRightCorner != isRightCorner;
}
