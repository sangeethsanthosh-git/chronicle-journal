import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'paperclip_widget.dart';
import 'washi_tape.dart';

class TornPaperCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool pinnedWithPaperclip;
  final bool showTape;

  const TornPaperCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
    this.pinnedWithPaperclip = false,
    this.showTape = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        backgroundColor ??
        (isDark ? AppColors.paperCardDark : AppColors.paperCardLight);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _TornPaperPainter(
            color: color,
            borderColor: isDark
                ? AppColors.paperCardBorderDark
                : AppColors.paperCardBorderLight,
          ),
          child: Container(padding: padding, child: child),
        ),
        if (pinnedWithPaperclip)
          const Positioned(
            top: -12,
            right: 24,
            child: PaperclipWidget(width: 16, height: 40, rotationDegrees: 6),
          ),
        if (showTape)
          const Positioned(
            top: -8,
            left: 20,
            child: WashiTape(width: 50, height: 14, rotationDegrees: -3),
          ),
      ],
    );
  }
}

class _TornPaperPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TornPaperPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const tearFrequency = 14.0;
    const tearAmplitude = 3.0;

    // Top torn edge
    path.moveTo(0, tearAmplitude);
    for (double x = 0; x < size.width; x += tearFrequency) {
      final isUp = ((x / tearFrequency).round() % 2 == 0);
      path.lineTo(x + tearFrequency / 2, isUp ? 0 : tearAmplitude * 2);
    }
    path.lineTo(size.width, tearAmplitude);

    // Right straight edge
    path.lineTo(size.width, size.height - tearAmplitude);

    // Bottom torn edge (right to left)
    for (double x = size.width; x > 0; x -= tearFrequency) {
      final isUp = ((x / tearFrequency).round() % 2 == 0);
      path.lineTo(
        x - tearFrequency / 2,
        size.height - (isUp ? 0 : tearAmplitude * 2),
      );
    }
    path.lineTo(0, size.height - tearAmplitude);

    // Left straight edge back to top
    path.close();

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(1, 3)), shadowPaint);

    // Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle border stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TornPaperPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderColor != borderColor;
  }
}
