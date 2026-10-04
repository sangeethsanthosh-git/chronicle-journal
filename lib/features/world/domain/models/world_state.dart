import 'package:flutter/material.dart';
import 'room_decoration.dart';

/// State representation of the interactive Cozy Study world.
class WorldState {
  final bool isLampOn;
  final int currentHour;
  final bool isRaining;
  final String? focusedHotspotId;
  final double cameraZoom;
  final Offset cameraPan;
  final List<RoomDecoration> decorations;

  const WorldState({
    this.isLampOn = true,
    this.currentHour = 14,
    this.isRaining = false,
    this.focusedHotspotId,
    this.cameraZoom = 1.0,
    this.cameraPan = Offset.zero,
    this.decorations = const [],
  });

  WorldState copyWith({
    bool? isLampOn,
    int? currentHour,
    bool? isRaining,
    String? focusedHotspotId,
    double? cameraZoom,
    Offset? cameraPan,
    List<RoomDecoration>? decorations,
  }) {
    return WorldState(
      isLampOn: isLampOn ?? this.isLampOn,
      currentHour: currentHour ?? this.currentHour,
      isRaining: isRaining ?? this.isRaining,
      focusedHotspotId: focusedHotspotId,
      cameraZoom: cameraZoom ?? this.cameraZoom,
      cameraPan: cameraPan ?? this.cameraPan,
      decorations: decorations ?? this.decorations,
    );
  }
}
