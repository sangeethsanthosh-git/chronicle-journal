import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';

/// Renders a single physical illustrated book spine standing on the shelf.
/// Includes 3D rounded spine gradient, embossed foil bands, vertical serif title,
/// subtle individual tilt angle, and floating paper tag pill badge when featured/selected.
class JournalBookSpine extends StatelessWidget {
  final JournalStackItem item;
  final bool isSelected;
  final bool isDimmed;
  final bool showFloatingTag;
  final VoidCallback onTap;

  const JournalBookSpine({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isDimmed,
    this.showFloatingTag = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Respect system reduced-motion preference
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final tilt = reducedMotion ? 0.0 : item.tiltAngle;

    final baseColor = item.spineColor;
    final darkerTone = Color.lerp(baseColor, Colors.black, 0.35)!;
    final highlightTone = Color.lerp(baseColor, Colors.white, 0.28)!;

    return Semantics(
      label: item.semanticLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: isDimmed ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedScale(
            scale: isSelected ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0.0,
                isSelected ? -16.0 : 0.0,
                0.0,
              )..rotateZ(tilt),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // 1. Diagonal soft cast shadow falling behind/below the book
                  Positioned(
                    bottom: -4,
                    left: -8,
                    child: Container(
                      width: item.spineThickness + 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isSelected ? 0.35 : 0.22,
                            ),
                            offset: const Offset(-8, 6),
                            blurRadius: isSelected ? 10 : 6,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Physical Book Body
                  Container(
                    width: item.spineThickness,
                    height: item.spineHeight,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                        bottomLeft: Radius.circular(1),
                        bottomRight: Radius.circular(1),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0.0, 0.18, 0.5, 0.85, 1.0],
                        colors: [
                          darkerTone,
                          baseColor,
                          highlightTone,
                          baseColor,
                          darkerTone,
                        ],
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          offset: const Offset(2, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative horizontal embossed bands
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSpineBand(baseColor, isTop: true),
                              if (item.spineBandCount >= 2)
                                _buildSpineBand(baseColor),
                              if (item.spineBandCount >= 3)
                                _buildSpineBand(baseColor),
                              _buildSpineBand(baseColor, isBottom: true),
                            ],
                          ),
                        ),

                        // Spine Vertical Title & Category Symbol
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Category tiny foil glyph
                                Icon(
                                  item.category.icon,
                                  size: 11,
                                  color: const Color(
                                    0xFFF7E7CE,
                                  ).withValues(alpha: 0.85),
                                ),
                                const SizedBox(height: 6),

                                // Rotated Vertical Title
                                Expanded(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: Text(
                                        item.title.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: item.spineThickness > 32
                                              ? 10
                                              : 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          color: const Color(
                                            0xFFFDFBF7,
                                          ).withValues(alpha: 0.95),
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.4,
                                              ),
                                              offset: const Offset(0.5, 0.5),
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),
                                // Entry count tiny stamp
                                Text(
                                  '${item.entryCount}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: const Color(
                                      0xFFF7E7CE,
                                    ).withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Floating Paper Pill Badge (matches reference image editorial style)
                  if (showFloatingTag || isSelected)
                    Positioned(
                      top: -36,
                      child: _buildFloatingPaperTag(item.title, isSelected),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpineBand(
    Color baseColor, {
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Container(
      margin: EdgeInsets.only(top: isTop ? 14 : 0, bottom: isBottom ? 14 : 0),
      height: 4.5,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.75),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPaperTag(String title, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB58055)
                : const Color(0xFFE2DDD1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF2C2218),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
