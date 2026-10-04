import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';
import 'package:chronicle/features/companion/domain/models/companion_state.dart';

class Layer5CompanionFable extends StatelessWidget {
  final CompanionState companionState;
  final double idleTick; // Periodic oscillating tick (e.g. 0.0 to 1.0)
  final double parallaxOffset;
  final VoidCallback onTapFable;
  final VoidCallback onDismissSpeech;

  const Layer5CompanionFable({
    super.key,
    required this.companionState,
    required this.idleTick,
    this.parallaxOffset = 0.0,
    required this.onTapFable,
    required this.onDismissSpeech,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;

          // Fable coordinates in the study (seated to the right side of the desk)
          final fableCenter = Offset(
            size.width * 0.65 + parallaxOffset * 26,
            size.height * 0.58,
          );

          // Hitbox for tapping Fable
          final hitboxRect = Rect.fromCenter(
            center: fableCenter,
            width: 75,
            height: 110,
          );

          return Stack(
            children: [
              // Procedurally Painted Character
              CustomPaint(
                size: Size.infinite,
                painter: _FablePainter(
                  state: companionState,
                  idleTick: idleTick,
                  fableCenter: fableCenter,
                ),
              ),

              // Interactive Tap Target
              Positioned.fromRect(
                rect: hitboxRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapFable,
                  child: const Tooltip(
                    message: 'Talk to Fable',
                    child: SizedBox.expand(),
                  ),
                ),
              ),

              // Visual Novel Speech Bubble (Above Fable's head)
              if (companionState.isSpeechBubbleVisible)
                Positioned(
                  left: (fableCenter.dx - 120).clamp(16.0, size.width - 240.0),
                  top: fableCenter.dy - 125,
                  child: _FableSpeechBubble(
                    text: companionState.activeSpeech,
                    onDismiss: onDismissSpeech,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FableSpeechBubble extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;

  const _FableSpeechBubble({required this.text, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCA134),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Fable',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3324),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.close, size: 14, color: Color(0xFF837B72)),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF2C2621),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FablePainter extends CustomPainter {
  final CompanionState state;
  final double idleTick;
  final Offset fableCenter;

  _FablePainter({
    required this.state,
    required this.idleTick,
    required this.fableCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Subtle gentle breathing/bobbing
    final bob = sin(idleTick * 2 * pi) * 2.0;
    canvas.translate(fableCenter.dx, fableCenter.dy + bob);

    // 1. STOOL (Seating)
    final stoolPaint = Paint()..color = const Color(0xFF3B2718);
    canvas.drawOval(const Rect.fromLTWH(-20, 28, 40, 10), stoolPaint);
    final legPaint = Paint()
      ..color = const Color(0xFF2C1B10)
      ..strokeWidth = 3.5;
    canvas.drawLine(const Offset(-14, 33), const Offset(-18, 55), legPaint);
    canvas.drawLine(const Offset(14, 33), const Offset(18, 55), legPaint);

    // 2. BODY & SWEATER (Cream cable-knit)
    final bodyPaint = Paint()..color = StudyAtmosphereColors.fableSweaterCream;
    final bodyPath = Path()
      ..moveTo(-16, 26)
      ..quadraticBezierTo(-18, 2, -10, -4)
      ..lineTo(10, -4)
      ..quadraticBezierTo(18, 2, 16, 26)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Sweater texture ribs
    final ribPaint = Paint()
      ..color = const Color(0xFFE2D6C3)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      final y = 4.0 + (i * 7.0);
      canvas.drawLine(Offset(-12, y), Offset(12, y), ribPaint);
    }

    // 3. OVERSIZED KNITTED SCARF (Mustard Gold)
    final scarfPaint = Paint()..color = StudyAtmosphereColors.fableScarfMustard;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -10, 36, 16),
        const Radius.circular(8),
      ),
      scarfPaint,
    );

    // Hanging scarf tail
    final tailPath = Path()
      ..moveTo(6, 2)
      ..quadraticBezierTo(14, 8, 12, 22)
      ..lineTo(6, 22)
      ..close();
    canvas.drawPath(tailPath, scarfPaint);

    // Scarf fringe
    final fringePaint = Paint()
      ..color = StudyAtmosphereColors.fableScarfKnitDark
      ..strokeWidth = 1.5;
    for (int f = 7; f <= 11; f += 2) {
      canvas.drawLine(
        Offset(f.toDouble(), 22),
        Offset(f.toDouble(), 26),
        fringePaint,
      );
    }

    // 4. HEAD & FACE
    final headPaint = Paint()..color = StudyAtmosphereColors.fableSkinTone;
    canvas.drawCircle(const Offset(0, -22), 17, headPaint);

    // Rosy cheeks
    final blushPaint = Paint()
      ..color = StudyAtmosphereColors.fableCheekBlush.withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(-9, -18), 3.5, blushPaint);
    canvas.drawCircle(const Offset(9, -18), 3.5, blushPaint);

    // Eyes (Hazel or closed smile based on mood)
    final eyePaint = Paint()..color = StudyAtmosphereColors.fableEyeHazel;
    final isBlinking = (idleTick > 0.45 && idleTick < 0.52);

    if (isBlinking ||
        state.moodState == CompanionMoodState.happy ||
        state.moodState == CompanionMoodState.celebrating) {
      // Curved happy / smiling eyes
      final smileEyePaint = Paint()
        ..color = StudyAtmosphereColors.fableEyeHazel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        const Rect.fromLTWH(-11, -26, 6, 6),
        pi * 1.1,
        pi * 0.8,
        false,
        smileEyePaint,
      );
      canvas.drawArc(
        const Rect.fromLTWH(5, -26, 6, 6),
        pi * 1.1,
        pi * 0.8,
        false,
        smileEyePaint,
      );
    } else {
      // Open inquisitive eyes
      canvas.drawCircle(const Offset(-8, -23), 2.2, eyePaint);
      canvas.drawCircle(const Offset(8, -23), 2.2, eyePaint);
    }

    // 5. ROUND BRASS SPECTACLES
    final specPaint = Paint()
      ..color = StudyAtmosphereColors.fableSpectaclesBrass
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(-8, -23), 5.5, specPaint);
    canvas.drawCircle(const Offset(8, -23), 5.5, specPaint);
    // Bridge between spectacles
    canvas.drawLine(const Offset(-2.5, -23), const Offset(2.5, -23), specPaint);

    // 6. CHESTNUT HAIR
    final hairPaint = Paint()..color = StudyAtmosphereColors.fableHairChestnut;
    final hairPath = Path()
      ..moveTo(-17, -22)
      ..quadraticBezierTo(-18, -40, 0, -40)
      ..quadraticBezierTo(18, -40, 17, -22)
      ..quadraticBezierTo(15, -30, 4, -32)
      ..quadraticBezierTo(-4, -28, -17, -22)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Bangs over forehead
    final bangPath = Path()
      ..moveTo(-12, -32)
      ..quadraticBezierTo(-5, -25, 0, -30)
      ..quadraticBezierTo(6, -26, 12, -31)
      ..close();
    canvas.drawPath(bangPath, hairPaint);

    // 7. BRASS QUILL IN HAND
    final quillPaint = Paint()..color = StudyAtmosphereColors.fableBrassQuill;
    final featherPaint = Paint()
      ..color = StudyAtmosphereColors.fableQuillFeather;

    canvas.save();
    canvas.translate(14, 10);
    canvas.rotate(0.35);

    // Quill nib
    final nibPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-2, 10)
      ..lineTo(2, 10)
      ..close();
    canvas.drawPath(nibPath, quillPaint);

    // Quill feather plume
    final featherPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-4, -14, 0, -20)
      ..quadraticBezierTo(4, -14, 0, 0)
      ..close();
    canvas.drawPath(featherPath, featherPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FablePainter oldDelegate) {
    return oldDelegate.idleTick != idleTick ||
        oldDelegate.state != state ||
        oldDelegate.fableCenter != fableCenter;
  }
}
