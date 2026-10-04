import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Authentic retro audio cassette tape player matching reference Image 2.
/// Includes rotating reel spools, vintage label sticker, tape window,
/// and smooth audio playback controls.
class CassetteTapeWidget extends StatefulWidget {
  final String audioPath;
  final String label;
  final VoidCallback? onDelete;
  final Color cassetteColor;

  const CassetteTapeWidget({
    super.key,
    required this.audioPath,
    this.label = 'VOICE MEMO • SIDE A',
    this.onDelete,
    this.cassetteColor = const Color(0xFFE8E2D2), // Vintage cream plastic
  });

  @override
  State<CassetteTapeWidget> createState() => _CassetteTapeWidgetState();
}

class _CassetteTapeWidgetState extends State<CassetteTapeWidget>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _posSub;

  late final AnimationController _spoolRotationController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _spoolRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _initAudio();
  }

  void _initAudio() {
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
      if (state == PlayerState.playing) {
        _spoolRotationController.repeat();
      } else {
        _spoolRotationController.stop();
      }
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _spoolRotationController.dispose();
    _stateSub?.cancel();
    _durationSub?.cancel();
    _posSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioPath));
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.cassetteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC4BCAB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(45),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Cassette label header & Delete action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2635),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'C-60',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF3C352D),
                    ),
                  ),
                ],
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFF7A6F62),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onDelete,
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Center Cassette Tape Body & Reels Window
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(
                0xFF282522,
              ), // Dark transparent plastic chamber
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF191715), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left spool wheel
                AnimatedBuilder(
                  animation: _spoolRotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spoolRotationController.value * 2 * math.pi,
                      child: _buildSpool(),
                    );
                  },
                ),

                // Center tape tape chamber & Play button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tape ribbon indicator
                    Container(
                      width: 54,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF42281D), // Magnetic tape brown
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Play / Pause Button
                    InkWell(
                      onTap: _togglePlay,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFC5A059), // Vintage gold button
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(60),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                // Right spool wheel
                AnimatedBuilder(
                  animation: _spoolRotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spoolRotationController.value * 2 * math.pi,
                      child: _buildSpool(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Duration & Progress Slider
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E5448),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 8,
                    ),
                    activeTrackColor: const Color(0xFF8B2635),
                    inactiveTrackColor: const Color(0xFFCCC3B2),
                    thumbColor: const Color(0xFF8B2635),
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds / _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (val) {
                      final ms = (val * _duration.inMilliseconds).toInt();
                      _player.seek(Duration(milliseconds: ms));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E5448),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpool() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEDE8DC),
        border: Border.all(color: const Color(0xFF9E9584), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner hub
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF282522),
            ),
          ),
          // Spoke teeth
          for (int i = 0; i < 6; i++)
            Transform.rotate(
              angle: (i * 60) * (math.pi / 180),
              child: Container(
                width: 2,
                height: 26,
                color: const Color(0xFFB5AC9B),
              ),
            ),
        ],
      ),
    );
  }
}
