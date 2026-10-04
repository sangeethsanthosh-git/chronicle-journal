import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'book_page_content_view.dart';
import 'book_page_data.dart';

/// Implements a realistic 3D physical book page flip animation with perspective,
/// spine anchor pivoting, dynamic shadows, and tactile haptic feedback.
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

    if (widget.isDualSpread) {
      return _buildDualSpreadView();
    }

    return _buildSinglePageFlipView();
  }

  /// Single page view with realistic 3D spine-anchored page-turning animation
  Widget _buildSinglePageFlipView() {
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
              );
            }

            // Off-screen page
            return BookPageContentView(page: page, isLeftPage: index % 2 == 0);
          },
        );
      },
    );
  }

  Widget _build3DTransformPage({
    required BookPageData page,
    required double diff,
    required int index,
  }) {
    final isLeftHinge = index % 2 == 0;
    // Rotation angle around the spine hinge
    // Max rotation is roughly -math.pi / 2.2 (~70-80 degrees)
    final rotationAngle = (-diff * (math.pi / 2.2)).clamp(
      -math.pi / 2,
      math.pi / 2,
    );

    // Realistic perspective matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // Subtle depth perspective
      ..rotateY(rotationAngle);

    // Spine anchor: if left-hinged, rotate around left edge; otherwise right edge
    final transformAlignment = isLeftHinge
        ? Alignment.centerLeft
        : Alignment.centerRight;

    // Shadow opacity scales as page turns upward and away
    final shadowOpacity = (diff.abs() * 0.45).clamp(0.0, 0.45);

    return Transform(
      transform: matrix,
      alignment: transformAlignment,
      child: Stack(
        children: [
          // Underlying page content
          Positioned.fill(
            child: BookPageContentView(page: page, isLeftPage: isLeftHinge),
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
                        Colors.black.withAlpha((shadowOpacity * 110).round()),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Two-page spread view (Left & Right open book pages side by side)
  Widget _buildDualSpreadView() {
    // In dual spread mode, 2 pages are shown per spread
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
            // Left open page
            Expanded(
              child: BookPageContentView(page: leftPage, isLeftPage: true),
            ),

            // Center gutter divider
            Container(width: 1.5, color: const Color(0xFFDCD2C0)),

            // Right open page (or blank facing parchment if odd count)
            Expanded(
              child: rightPage != null
                  ? BookPageContentView(page: rightPage, isLeftPage: false)
                  : Container(
                      color: const Color(0xFFFBF8EE),
                      child: const Center(
                        child: Text(
                          '~ End of Entry ~',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF9E958D),
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
