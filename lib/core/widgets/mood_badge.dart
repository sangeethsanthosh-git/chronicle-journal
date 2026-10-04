import 'package:flutter/material.dart';
import '../../domain/models/mood.dart';

class MoodBadge extends StatelessWidget {
  final Mood mood;
  final int intensity;
  final bool showLabel;
  final bool showIntensity;

  const MoodBadge({
    super.key,
    required this.mood,
    this.intensity = 3,
    this.showLabel = true,
    this.showIntensity = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: mood.color.withAlpha(45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mood.color.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 14)),
          if (showLabel) ...[
            const SizedBox(width: 5),
            Text(
              mood.label,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: mood.color.withAlpha(240),
              ),
            ),
          ],
          if (showIntensity) ...[
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final active = index < intensity;
                return Container(
                  margin: const EdgeInsets.only(left: 2),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? mood.color : mood.color.withAlpha(60),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
