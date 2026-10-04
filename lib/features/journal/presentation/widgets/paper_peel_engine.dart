import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'journal_page.dart';
import 'journal_page_spread.dart';
import 'page_shadow.dart';
import 'page_turn_controller.dart';

/// Authentic Physical Paper Peeling & Page Curl Engine.
/// Replaces rigid card swiping with true flexible paper physics:
/// - Real-time curling cylinder geometry with dynamic crease line
/// - Under-peel page reveal underneath the lifting paper
/// - Curled flap rendering the underside/backface of the peeling sheet
/// - Specular ridge sheen and dynamic cast drop shadow on revealed paper
/// - Interactive touch peel: touching or dragging the page curls it immediately
class PaperPeelPageTurn extends StatefulWidget {
  final List<JournalPageSpread> spreads;
  final PageTurnController controller;
  final Color paperColor;
  final ValueChanged<int>? onSpreadChanged;

  const PaperPeelPageTurn({
    super.key,
    required this.spreads,
    required this.controller,
    this.paperColor = const Color(0xFFFAF7EE),
    this.onSpreadChanged,
  });

  @override
  State<PaperPeelPageTurn> createState() => _PaperPeelPageTurnState();
}

class _PaperPeelPageTurnState extends State<PaperPeelPageTurn>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    widget.controller.attachAnimationController(_animController);
    widget.controller.setTotalSpreads(widget.spreads.length);
  }

  @override
  void didUpdateWidget(PaperPeelPageTurn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.detachAnimationController();
      widget.controller.attachAnimationController(_animController);
    }
    widget.controller.setTotalSpreads(widget.spreads.length);
  }

  @override
  void dispose() {
    widget.controller.detachAnimationController();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spreads.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentIdx = widget.controller.currentSpreadIndex;
        final progress = widget.controller.dragProgress;
        final isTurning = progress > 0.001;
        final isForward = widget.controller.isTurningForward;

        final currentSpread =
            widget.spreads[currentIdx.clamp(0, widget.spreads.length - 1)];

        return LayoutBuilder(
          builder: (context, constraints) {
            final halfWidth = constraints.maxWidth / 2;
            final fullHeight = constraints.maxHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Touching the page immediately changes to the next/previous page via authentic peel
              onTapUp: (details) {
                if (widget.controller.isAnimating || widget.controller.isDragging) {
                  return;
                }
                final localX = details.localPosition.dx;
                if (localX >= halfWidth) {
                  if (widget.controller.canTurnForward) {
                    widget.controller.nextPage();
                  }
                } else {
                  if (widget.controller.canTurnBackward) {
                    widget.controller.previousPage();
                  }
                }
              },
              onHorizontalDragStart: (details) {
                final localX = details.localPosition.dx;
                final forward = localX >= halfWidth;
                widget.controller.handleDragStart(forward: forward);
              },
              onHorizontalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0.0;
                final normalizedDelta = delta / halfWidth;
                widget.controller.handleDragUpdate(normalizedDelta);
              },
              onHorizontalDragEnd: (details) {
                widget.controller.completeDrag(
                  velocity: details.primaryVelocity ?? 0.0,
                );
              },
              onHorizontalDragCancel: () {
                widget.controller.cancelDrag();
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Resting Base Spread when no peel is active
                  if (!isTurning)
                    Positioned.fill(child: currentSpread)
                  else if (isForward)
                    _buildForwardPeelSpread(
                      currentIdx: currentIdx,
                      progress: progress,
                      pageWidth: halfWidth,
                      pageHeight: fullHeight,
                    )
                  else
                    _buildBackwardPeelSpread(
                      currentIdx: currentIdx,
                      progress: progress,
                      pageWidth: halfWidth,
                      pageHeight: fullHeight,
                    ),

                  // 2. Spine Crease & Shadow
                  Positioned(
                    left: halfWidth - 18,
                    top: 0,
                    bottom: 0,
                    width: 36,
                    child: const SpineShadow(),
                  ),

                  // 3. Tactile Corner Dog-Ear Peel Hints when resting
                  if (!isTurning) ...[
                    // Right page corner peel hint (touch here to peel forward)
                    if (widget.controller.canTurnForward)
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: _buildDogEarPeelAffordance(isRight: true),
                      ),
                    // Left page corner peel hint (touch here to peel backward)
                    if (widget.controller.canTurnBackward)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: _buildDogEarPeelAffordance(isRight: false),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Forward Peel: Right page curls & peels inward toward the spine,
  /// revealing the upcoming right page beneath it.
  Widget _buildForwardPeelSpread({
    required int currentIdx,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    final nextIdx = (currentIdx + 1).clamp(0, widget.spreads.length - 1);
    final currentLeft = widget.spreads[currentIdx].leftContent;
    final currentRight = widget.spreads[currentIdx].rightContent;
    final nextLeft = widget.spreads[nextIdx].leftContent;
    final nextRight = widget.spreads[nextIdx].rightContent;

    // Phase 1 (0.0 to 0.5): Peeling right page inward from right edge
    // Phase 2 (0.5 to 1.0): Curled page landing & uncurling onto the left side
    final isFirstHalf = progress <= 0.5;

    return Stack(
      children: [
        // Left Page Base
        Positioned(
          left: 0,
          top: 0,
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: isFirstHalf ? currentLeft : nextLeft,
            isLeftPage: true,
            paperColor: widget.paperColor,
          ),
        ),

        // Right Page Base (Revealed Next Page underneath)
        Positioned(
          left: pageWidth,
          top: 0,
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: nextRight,
            isLeftPage: false,
            paperColor: widget.paperColor,
          ),
        ),

        // Active Peeling Stage
        if (isFirstHalf)
          _buildRightPagePeelingInward(
            content: currentRight,
            backContent: nextLeft,
            progress: progress * 2.0, // 0.0 -> 1.0
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          )
        else
          _buildLeftPageLandingUncurl(
            content: nextLeft,
            progress: (progress - 0.5) * 2.0, // 0.0 -> 1.0
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          ),
      ],
    );
  }

  /// Backward Peel: Left page curls & peels backward toward the spine,
  /// revealing the previous left page beneath it.
  Widget _buildBackwardPeelSpread({
    required int currentIdx,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    final prevIdx = (currentIdx - 1).clamp(0, widget.spreads.length - 1);
    final currentLeft = widget.spreads[currentIdx].leftContent;
    final currentRight = widget.spreads[currentIdx].rightContent;
    final prevLeft = widget.spreads[prevIdx].leftContent;
    final prevRight = widget.spreads[prevIdx].rightContent;

    final isFirstHalf = progress <= 0.5;

    return Stack(
      children: [
        // Left Page Base (Revealed Previous Left Page underneath)
        Positioned(
          left: 0,
          top: 0,
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: prevLeft,
            isLeftPage: true,
            paperColor: widget.paperColor,
          ),
        ),

        // Right Page Base
        Positioned(
          left: pageWidth,
          top: 0,
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: isFirstHalf ? currentRight : prevRight,
            isLeftPage: false,
            paperColor: widget.paperColor,
          ),
        ),

        // Active Backward Peeling Stage
        if (isFirstHalf)
          _buildLeftPagePeelingBackward(
            content: currentLeft,
            backContent: prevRight,
            progress: progress * 2.0, // 0.0 -> 1.0
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          )
        else
          _buildRightPageLandingUncurl(
            content: prevRight,
            progress: (progress - 0.5) * 2.0, // 0.0 -> 1.0
            pageWidth: pageWidth,
            pageHeight: pageHeight,
          ),
      ],
    );
  }

  /// Right page curling inward from outer right edge towards spine.
  Widget _buildRightPagePeelingInward({
    required JournalPageContent content,
    required JournalPageContent backContent,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    // Crease position moves from pageWidth down to 0
    final creaseX = pageWidth * (1.0 - progress);
    // Curl cylinder width
    final curlWidth =
        (pageWidth * progress * 0.45 + 18.0 * math.sin(progress * math.pi))
            .clamp(12.0, pageWidth);

    return Positioned(
      left: pageWidth,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Under-peel dynamic cast shadow falling onto revealed page underneath
          Positioned(
            left: creaseX,
            top: 0,
            width: math.min(curlWidth * 1.4, pageWidth - creaseX),
            height: pageHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha((110 * math.sin(progress * math.pi)).toInt()),
                      Colors.black.withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Unpeeled Flat Portion of the Top Page (from 0 to creaseX)
          Positioned(
            left: 0,
            top: 0,
            width: creaseX.clamp(0.0, pageWidth),
            height: pageHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: pageWidth,
                maxHeight: pageHeight,
                child: JournalPageWidget(
                  content: content,
                  isLeftPage: false,
                  paperColor: widget.paperColor,
                ),
              ),
            ),
          ),

          // 3. The Curled Peeling Flap (folds over towards the left of the crease)
          if (creaseX > 0 && curlWidth > 2)
            Positioned(
              left: (creaseX - curlWidth).clamp(-pageWidth * 0.2, pageWidth),
              top: 0,
              width: curlWidth,
              height: pageHeight,
              child: _buildCurledFlapSurface(
                curlWidth: curlWidth,
                progress: progress,
                isRightSide: true,
              ),
            ),

          // 4. Highlight line right along the crease fold
          Positioned(
            left: creaseX - 2,
            top: 0,
            bottom: 0,
            width: 4,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(160),
                      Colors.white.withAlpha(40),
                      Colors.transparent,
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

  /// Left page uncurling and settling flat onto the left side as turn completes.
  Widget _buildLeftPageLandingUncurl({
    required JournalPageContent content,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    // Landing progress moves uncurled edge from right (spine) to left
    final uncurlX = pageWidth * progress;
    final curlWidth =
        (pageWidth * (1.0 - progress) * 0.4 + 14.0 * math.sin((1.0 - progress) * math.pi))
            .clamp(8.0, pageWidth);

    return Positioned(
      left: 0,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: Stack(
        children: [
          // Flat portion settled onto left page
          Positioned(
            right: 0,
            top: 0,
            width: uncurlX.clamp(0.0, pageWidth),
            height: pageHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerRight,
                maxWidth: pageWidth,
                maxHeight: pageHeight,
                child: JournalPageWidget(
                  content: content,
                  isLeftPage: true,
                  paperColor: widget.paperColor,
                ),
              ),
            ),
          ),

          // Remaining landing curl edge
          if (progress < 0.98)
            Positioned(
              right: uncurlX - 4,
              top: 0,
              width: curlWidth,
              height: pageHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.white.withAlpha(140),
                      Colors.black.withAlpha(50),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Left page curling backward from outer left edge towards spine.
  Widget _buildLeftPagePeelingBackward({
    required JournalPageContent content,
    required JournalPageContent backContent,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    final creaseX = pageWidth * progress;
    final curlWidth =
        (pageWidth * progress * 0.45 + 18.0 * math.sin(progress * math.pi))
            .clamp(12.0, pageWidth);

    return Positioned(
      left: 0,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Under-peel cast shadow falling onto revealed left page underneath
          Positioned(
            right: pageWidth - creaseX,
            top: 0,
            width: math.min(curlWidth * 1.4, creaseX),
            height: pageHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withAlpha((110 * math.sin(progress * math.pi)).toInt()),
                      Colors.black.withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Unpeeled Flat Portion of the Left Page (from creaseX to pageWidth)
          Positioned(
            left: creaseX,
            top: 0,
            width: (pageWidth - creaseX).clamp(0.0, pageWidth),
            height: pageHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerRight,
                maxWidth: pageWidth,
                maxHeight: pageHeight,
                child: JournalPageWidget(
                  content: content,
                  isLeftPage: true,
                  paperColor: widget.paperColor,
                ),
              ),
            ),
          ),

          // 3. The Curled Peeling Flap
          if (curlWidth > 2)
            Positioned(
              left: creaseX,
              top: 0,
              width: curlWidth,
              height: pageHeight,
              child: _buildCurledFlapSurface(
                curlWidth: curlWidth,
                progress: progress,
                isRightSide: false,
              ),
            ),
        ],
      ),
    );
  }

  /// Right page landing and uncurling flat onto the right side.
  Widget _buildRightPageLandingUncurl({
    required JournalPageContent content,
    required double progress,
    required double pageWidth,
    required double pageHeight,
  }) {
    final uncurlX = pageWidth * progress;
    final curlWidth =
        (pageWidth * (1.0 - progress) * 0.4 + 14.0 * math.sin((1.0 - progress) * math.pi))
            .clamp(8.0, pageWidth);

    return Positioned(
      left: pageWidth,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: uncurlX.clamp(0.0, pageWidth),
            height: pageHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: pageWidth,
                maxHeight: pageHeight,
                child: JournalPageWidget(
                  content: content,
                  isLeftPage: false,
                  paperColor: widget.paperColor,
                ),
              ),
            ),
          ),
          if (progress < 0.98)
            Positioned(
              left: uncurlX - 4,
              top: 0,
              width: curlWidth,
              height: pageHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(140),
                      Colors.black.withAlpha(50),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders the authentic tactile 3D curved underside cylinder of the peeling flap
  Widget _buildCurledFlapSurface({
    required double curlWidth,
    required double progress,
    required bool isRightSide,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.paperColor,
        borderRadius: BorderRadius.horizontal(
          left: isRightSide ? const Radius.circular(8) : Radius.zero,
          right: !isRightSide ? const Radius.circular(8) : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 10,
            offset: Offset(isRightSide ? -4 : 4, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Specular light sheen on the cylindrical apex of the paper curl
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
                  end: isRightSide ? Alignment.centerLeft : Alignment.centerRight,
                  colors: [
                    Colors.black.withAlpha(40),
                    Colors.white.withAlpha(140), // Specular light reflection on paper roll
                    Colors.black.withAlpha(30),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Subtle watermark texture on the underside of turning paper
          Center(
            child: Icon(
              Icons.auto_stories,
              size: 16,
              color: Colors.black.withAlpha(15),
            ),
          ),
        ],
      ),
    );
  }

  /// Tactile Dog-Ear Curled Corner Affordance at resting state:
  /// Gently curls to invite the user to touch and peel the page.
  Widget _buildDogEarPeelAffordance({required bool isRight}) {
    return IgnorePointer(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.paperColor,
          borderRadius: BorderRadius.only(
            topLeft: isRight ? const Radius.circular(16) : Radius.zero,
            topRight: !isRight ? const Radius.circular(16) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: Offset(isRight ? -2 : 2, -2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isRight ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
            size: 10,
            color: const Color(0xFFC5A059),
          ),
        ),
      ),
    );
  }
}
