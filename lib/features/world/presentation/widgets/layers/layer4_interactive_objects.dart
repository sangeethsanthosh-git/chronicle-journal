import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';

class Layer4InteractiveObjects extends StatelessWidget {
  final bool isLampOn;
  final double plantRustle;
  final double pendulumAngle;
  final double parallaxOffset;
  final VoidCallback onJournalTap;
  final VoidCallback onBookshelfTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onLampTap;
  final VoidCallback onPlantTap;

  const Layer4InteractiveObjects({
    super.key,
    required this.isLampOn,
    this.plantRustle = 0.0,
    this.pendulumAngle = 0.0,
    this.parallaxOffset = 0.0,
    required this.onJournalTap,
    required this.onBookshelfTap,
    required this.onGalleryTap,
    required this.onLampTap,
    required this.onPlantTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          // Scaled Hotspot Bounds
          // 1. Journal on the desk
          final journalRect = Rect.fromCenter(
            center: Offset(
              size.width * 0.46 + parallaxOffset * 28,
              size.height * 0.62,
            ),
            width: 90,
            height: 60,
          );

          // 2. Bookshelf on the right
          final bookshelfRect = Rect.fromLTWH(
            size.width * 0.72 + parallaxOffset * 22,
            size.height * 0.22,
            size.width * 0.26,
            size.height * 0.52,
          );

          // 3. Gallery wall frames
          final galleryRect = Rect.fromCenter(
            center: Offset(
              size.width * 0.50 + parallaxOffset * 16,
              size.height * 0.18,
            ),
            width: 130,
            height: 65,
          );

          // 4. Desk Lamp
          final lampRect = Rect.fromCenter(
            center: Offset(
              size.width * 0.22 + parallaxOffset * 28,
              size.height * 0.48,
            ),
            width: 70,
            height: 90,
          );

          // 5. Potted Plant
          final plantRect = Rect.fromCenter(
            center: Offset(
              size.width * 0.12 + parallaxOffset * 28,
              size.height * 0.56,
            ),
            width: 65,
            height: 75,
          );

          return Stack(
            children: [
              // Custom Painted Objects
              CustomPaint(
                size: Size.infinite,
                painter: _ObjectsPainter(
                  isLampOn: isLampOn,
                  plantRustle: plantRustle,
                  pendulumAngle: pendulumAngle,
                  parallaxOffset: parallaxOffset,
                ),
              ),

              // Interactive Touch Hitboxes
              // Journal Hitbox
              Positioned.fromRect(
                rect: journalRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onJournalTap,
                  child: const _HotspotHighlight(tooltip: 'Open Journal'),
                ),
              ),

              // Bookshelf Hitbox
              Positioned.fromRect(
                rect: bookshelfRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBookshelfTap,
                  child: const _HotspotHighlight(tooltip: 'Memories Bookshelf'),
                ),
              ),

              // Gallery Wall Hitbox
              Positioned.fromRect(
                rect: galleryRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onGalleryTap,
                  child: const _HotspotHighlight(tooltip: 'Memory Gallery'),
                ),
              ),

              // Lamp Hitbox
              Positioned.fromRect(
                rect: lampRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLampTap,
                  child: const _HotspotHighlight(tooltip: 'Toggle Lamp'),
                ),
              ),

