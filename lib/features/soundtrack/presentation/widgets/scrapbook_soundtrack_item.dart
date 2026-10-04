import 'package:flutter/material.dart';
import '../../domain/models/now_playing.dart';
import '../../domain/models/soundtrack_card_style.dart';
import 'soundtrack_card.dart';

/// Interactive Scrapbook Soundtrack Canvas Object
/// Supports tactile dragging (move), rotation, scaling, style switching, and deletion.
class ScrapbookSoundtrackItem extends StatefulWidget {
  final NowPlaying track;
  final Offset initialPosition;
  final double initialRotation;
  final double initialScale;
  final SoundtrackCardStyle initialStyle;
  final ValueChanged<Offset>? onPositionChanged;
  final ValueChanged<double>? onRotationChanged;
  final ValueChanged<double>? onScaleChanged;
  final ValueChanged<SoundtrackCardStyle>? onStyleChanged;
  final VoidCallback? onDelete;

  const ScrapbookSoundtrackItem({
    super.key,
    required this.track,
    this.initialPosition = const Offset(40, 80),
    this.initialRotation = -0.04,
    this.initialScale = 1.0,
    this.initialStyle = SoundtrackCardStyle.cassette,
    this.onPositionChanged,
    this.onRotationChanged,
    this.onScaleChanged,
    this.onStyleChanged,
    this.onDelete,
  });

  @override
  State<ScrapbookSoundtrackItem> createState() =>
      _ScrapbookSoundtrackItemState();
}

class _ScrapbookSoundtrackItemState extends State<ScrapbookSoundtrackItem> {
  late Offset _position;
  late double _rotation;
  late double _scale;
  late SoundtrackCardStyle _style;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _rotation = widget.initialRotation;
    _scale = widget.initialScale;
    _style = widget.initialStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () => setState(() => _isSelected = !_isSelected),
        onScaleStart: (_) => setState(() => _isSelected = true),
        onScaleUpdate: (details) {
          setState(() {
            _position += details.focalPointDelta;
            if (details.rotation != 0) {
              _rotation += details.rotation * 0.5;
            }
            if (details.scale != 1.0) {
              _scale = (_scale * details.scale).clamp(0.6, 1.8);
            }
          });
          widget.onPositionChanged?.call(_position);
          widget.onRotationChanged?.call(_rotation);
          widget.onScaleChanged?.call(_scale);
        },
        child: Transform.rotate(
          angle: _rotation,
          child: Transform.scale(
            scale: _scale,
            child: Container(
              decoration: _isSelected
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFC5A059),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: SoundtrackCard(
                track: widget.track,
                style: _style,
                onDelete: widget.onDelete,
                onStyleChanged: (newStyle) {
                  setState(() => _style = newStyle);
                  widget.onStyleChanged?.call(newStyle);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
