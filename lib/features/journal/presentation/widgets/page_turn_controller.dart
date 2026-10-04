import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Controller for driving physical page turning animations and gestures.
/// Responsible for:
/// - Tracking current spread index
/// - Handling interactive drag gestures (finger following paper)
/// - Completing and canceling drag turns with spring physics
/// - Programmatic nextPage() / previousPage() / jumpToSpread()
class PageTurnController extends ChangeNotifier {
  int _currentSpreadIndex = 0;
  int _totalSpreads = 1;

  double _dragProgress = 0.0;
  bool _isTurningForward = true;
  bool _isDragging = false;
  bool _isAnimating = false;

  AnimationController? _animController;

  int get currentSpreadIndex => _currentSpreadIndex;
  int get totalSpreads => _totalSpreads;

  /// Progress of the active page turn:
  /// 0.0 = Page resting flat in place
  /// 0.5 = Page standing vertically at 90 degrees
  /// 1.0 = Page fully turned flat to the other side
  double get dragProgress => _dragProgress;

  /// true if turning forward (right page flips to left),
  /// false if turning backward (left page flips to right).
  bool get isTurningForward => _isTurningForward;

  bool get isDragging => _isDragging;
  bool get isAnimating => _isAnimating;

  bool get canTurnForward => _currentSpreadIndex < _totalSpreads - 1;
  bool get canTurnBackward => _currentSpreadIndex > 0;

  void attachAnimationController(AnimationController controller) {
    _animController = controller;
  }

  void detachAnimationController() {
    _animController = null;
  }

  void setTotalSpreads(int count) {
    _totalSpreads = math.max(1, count);
    if (_currentSpreadIndex >= _totalSpreads) {
      _currentSpreadIndex = _totalSpreads - 1;
    }
    notifyListeners();
  }

  /// Begins a manual finger drag on a page.
  void handleDragStart({required bool forward}) {
    if (_isAnimating) return;
    if (forward && !canTurnForward) return;
    if (!forward && !canTurnBackward) return;

    _isDragging = true;
    _isTurningForward = forward;
    _dragProgress = 0.0;
    notifyListeners();
  }

  /// Updates drag progress as user moves finger horizontally.
  /// [deltaNormalized] is the horizontal movement divided by page width.
  void handleDragUpdate(double deltaNormalized) {
    if (!_isDragging) return;

    if (_isTurningForward) {
      // Swiping from right to left increases progress
      _dragProgress = (_dragProgress - deltaNormalized).clamp(0.0, 1.0);
    } else {
      // Swiping from left to right increases progress
      _dragProgress = (_dragProgress + deltaNormalized).clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  /// Completes drag gesture when user releases finger.
  /// If progress > threshold or flick velocity is high, finishes page turn.
  /// Otherwise, springs back to starting position.
  /// Completes drag gesture when user releases finger.
  /// If progress > threshold or flick velocity is high, finishes page turn.
  /// Otherwise, springs back to starting position.
  Future<void> completeDrag({double velocity = 0.0}) async {
    if (!_isDragging) return;
    _isDragging = false;

    final threshold = 0.38;
    final velocityThreshold = 400.0;

    final shouldTurn = _isTurningForward
        ? (_dragProgress > threshold || velocity < -velocityThreshold)
        : (_dragProgress > threshold || velocity > velocityThreshold);

    try {
      if (shouldTurn) {
        await _animateProgressTo(1.0);
        if (_isTurningForward) {
          _currentSpreadIndex = math.min(
            _totalSpreads - 1,
            _currentSpreadIndex + 1,
          );
        } else {
          _currentSpreadIndex = math.max(0, _currentSpreadIndex - 1);
        }
      } else {
        await _animateProgressTo(0.0);
      }
    } catch (_) {
      // Ignore animation cancellation
    } finally {
      _dragProgress = 0.0;
      _isDragging = false;
      _isAnimating = false;
      notifyListeners();
    }
  }

  /// Cancels drag and snaps back.
  Future<void> cancelDrag() async {
    if (!_isDragging) return;
    _isDragging = false;
    try {
      await _animateProgressTo(0.0);
    } catch (_) {
      // Ignore cancellation
    } finally {
      _dragProgress = 0.0;
      _isDragging = false;
      _isAnimating = false;
      notifyListeners();
    }
  }

  /// Programmatic turn to next page with natural paper timing.
  Future<void> nextPage({
    Duration duration = const Duration(milliseconds: 480),
  }) async {
    if (!canTurnForward || _isAnimating || _isDragging) return;
    _isTurningForward = true;
    _dragProgress = 0.0;
    _isAnimating = true;
    notifyListeners();

    try {
      await _animateProgressTo(1.0, duration: duration);
      _currentSpreadIndex = math.min(_totalSpreads - 1, _currentSpreadIndex + 1);
    } catch (_) {
      // Ignore cancellation
    } finally {
      _dragProgress = 0.0;
      _isAnimating = false;
      _isDragging = false;
      notifyListeners();
    }
  }

  /// Programmatic turn to previous page with natural paper timing.
  Future<void> previousPage({
    Duration duration = const Duration(milliseconds: 480),
  }) async {
    if (!canTurnBackward || _isAnimating || _isDragging) return;
    _isTurningForward = false;
    _dragProgress = 0.0;
    _isAnimating = true;
    notifyListeners();

    try {
      await _animateProgressTo(1.0, duration: duration);
      _currentSpreadIndex = math.max(0, _currentSpreadIndex - 1);
    } catch (_) {
      // Ignore cancellation
    } finally {
      _dragProgress = 0.0;
      _isAnimating = false;
      _isDragging = false;
      notifyListeners();
    }
  }

  /// Jumps directly to a given spread index without animation.
  void jumpToSpread(int spreadIndex) {
    if (spreadIndex < 0 || spreadIndex >= _totalSpreads) return;
    _currentSpreadIndex = spreadIndex;
    _dragProgress = 0.0;
    _isDragging = false;
    _isAnimating = false;
    notifyListeners();
  }

  Future<void> _animateProgressTo(double target, {Duration? duration}) async {
    if (_animController == null) {
      _dragProgress = target;
      notifyListeners();
      return;
    }

    _isAnimating = true;
    final start = _dragProgress;
    final animDuration = duration ?? const Duration(milliseconds: 420);

    _animController!.stop();
    _animController!.duration = animDuration;
    _animController!.reset();

    final animation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    );

    void listener() {
      _dragProgress = animation.value;
      notifyListeners();
    }

    animation.addListener(listener);

    try {
      await _animController!.forward();
    } catch (_) {
      // Safely ignore TickerCanceled or animation cancellation
    } finally {
      animation.removeListener(listener);
      _isAnimating = false;
    }
  }
}
