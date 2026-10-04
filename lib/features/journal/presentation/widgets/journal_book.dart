import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'journal_page_spread.dart';
import 'page_shadow.dart';
import 'page_turn_controller.dart';
import 'paper_peel_engine.dart';

/// The interactive Illustrated Journal Book object resting inside the world.
/// Features:
/// - Closed book with authentic embossed leather cover & ribbon bookmark
/// - Tap book -> subtle highlight, camera depth zoom (room 0.98, journal 1.04), cover 3D opens
/// - Open book -> interactive physical 3D page turning with drag & swipe
/// - Orientation switcher toggle (Landscape spread vs Portrait reading)
/// - Tap outside -> closes book and returns camera to room scale
class JournalBook extends StatefulWidget {
  final List<JournalPageSpread> spreads;
  final PageTurnController controller;
  final Color coverColor;
  final Color paperColor;
  final VoidCallback? onBookOpened;
  final VoidCallback? onBookClosed;
  final bool initialOpen;

  const JournalBook({
    super.key,
    required this.spreads,
    required this.controller,
    this.coverColor = const Color(0xFF2C241E), // Vintage dark leather
    this.paperColor = const Color(0xFFFAF7EE),
    this.onBookOpened,
    this.onBookClosed,
    this.initialOpen = true,
  });

  @override
  State<JournalBook> createState() => _JournalBookState();
}

class _JournalBookState extends State<JournalBook>
    with SingleTickerProviderStateMixin {
  late AnimationController _openController;
  late Animation<double> _openAnimation;
  late Animation<double> _journalScaleAnimation;

  bool _isOpen = false;
  bool _isLandscapeMode = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen;

    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _openAnimation = CurvedAnimation(
      parent: _openController,
      curve: Curves.easeInOutCubic,
    );

    _journalScaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _openController, curve: Curves.easeOutCubic),
    );

    if (_isOpen) {
      _openController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(JournalBook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOpen != oldWidget.initialOpen) {
      if (widget.initialOpen && !_isOpen) {
        setState(() => _isOpen = true);
        _openController.forward();
      } else if (!widget.initialOpen && _isOpen) {
        setState(() => _isOpen = false);
        _openController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _openController.dispose();
    super.dispose();
  }

  void _toggleOpen() {
    if (_isOpen) {
      _openController.reverse().then((_) {
        setState(() => _isOpen = false);
        widget.onBookClosed?.call();
      });
    } else {
      setState(() => _isOpen = true);
      _openController.forward().then((_) {
        widget.onBookOpened?.call();
      });
    }
  }

  /// Toggles orientation between Landscape (wide physical spread) and Portrait
  Future<void> _toggleOrientation() async {
    final newIsLandscape = !_isLandscapeMode;
    setState(() => _isLandscapeMode = newIsLandscape);

    if (newIsLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _openController,
      builder: (context, _) {
        final openProgress = _openAnimation.value;
        final scale = _journalScaleAnimation.value;

        return Transform.scale(
          scale: scale,
          child: BookDropShadow(
            child: AspectRatio(
              aspectRatio:
                  16 / 10.5, // Standard physical landscape notebook spread
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = constraints.maxWidth / 2;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Leather Book Outer Binding Base
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.coverColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFC5A059).withAlpha(80),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),

                      // 2. Open Journal Pages
                      if (openProgress > 0.05)
                        Positioned.fill(
                          child: Opacity(
                            opacity:
                                ((openProgress - 0.05) / 0.95).clamp(0.0, 1.0),
                            child: PaperPeelPageTurn(
                              spreads: widget.spreads,
                              controller: widget.controller,
                              paperColor: widget.paperColor,
                            ),
                          ),
                        ),

                      // 3. 3D Opening Leather Cover (visible during opening animation or when closed)
                      if (openProgress < 0.98)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: halfWidth,
                          child: _build3DCover(openProgress),
                        ),

                      // 4. Closed book interaction layer: tapping ANYWHERE on closed book opens it
                      if (!_isOpen || openProgress < 0.1)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _toggleOpen,
                          ),
                        ),

                      // 5. Floating Header Overlay when open (Orientation toggle, Page count, Close)
                      if (_isOpen && openProgress > 0.8)
                        Positioned(
                          top: -38,
                          left: 0,
                          right: 0,
                          child: _buildBookControlsHeader(context),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 3D Leather Cover opening toward the left
  Widget _build3DCover(double openProgress) {
    final angle = -openProgress * math.pi;

    return Transform(
      alignment: Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle),
      child: GestureDetector(
        onTap: _toggleOpen,
        child: Container(
          decoration: BoxDecoration(
            color: widget.coverColor,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(-4, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gold Foil Cover Embellishment
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFC5A059),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'CHRONICLE',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: Color(0xFFFAF7EE),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '— MEMORIES & DAYS —',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 8,
                              letterSpacing: 2.0,
                              color: Color(0xFFC5A059),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap to Open Journal',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFDED6C4),
                      ),
                    ),
                  ],
                ),
              ),

              // Ribbon bookmark hanging out from the bottom
              Positioned(
                bottom: -16,
                right: 32,
                width: 18,
                height: 36,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B2635), // Burgundy ribbon
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact controls bar above the open journal
  Widget _buildBookControlsHeader(BuildContext context) {
    final current = widget.controller.currentSpreadIndex + 1;
    final total = widget.controller.totalSpreads;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close journal button (zoom back out to room)
          InkWell(
            onTap: _toggleOpen,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.close_fullscreen_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Close Journal',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(140),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Spread $current of $total',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Orientation Switcher (Landscape Spread vs Portrait)
          InkWell(
            onTap: _toggleOrientation,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLandscapeMode
                        ? Icons.screen_lock_rotation_rounded
                        : Icons.screen_rotation_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isLandscapeMode ? 'Portrait View' : 'Landscape Spread',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
