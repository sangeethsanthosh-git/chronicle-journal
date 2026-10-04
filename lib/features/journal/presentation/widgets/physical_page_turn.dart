import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'journal_page.dart';
import 'journal_page_spread.dart';
import 'page_shadow.dart';
import 'page_turn_controller.dart';

/// The Physical 3D Page Turn Engine.
/// Implements authentic paper turning around the vertical spine:
/// - 3D Matrix4 perspective transformation with setEntry(3, 2, 0.001)
/// - Interactive finger dragging: user can partially drag, hold, and release
/// - Smooth spring completion past drag threshold
/// - Front and back face rendering during rotation (crossing 90 degrees)
/// - Dynamic cast shadows and paper curl lighting
/// - Reduced-motion accessibility fallback
class PhysicalPageTurn extends StatefulWidget {
  final List<JournalPageSpread> spreads;
  final PageTurnController controller;
  final Color paperColor;
  final ValueChanged<int>? onSpreadChanged;

  const PhysicalPageTurn({
    super.key,
    required this.spreads,
    required this.controller,
    this.paperColor = const Color(0xFFFAF7EE),
    this.onSpreadChanged,
  });

  @override
  State<PhysicalPageTurn> createState() => _PhysicalPageTurnState();
}

class _PhysicalPageTurnState extends State<PhysicalPageTurn>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    widget.controller.attachAnimationController(_animController);
    widget.controller.setTotalSpreads(widget.spreads.length);
  }

  @override
  void didUpdateWidget(PhysicalPageTurn oldWidget) {
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
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentIdx = widget.controller.currentSpreadIndex;
        final progress = widget.controller.dragProgress;
        final isTurning = progress > 0.0;
        final isForward = widget.controller.isTurningForward;

        if (widget.spreads.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentSpread =
            widget.spreads[currentIdx.clamp(0, widget.spreads.length - 1)];

        // Simplified reduced-motion view
        if (disableAnimations) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0.0;
              if (velocity < -200) {
                widget.controller.nextPage();
              } else if (velocity > 200) {
                widget.controller.previousPage();
              }
            },
            child: currentSpread,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = constraints.maxWidth / 2;
            final pageHeight = constraints.maxHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                final localX = details.localPosition.dx;
                // If touch on right half -> turn forward; if on left half -> turn backward
                final forward = localX >= pageWidth;
                widget.controller.handleDragStart(forward: forward);
              },
              onHorizontalDragUpdate: (details) {
                final delta = details.primaryDelta ?? 0.0;
                final normalizedDelta = delta / pageWidth;
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
                children: [
                  // 1. Base Spread (underneath the turning page)
                  if (!isTurning)
                    Positioned.fill(child: currentSpread)
                  else if (isForward)
                    // Turning Forward:
                    // Left side is current left page; Right side is NEXT right page!
                    _buildForwardUnderneathSpread(
                      currentIdx,
                      pageWidth,
                      pageHeight,
                    )
                  else
                    // Turning Backward:
                    // Left side is PREVIOUS left page; Right side is current right page!
                    _buildBackwardUnderneathSpread(
                      currentIdx,
                      pageWidth,
                      pageHeight,
                    ),

                  // 2. Under-page dynamic cast shadow
                  if (isTurning)
                    Positioned(
                      left: isForward ? pageWidth : 0,
                      top: 0,
                      width: pageWidth,
                      height: pageHeight,
                      child: UnderPageCastShadow(
                        progress: progress,
                        isRightSide: isForward,
                      ),
                    ),

                  // 3. The 3D Rotating Page
                  if (isTurning)
                    isForward
                        ? _buildForwardRotatingPage(
                            currentIdx,
                            progress,
                            pageWidth,
                            pageHeight,
                          )
                        : _buildBackwardRotatingPage(
                            currentIdx,
                            progress,
                            pageWidth,
                            pageHeight,
                          ),

                  // 4. Center Spine crease shadow
                  Positioned(
                    left: pageWidth - 18,
                    top: 0,
                    bottom: 0,
                    width: 36,
                    child: const SpineShadow(),
                  ),

                  // 5. Margin tap targets for easy flipping
                  if (!isTurning) ...[
                    // Left margin tap: previous page
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 44,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.controller.canTurnBackward
                            ? () => widget.controller.previousPage()
                            : null,
                      ),
                    ),
                    // Right margin tap: next page
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 44,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.controller.canTurnForward
                            ? () => widget.controller.nextPage()
                            : null,
                      ),
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

  /// When turning forward:
  /// Left side: current spread's left page
  /// Right side: next spread's right page (revealed underneath)
  Widget _buildForwardUnderneathSpread(
    int currentIdx,
    double pageWidth,
    double pageHeight,
  ) {
    final nextIdx = (currentIdx + 1).clamp(0, widget.spreads.length - 1);
    final currentLeft = widget.spreads[currentIdx].leftContent;
    final nextRight = widget.spreads[nextIdx].rightContent;

    return Row(
      children: [
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: currentLeft,
            isLeftPage: true,
            paperColor: widget.paperColor,
          ),
        ),
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: nextRight,
            isLeftPage: false,
            paperColor: widget.paperColor,
          ),
        ),
      ],
    );
  }

  /// When turning backward:
  /// Left side: previous spread's left page (revealed underneath)
  /// Right side: current spread's right page
  Widget _buildBackwardUnderneathSpread(
    int currentIdx,
    double pageWidth,
    double pageHeight,
  ) {
    final prevIdx = (currentIdx - 1).clamp(0, widget.spreads.length - 1);
    final prevLeft = widget.spreads[prevIdx].leftContent;
    final currentRight = widget.spreads[currentIdx].rightContent;

    return Row(
      children: [
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: prevLeft,
            isLeftPage: true,
            paperColor: widget.paperColor,
          ),
        ),
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: JournalPageWidget(
            content: currentRight,
            isLeftPage: false,
            paperColor: widget.paperColor,
          ),
        ),
      ],
    );
  }

  /// 3D Forward Rotating Page (Right Page lifting and rotating toward Left).
  /// Rotates around its left edge (spine) from 0 to -pi radians.
  Widget _buildForwardRotatingPage(
    int currentIdx,
    double progress,
    double pageWidth,
    double pageHeight,
  ) {
    final angle = -progress * math.pi;
    final isFrontFace = progress <= 0.5;

    final turningRightContent = widget.spreads[currentIdx].rightContent;
    final nextIdx = (currentIdx + 1).clamp(0, widget.spreads.length - 1);
    final incomingLeftContent = widget.spreads[nextIdx].leftContent;

    // 3D Perspective Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective camera depth
      ..rotateY(angle);

    return Positioned(
      left: pageWidth,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: RepaintBoundary(
        child: Transform(
          alignment: Alignment.centerLeft, // Rotates around the spine!
          transform: matrix,
          child: Stack(
            children: [
              // If angle <= 90 deg, show front face.
              // If angle > 90 deg, show back face (flipped horizontally to be readable).
              if (isFrontFace)
                JournalPageWidget(
                  content: turningRightContent,
                  isLeftPage: false,
                  paperColor: widget.paperColor,
                )
              else
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: JournalPageWidget(
                    content: incomingLeftContent,
                    isLeftPage: true,
                    paperColor: widget.paperColor,
                  ),
                ),

              // Dynamic paper curl specular lighting & shadow
              Positioned.fill(
                child: PaperCurlLighting(
                  progress: progress,
                  isBackFace: !isFrontFace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3D Backward Rotating Page (Left Page lifting and rotating toward Right).
  /// Rotates around its right edge (spine) from 0 to pi radians.
  Widget _buildBackwardRotatingPage(
    int currentIdx,
    double progress,
    double pageWidth,
    double pageHeight,
  ) {
    final angle = progress * math.pi;
    final isFrontFace = progress <= 0.5;

    final turningLeftContent = widget.spreads[currentIdx].leftContent;
    final prevIdx = (currentIdx - 1).clamp(0, widget.spreads.length - 1);
    final incomingRightContent = widget.spreads[prevIdx].rightContent;

    // 3D Perspective Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle);

    return Positioned(
      left: 0,
      top: 0,
      width: pageWidth,
      height: pageHeight,
      child: RepaintBoundary(
        child: Transform(
          alignment: Alignment.centerRight, // Rotates around spine!
          transform: matrix,
          child: Stack(
            children: [
              if (isFrontFace)
                JournalPageWidget(
                  content: turningLeftContent,
                  isLeftPage: true,
                  paperColor: widget.paperColor,
                )
              else
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: JournalPageWidget(
                    content: incomingRightContent,
                    isLeftPage: false,
                    paperColor: widget.paperColor,
                  ),
                ),

              Positioned.fill(
                child: PaperCurlLighting(
                  progress: progress,
                  isBackFace: !isFrontFace,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