              // Plant Hitbox
              Positioned.fromRect(
                rect: plantRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPlantTap,
                  child: const _HotspotHighlight(tooltip: 'Rustle Plant'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HotspotHighlight extends StatelessWidget {
  final String tooltip;
  const _HotspotHighlight({required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        color: Colors.transparent, // Transparent hit area
      ),
    );
  }
}

class _ObjectsPainter extends CustomPainter {
  final bool isLampOn;
  final double plantRustle;
  final double pendulumAngle;
  final double parallaxOffset;

  _ObjectsPainter({
    required this.isLampOn,
    required this.plantRustle,
    required this.pendulumAngle,
    required this.parallaxOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintBookshelfVolumes(canvas, size);
    _paintGalleryWall(canvas, size);
    _paintDeskPlant(canvas, size);
    _paintDeskLamp(canvas, size);
    _paintDeskJournal(canvas, size);
  }

  void _paintBookshelfVolumes(Canvas canvas, Size size) {
    final shelfLeft = size.width * 0.72 + parallaxOffset * 22;
    final shelfWidth = size.width * 0.28;
    final shelfTop = size.height * 0.18;
    final shelfBottom = size.height * 0.78;

    final spineColors = [
      const Color(0xFF6B2D2D), // Crimson leather
      const Color(0xFF2D4B6B), // Navy linen
      const Color(0xFF2D5A38), // Forest green
      const Color(0xFF8B6B23), // Ochre gold
      const Color(0xFF4A3B32), // Dark brown
      const Color(0xFF6B4226), // Saddle leather
    ];

    // Paint books on 3 shelves
    final shelfSlots = [0.38, 0.54, 0.70];
    int colorIdx = 0;

    for (final frac in shelfSlots) {
      final shelfY = shelfTop + (shelfBottom - shelfTop) * frac;
      double bookX = shelfLeft + 12;

      while (bookX < shelfLeft + shelfWidth - 25) {
        final bookWidth = 10.0 + ((bookX * 3) % 8);
        final bookHeight = 36.0 + ((bookX * 7) % 14);
        final bookRect = Rect.fromLTRB(
          bookX,
          shelfY - bookHeight,
          bookX + bookWidth,
          shelfY,
        );

        final bookPaint = Paint()
          ..color = spineColors[colorIdx % spineColors.length];
        canvas.drawRRect(
          RRect.fromRectAndRadius(bookRect, const Radius.circular(2)),
          bookPaint,
        );

        // Gold spine foil line
        final foilPaint = Paint()
          ..color = StudyAtmosphereColors.vintageBrass.withValues(alpha: 0.8)
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(bookX + 2, shelfY - bookHeight + 8),
          Offset(bookX + bookWidth - 2, shelfY - bookHeight + 8),
          foilPaint,
        );

        bookX += bookWidth + 2.5;
        colorIdx++;
      }
    }
  }

  void _paintGalleryWall(Canvas canvas, Size size) {
    final centerX = size.width * 0.50 + parallaxOffset * 16;
    final centerY = size.height * 0.18;

    // Frame 1: Polaroid Memory
    final p1Center = Offset(centerX - 35, centerY);
    canvas.save();
    canvas.translate(p1Center.dx, p1Center.dy);
    canvas.rotate(-0.06);

    // Frame backing & paper
    final frameRect = Rect.fromCenter(
      center: Offset.zero,
      width: 44,
      height: 52,
    );
    final framePaint = Paint()..color = const Color(0xFFFAF6EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(3)),
      framePaint,
    );

    // Inner photo area
    final photoRect = Rect.fromLTWH(-18, -22, 36, 32);
    final photoPaint = Paint()..color = const Color(0xFF7FA1B8);
    canvas.drawRect(photoRect, photoPaint);

    // Washi tape across top
    final tapePaint = Paint()..color = const Color(0xBBDEC69A);
    canvas.drawRect(const Rect.fromLTWH(-12, -26, 24, 7), tapePaint);
    canvas.restore();

    // Frame 2: Wooden Landscape Frame
    final p2Center = Offset(centerX + 32, centerY + 3);
    canvas.save();
    canvas.translate(p2Center.dx, p2Center.dy);
    canvas.rotate(0.04);

    final woodFrameRect = Rect.fromCenter(
      center: Offset.zero,
      width: 52,
      height: 42,
    );
    final woodFramePaint = Paint()..color = const Color(0xFF5A3D28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(woodFrameRect, const Radius.circular(3)),
      woodFramePaint,
    );

    final innerPicRect = Rect.fromCenter(
      center: Offset.zero,
      width: 42,
      height: 32,
    );
    final artPaint = Paint()..color = const Color(0xFFBF8A49);
    canvas.drawRect(innerPicRect, artPaint);
    canvas.restore();
  }

  void _paintDeskPlant(Canvas canvas, Size size) {
    final potX = size.width * 0.14 + parallaxOffset * 28;
    final potY = size.height * 0.58;

    // Terracotta Pot
    final potPath = Path()
      ..moveTo(potX - 18, potY)
      ..lineTo(potX - 12, potY + 28)
      ..lineTo(potX + 12, potY + 28)
      ..lineTo(potX + 18, potY)
      ..close();

    final potPaint = Paint()..color = StudyAtmosphereColors.terracottaPot;
    canvas.drawPath(potPath, potPaint);

    // Pot Rim
    final rimRect = Rect.fromCenter(
      center: Offset(potX, potY),
      width: 40,
      height: 7,
    );
    final rimPaint = Paint()..color = StudyAtmosphereColors.terracottaRim;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, const Radius.circular(3)),
      rimPaint,
    );

    // Ivy Leaves with spring rustle tilt
    canvas.save();
    canvas.translate(potX, potY - 4);
    canvas.rotate(plantRustle * 0.15);

    final leafPaint = Paint()..color = StudyAtmosphereColors.plantLeafDeepGreen;
    final highlightLeaf = Paint()
      ..color = StudyAtmosphereColors.plantLeafHighlight;

