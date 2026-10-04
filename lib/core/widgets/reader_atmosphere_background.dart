import 'dart:io';
import 'package:flutter/material.dart';

class ReaderWallpaperOption {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData icon;

  const ReaderWallpaperOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.icon,
  });
}

const List<ReaderWallpaperOption> kReaderPresetWallpapers = [
  ReaderWallpaperOption(
    id: 'botanical_deer',
    title: 'Lotus Fawn & Deer',
    subtitle: 'Botanical Wildlife Art',
    assetPath: 'assets/botanical_deer.jpg',
    icon: Icons.forest_rounded,
  ),
  ReaderWallpaperOption(
    id: 'ethereal_goddess',
    title: 'Ethereal Fantasy',
    subtitle: 'Mythological Goddess Art',
    assetPath: 'assets/ethereal_goddess.jpg',
    icon: Icons.auto_awesome_rounded,
  ),
  ReaderWallpaperOption(
    id: 'cozy_portrait',
    title: 'Storybook Warmth',
    subtitle: 'Cozy Solitude',
    assetPath: 'assets/cozy_portrait.jpg',
    icon: Icons.menu_book_rounded,
  ),
  ReaderWallpaperOption(
    id: 'artistic_study',
    title: 'Vintage Archive',
    subtitle: 'Classic Book Study',
    assetPath: 'assets/artistic_study.jpg',
    icon: Icons.history_edu_rounded,
  ),
];

/// Atmospheric illustrated reader background backdrop.
/// Displays selected artwork from assets or device gallery behind the physical book
/// with soft vignette and warm lighting for deep immersion.
class ReaderAtmosphereBackground extends StatelessWidget {
  final Widget child;
  final String mode; // 'asset', 'custom', 'desk'
  final String assetPath;
  final String? customImagePath;
  final Color deskFallbackColor;

  const ReaderAtmosphereBackground({
    super.key,
    required this.child,
    this.mode = 'asset',
    this.assetPath = 'assets/botanical_deer.jpg',
    this.customImagePath,
    this.deskFallbackColor = const Color(0xFF2C1B10),
  });

  @override
  Widget build(BuildContext context) {
    Widget backgroundWidget;

    if (mode == 'custom' && customImagePath != null && customImagePath!.isNotEmpty) {
      final file = File(customImagePath!);
      if (file.existsSync()) {
        backgroundWidget = Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackAsset(assetPath),
        );
      } else {
        backgroundWidget = _buildFallbackAsset(assetPath);
      }
    } else if (mode == 'asset') {
      backgroundWidget = _buildFallbackAsset(assetPath);
    } else {
      // Wood/Desk surface mode
      backgroundWidget = Container(
        decoration: BoxDecoration(
          color: deskFallbackColor,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              deskFallbackColor.withAlpha(220),
              deskFallbackColor,
              const Color(0xFF140D08),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Wallpaper Image / Backdrop
        Positioned.fill(
          child: backgroundWidget,
        ),

        // 2. Atmospheric Dimming & Warm Vignette Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Colors.black.withAlpha(65),
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(190),
                ],
                stops: const [0.3, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // 3. Subtle Warm Ambient Cast
        Positioned.fill(
          child: Container(
            color: const Color(0xFF2C1B10).withAlpha(40),
          ),
        ),

        // 4. Foreground Content (Book / Postcard / Binder)
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Widget _buildFallbackAsset(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to botanical deer or solid color if asset fails to load
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF231B16),
                Color(0xFF3E2D22),
                Color(0xFF1A120D),
              ],
            ),
          ),
        );
      },
    );
  }
}
