import 'package:flutter/material.dart';

import 'journal_page.dart';
import 'page_shadow.dart';

/// A complete two-page journal spread (Left Page + Center Spine + Right Page)
/// resting open on the desk surface.
class JournalPageSpread extends StatelessWidget {
  final JournalPageContent leftContent;
  final JournalPageContent rightContent;
  final Color paperColor;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final bool showSpineRings;

  const JournalPageSpread({
    super.key,
    required this.leftContent,
    required this.rightContent,
    this.paperColor = const Color(0xFFFAF7EE),
    this.onTapLeft,
    this.onTapRight,
    this.showSpineRings = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;

        return Stack(
          children: [
            // Left & Right Pages side-by-side
            Row(
              children: [
                // Left Page
                SizedBox(
                  width: halfWidth,
                  height: constraints.maxHeight,
                  child: JournalPageWidget(
                    content: leftContent,
                    isLeftPage: true,
                    paperColor: paperColor,
                    onTap: onTapLeft,
                  ),
                ),

                // Right Page
                SizedBox(
                  width: halfWidth,
                  height: constraints.maxHeight,
                  child: JournalPageWidget(
                    content: rightContent,
                    isLeftPage: false,
                    paperColor: paperColor,
                    onTap: onTapRight,
                  ),
                ),
              ],
            ),

            // Center Spine Crease & Shadow
            Positioned(
              left: halfWidth - 18,
              top: 0,
              bottom: 0,
              width: 36,
              child: const SpineShadow(),
            ),

            // Corner page turn hints / affordances
            if (onTapLeft != null)
              Positioned(
                top: 6,
                left: 8,
                child: _buildCornerTurnAffordance(isLeft: true),
              ),

            if (onTapRight != null)
              Positioned(
                top: 6,
                right: 8,
                child: _buildCornerTurnAffordance(isLeft: false),
              ),
          ],
        );
      },
    );
  }

  /// Subtle dog-eared corner fold affordance hinting to user that paper can be turned
  Widget _buildCornerTurnAffordance({required bool isLeft}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(4) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(4) : Radius.zero,
        ),
      ),
      child: Icon(
        isLeft ? Icons.chevron_left : Icons.chevron_right,
        size: 10,
        color: Colors.black45,
      ),
    );
  }
}
