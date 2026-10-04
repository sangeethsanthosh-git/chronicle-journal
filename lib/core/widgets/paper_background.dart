import 'package:flutter/material.dart';
import '../../domain/models/paper_style.dart';
import '../theme/app_colors.dart';

class PaperBackground extends StatelessWidget {
  final Widget child;
  final PaperStyle paperStyle;
  final Color? backgroundColor;

  const PaperBackground({
    super.key,
    required this.child,
    this.paperStyle = PaperStyle.plain,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark
            ? AppColors.paperBackgroundDark
            : AppColors.paperBackgroundLight);

    if (paperStyle == PaperStyle.plain) {
      return Container(color: bgColor, child: child);
    }

    return Container(
      color: bgColor,
      child: CustomPaint(
        painter: _PaperTexturePainter(paperStyle: paperStyle, isDark: isDark),
        child: child,
      ),
    );
  }
}

class _PaperTexturePainter extends CustomPainter {
  final PaperStyle paperStyle;
  final bool isDark;

  _PaperTexturePainter({required this.paperStyle, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    switch (paperStyle) {
      case PaperStyle.ruled:
        _drawRuledLines(canvas, size);
        break;
      case PaperStyle.grid:
        _drawGrid(canvas, size);
        break;
      case PaperStyle.vintage:
        _drawVintageTexture(canvas, size);
        break;
      case PaperStyle.plain:
        break;
    }
  }

  void _drawRuledLines(Canvas canvas, Size size) {
    const lineHeight = 28.0;
    final linePaint = Paint()
      ..color = isDark
          ? AppColors.ruledLineColorDark
          : AppColors.ruledLineColorLight
      ..strokeWidth = 1.0;

    for (double y = 40.0; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Left vertical margin line
    final marginPaint = Paint()
      ..color = isDark
          ? AppColors.ruledMarginColorDark
          : AppColors.ruledMarginColorLight
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(48, 0), Offset(48, size.height), marginPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    const spacing = 20.0;
    final dotPaint = Paint()
      ..color = isDark
          ? AppColors.gridDotColorDark
          : AppColors.gridDotColorLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  void _drawVintageTexture(Canvas canvas, Size size) {
    // Subtle sepia edge vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          (isDark ? Colors.black : const Color(0xFFC7B198)).withAlpha(
            isDark ? 80 : 45,
          ),
        ],
        stops: const [0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) {
    return oldDelegate.paperStyle != paperStyle || oldDelegate.isDark != isDark;
  }
}
