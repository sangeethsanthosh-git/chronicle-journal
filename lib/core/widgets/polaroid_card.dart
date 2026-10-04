import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'washi_tape.dart';

class PolaroidCard extends StatelessWidget {
  final String imagePath;
  final String? caption;
  final double width;
  final double rotationDegrees;
  final VoidCallback? onTap;

  const PolaroidCard({
    super.key,
    required this.imagePath,
    this.caption,
    this.width = 160.0,
    this.rotationDegrees = 2.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Transform.rotate(
            angle: rotationDegrees * (3.14159 / 180),
            child: Container(
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(35),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      width: width - 16,
                      height: (width - 16) * 1.05,
                      color: const Color(0xFFECE7DE),
                      child: isNetwork
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                    ),
                  ),
                  if (caption != null && caption!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      caption!,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.inkPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Tape on top
          Positioned(
            top: -10,
            child: WashiTape(
              width: width * 0.45,
              height: 18,
              rotationDegrees: -rotationDegrees,
              color: AppColors.washiTapeKraft,
            ),
          ),
        ],
      ),
    );
  }
}