    // Cluster of ivy leaves
    for (int i = 0; i < 7; i++) {
      final angle = (i * 0.5) - 1.5;
      final dist = 14.0 + (i % 3) * 6;
      final lx = cos(angle) * dist;
      final ly = sin(angle) * dist - 8;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(lx, ly), width: 14, height: 9),
        (i % 2 == 0) ? leafPaint : highlightLeaf,
      );
    }
    canvas.restore();
  }

  void _paintDeskLamp(Canvas canvas, Size size) {
    final lampX = size.width * 0.22 + parallaxOffset * 28;
    final lampY = size.height * 0.58;

    // Brass Base
    final basePaint = Paint()..color = StudyAtmosphereColors.vintageBrass;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(lampX, lampY), width: 34, height: 10),
      basePaint,
    );

    // Curved Brass Arm
    final armPath = Path()
      ..moveTo(lampX, lampY)
      ..cubicTo(
        lampX - 15,
        lampY - 40,
        lampX + 10,
        lampY - 65,
        lampX + 6,
        lampY - 78,
      );
    final armPaint = Paint()
      ..color = StudyAtmosphereColors.vintageBrass
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(armPath, armPaint);

    // Shade (Banker's Emerald Lamp Shade)
    final shadeCenter = Offset(lampX + 6, lampY - 78);
    final shadeRect = Rect.fromCenter(
      center: shadeCenter,
      width: 42,
      height: 20,
    );
    final shadePaint = Paint()
      ..color = isLampOn ? const Color(0xFF2C6B38) : const Color(0xFF1B3D22);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        shadeRect,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      shadePaint,
    );

    // Lamp Bulb Glow if ON
    if (isLampOn) {
      final bulbPaint = Paint()..color = StudyAtmosphereColors.lampLightCore;
      canvas.drawCircle(
        Offset(shadeCenter.dx, shadeCenter.dy + 8),
        5,
        bulbPaint,
      );

      // Radial warm light cone downward across desk
      final lightGlow = Paint()
        ..shader =
            RadialGradient(
              colors: [StudyAtmosphereColors.lampLightGlow, Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(shadeCenter.dx, shadeCenter.dy + 35),
                radius: 65,
              ),
            );
      canvas.drawCircle(
        Offset(shadeCenter.dx, shadeCenter.dy + 35),
        65,
        lightGlow,
      );
    }
  }

  void _paintDeskJournal(Canvas canvas, Size size) {
    final journalX = size.width * 0.46 + parallaxOffset * 28;
    final journalY = size.height * 0.62;

    canvas.save();
    canvas.translate(journalX, journalY);
    canvas.rotate(-0.05); // slight natural tilt on the desk

    // Drop shadow
    final shadowPaint = Paint()..color = const Color(0x33000000);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-36, -20, 76, 52),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    // Leather cover back
    final leatherPaint = Paint()..color = const Color(0xFF522E1A);
    final coverRect = const Rect.fromLTWH(-38, -22, 76, 50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(coverRect, const Radius.circular(5)),
      leatherPaint,
    );

    // Cream paper pages block (open spread or closed edges)
    final paperBlockPaint = Paint()..color = const Color(0xFFFAF4E6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-34, -19, 68, 44),
        const Radius.circular(3),
      ),
      paperBlockPaint,
    );

    // Center spine crease
    final spinePaint = Paint()
      ..color = const Color(0xFFDACBB5)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(0, -19), const Offset(0, 25), spinePaint);

    // Subtle ruled text lines preview
    final textLinePaint = Paint()
      ..color = const Color(0x338A7360)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 4; i++) {
      final y = -12.0 + (i * 9.0);
      canvas.drawLine(Offset(-28, y), Offset(-6, y), textLinePaint);
      canvas.drawLine(Offset(6, y), Offset(28, y), textLinePaint);
    }

    // Red silk bookmark ribbon hanging out bottom
    final ribbonPaint = Paint()
      ..color = const Color(0xFFB52D2D)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final ribbonPath = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(4, 30, -2, 38);
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Brass corner ornaments
    final cornerPaint = Paint()..color = StudyAtmosphereColors.vintageBrass;
    canvas.drawCircle(const Offset(-34, -18), 3, cornerPaint);
    canvas.drawCircle(const Offset(34, -18), 3, cornerPaint);
    canvas.drawCircle(const Offset(-34, 24), 3, cornerPaint);
    canvas.drawCircle(const Offset(34, 24), 3, cornerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ObjectsPainter oldDelegate) {
    return oldDelegate.isLampOn != isLampOn ||
        oldDelegate.plantRustle != plantRustle ||
        oldDelegate.pendulumAngle != pendulumAngle ||
        oldDelegate.parallaxOffset != parallaxOffset;
  }
}
