import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/preferences_provider.dart';

/// Immersive, responsive Splash Screen featuring the Miora identity:
/// - Brand artwork background ("Your thoughts. Your moments. Your story.")
/// - Red icon with smooth entrance scale & fade
/// - Responsive LayoutBuilder for phones, foldables, tablets, and landscape
/// - Automatic route resolution (Onboarding -> App Lock -> Home)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _navTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    // Navigate after 1.8 seconds
    _navTimer = Timer(const Duration(milliseconds: 1800), _proceedToNextScreen);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _proceedToNextScreen() {
    if (!mounted || _navigated) return;
    _navigated = true;

    final prefs = ref.read(preferencesProvider);
    if (!prefs.isOnboardingCompleted) {
      context.go('/onboarding');
    } else if (prefs.isAppLockEnabled) {
      context.go('/lock');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isShort = size.height < 600;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF6C4EB6), // Matches splash gradient primary
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Allow tapping to skip splash after brief pause
          if (_animController.value > 0.4) {
            _proceedToNextScreen();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-bleed Brand Gradient Artwork
            Image.asset(
              'assets/splash_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5B36F5),
                      Color(0xFF8672D6),
                      Color(0xFFC1E6A9),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle dark overlay to ensure high contrast in all lighting
            Container(
              color: Colors.black.withAlpha(25),
            ),

            // 2. Responsive Content Container
            SafeArea(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: child,
                    ),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final iconSize = isShort
                        ? 64.0
                        : (isLandscape ? 72.0 : 96.0);

                    return Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Red App Icon (Centerpiece with shadow & white border)
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(iconSize * 0.24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(70),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(iconSize * 0.24),
                                  child: Image.asset(
                                    'assets/app_icon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFFE5252A),
                                      child: const Center(
                                        child: Text(
                                          'M',
                                          style: TextStyle(
                                            fontFamily: 'serif',
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isShort ? 14 : 22),

                              // Brand Name
                              const Text(
                                'Miora',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tagline
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 380),
                                child: const Text(
                                  'Your thoughts. Your moments. Your story.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 14.5,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.4,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 8,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isShort ? 24 : 40),

                              // Elegant loading pulse dot
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(3, (i) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withAlpha(190 + (i * 20)),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
