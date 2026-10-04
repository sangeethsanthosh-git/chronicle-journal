import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chronicle/core/theme/study_atmosphere_colors.dart';
import '../../../companion/providers/companion_provider.dart';
import '../../../progression/providers/progression_provider.dart';
import '../../providers/world_providers.dart';
import '../widgets/layers/layer0_skybox.dart';
import '../widgets/layers/layer1_window_vista.dart';
import '../widgets/layers/layer2_study_architecture.dart';
import '../widgets/layers/layer3_study_furniture.dart';
import '../widgets/layers/layer4_interactive_objects.dart';
import '../widgets/layers/layer5_companion_fable.dart';
import '../widgets/layers/layer6_foreground_props.dart';
import '../widgets/layers/layer7_atmospheric_fx.dart';

class CozyStudyWorldScreen extends ConsumerStatefulWidget {
  final VoidCallback? onToggleOverview;

  const CozyStudyWorldScreen({super.key, this.onToggleOverview});

  @override
  ConsumerState<CozyStudyWorldScreen> createState() =>
      _CozyStudyWorldScreenState();
}

class _CozyStudyWorldScreenState extends ConsumerState<CozyStudyWorldScreen>
    with TickerProviderStateMixin {
  // Ambient animation controller (drives dust motes, teacup steam, companion breathing)
  late final AnimationController _ambientController;

  // Plant rustle spring controller
  late final AnimationController _plantRustleController;

  // Cinematic Camera Zoom Controller
  late final AnimationController _cameraController;
  late final Animation<double> _cameraZoomAnimation;
  late final Animation<Offset> _cameraOffsetAnimation;

  // Touch Pan Parallax State
  double _panDeltaX = 0.0;

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _plantRustleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _cameraZoomAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOutCubic),
    );

    _cameraOffsetAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.15, -0.25),
        ).animate(
          CurvedAnimation(
            parent: _cameraController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _plantRustleController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void _onPlantTap() {
    HapticFeedback.lightImpact();
    _plantRustleController.forward(from: 0.0);
  }

  void _onLampTap() {
    HapticFeedback.mediumImpact();
    ref.read(worldProvider.notifier).toggleLamp();
  }

  void _onFableTap() {
    HapticFeedback.selectionClick();
    ref.read(companionProvider.notifier).tapCompanion();
  }

  Future<void> _onJournalTap() async {
    HapticFeedback.heavyImpact();
    ref.read(worldProvider.notifier).focusHotspot('desk_journal');

    // Cinematic zoom towards the desk journal
    await _cameraController.forward();

    if (!mounted) return;
    // Navigate into the editor or book reader
    await context.push('/editor');

    if (mounted) {
      _cameraController.reverse();
      ref.read(worldProvider.notifier).clearFocus();
    }
  }

  void _onBookshelfTap() {
    HapticFeedback.selectionClick();
    context.push('/memories');
  }

  void _onGalleryTap() {
    HapticFeedback.selectionClick();
    context.push('/scrapbook');
  }

  @override
  Widget build(BuildContext context) {
    final worldState = ref.watch(worldProvider);
    final companionState = ref.watch(companionProvider);
    final progress = ref.watch(userProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _panDeltaX = (_panDeltaX + details.delta.dx * 0.003).clamp(
              -0.08,
              0.08,
            );
          });
        },
        onHorizontalDragEnd: (_) {
          // Softly spring back to center
          setState(() {
            _panDeltaX = 0.0;
          });
        },
        child: Stack(
          children: [
            // ZOOMABLE & CAMERA VIEWPORT
            AnimatedBuilder(
              animation: _cameraController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cameraZoomAnimation.value,
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(
                      _cameraOffsetAnimation.value.dx *
                          MediaQuery.of(context).size.width,
                      _cameraOffsetAnimation.value.dy *
                          MediaQuery.of(context).size.height,
                    ),
                    child: child,
                  ),
                );
              },
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  final tick = _ambientController.value;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // LAYER 0: Skybox & Ambient Gradient
                      Layer0Skybox(
                        hour: worldState.currentHour,
                        parallaxOffset: _panDeltaX * 0.1,
                      ),

                      // LAYER 1: Window Vista (Hills, Weather, Rain)
                      Layer1WindowVista(
                        hour: worldState.currentHour,
                        isRaining: worldState.isRaining,
                        parallaxOffset: _panDeltaX * 0.2,
                      ),

                      // LAYER 2: Room Architecture (Wallpaper, Floorboards, Rug)
                      Layer2StudyArchitecture(
                        isDarkTheme: isDark,
                        parallaxOffset: _panDeltaX * 0.35,
                      ),

                      // LAYER 3: Furniture & Room Fixtures (Desk, Chair, Bookshelf Frame)
                      Layer3StudyFurniture(parallaxOffset: _panDeltaX * 0.55),

                      // LAYER 4: Interactive World Objects (Journal, Lamp, Books, Plant)
                      Layer4InteractiveObjects(
                        isLampOn: worldState.isLampOn,
                        plantRustle: _plantRustleController.value,
                        pendulumAngle: (tick * 2 - 1.0),
                        parallaxOffset: _panDeltaX * 0.75,
                        onJournalTap: _onJournalTap,
                        onBookshelfTap: _onBookshelfTap,
                        onGalleryTap: _onGalleryTap,
                        onLampTap: _onLampTap,
                        onPlantTap: _onPlantTap,
                      ),

                      // LAYER 5: Companion Character "Fable"
                      Layer5CompanionFable(
                        companionState: companionState,
                        idleTick: tick,
                        parallaxOffset: _panDeltaX * 0.85,
                        onTapFable: _onFableTap,
                        onDismissSpeech: () {
                          ref
                              .read(companionProvider.notifier)
                              .dismissSpeechBubble();
                        },
                      ),

                      // LAYER 6: Foreground Props (Teacup Steam, Inkwell)
                      Layer6ForegroundProps(
                        steamTick: (tick * 4) % 1.0,
                        parallaxOffset: _panDeltaX * 0.95,
                      ),

                      // LAYER 7: Atmospheric Particle Systems & Warm Light
                      Layer7AtmosphericFX(
                        hour: worldState.currentHour,
                        isLampOn: worldState.isLampOn,
                        particleTick: tick,
                        parallaxOffset: _panDeltaX,
                      ),
                    ],
                  );
                },
              ),
            ),

            // TOP FLOATING SANCTUARY HUD
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _StudySanctuaryHeader(
                progress: progress,
                isLampOn: worldState.isLampOn,
                onToggleLamp: _onLampTap,
                onToggleOverview: widget.onToggleOverview,
              ),
            ),

            // BOTTOM FLOATING VINTAGE TOOLBAR
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _StudyQuickBar(
                onOpenJournal: _onJournalTap,
                onReadBook: () => context.push('/book-reader'),
                onScrapbook: () => context.push('/scrapbook'),
                onTimeline: () => context.push('/journal'),
                onCalendar: () => context.push('/calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating sanctuary header showing Thought XP, Room Tier, and Quick Controls.
class _StudySanctuaryHeader extends StatelessWidget {
  final dynamic progress;
  final bool isLampOn;
  final VoidCallback onToggleLamp;
  final VoidCallback? onToggleOverview;

  const _StudySanctuaryHeader({
    required this.progress,
    required this.isLampOn,
    required this.onToggleLamp,
    this.onToggleOverview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xDD2A1F17),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x66C5A059), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sanctuary Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC5A059),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv. ${progress.currentLevel}',
              style: const TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF2C1B10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  progress.sanctuaryTitle,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFFF7F3E9),
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress.levelProgress,
                    minHeight: 4,
                    backgroundColor: const Color(0x44FFFFFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      StudyAtmosphereColors.vintageBrass,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Lamp toggle button
          IconButton(
            icon: Icon(
              isLampOn
                  ? Icons.lightbulb_rounded
                  : Icons.lightbulb_outline_rounded,
              color: isLampOn
                  ? const Color(0xFFFFD54F)
                  : const Color(0x99FFFFFF),
              size: 22,
            ),
            tooltip: isLampOn ? 'Turn Off Lamp' : 'Turn On Lamp',
            onPressed: onToggleLamp,
          ),
          if (onToggleOverview != null)
            IconButton(
              icon: const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFFE2DACB),
                size: 22,
              ),
              tooltip: 'Journal Overview',
              onPressed: onToggleOverview,
            ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar designed as a tactile brass-embossed study drawer.
class _StudyQuickBar extends StatelessWidget {
  final VoidCallback onOpenJournal;
  final VoidCallback onReadBook;
  final VoidCallback onScrapbook;
  final VoidCallback onTimeline;
  final VoidCallback onCalendar;

  const _StudyQuickBar({
    required this.onOpenJournal,
    required this.onReadBook,
    required this.onScrapbook,
    required this.onTimeline,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE382519),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x88C5A059), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickButton(
            icon: Icons.edit_note_rounded,
            label: 'Write',
            isPrimary: true,
            onTap: onOpenJournal,
          ),
          _QuickButton(
            icon: Icons.auto_stories_rounded,
            label: 'Read',
            onTap: onReadBook,
          ),
          _QuickButton(
            icon: Icons.palette_outlined,
            label: 'Scrapbook',
            onTap: onScrapbook,
          ),
          _QuickButton(
            icon: Icons.history_edu_rounded,
            label: 'Timeline',
            onTap: onTimeline,
          ),
          _QuickButton(
            icon: Icons.calendar_today_rounded,
            label: 'Calendar',
            onTap: onCalendar,
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5A059),
          foregroundColor: const Color(0xFF2C1B10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        onPressed: onTap,
      );
    }

    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFF0E6D2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon: Icon(icon, size: 18, color: const Color(0xFFD4B996)),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onTap,
    );
  }
}
