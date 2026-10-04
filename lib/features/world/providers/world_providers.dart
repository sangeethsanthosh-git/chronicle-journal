import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progression/providers/progression_provider.dart';
import '../domain/models/room_decoration.dart';
import '../domain/models/world_state.dart';

class WorldNotifier extends Notifier<WorldState> {
  @override
  WorldState build() {
    final progress = ref.watch(userProgressProvider);
    final currentHour = DateTime.now().hour;

    // Filter unlocked decorations based on current sanctuary level
    final availableDecorations = RoomDecoration.defaultDecorations.map((decor) {
      final isUnlocked = decor.unlockLevel <= progress.currentLevel;
      return decor.copyWith(isEquipped: isUnlocked);
    }).toList();

    return WorldState(
      isLampOn: currentHour < 7 || currentHour >= 18,
      currentHour: currentHour,
      isRaining: false,
      decorations: availableDecorations,
    );
  }

  void toggleLamp() {
    state = state.copyWith(isLampOn: !state.isLampOn);
  }

  void setWeather({required bool isRaining}) {
    state = state.copyWith(isRaining: isRaining);
  }

  void focusHotspot(String? hotspotId) {
    state = state.copyWith(focusedHotspotId: hotspotId);
  }

  void clearFocus() {
    state = state.copyWith(focusedHotspotId: null);
  }
}

final worldProvider = NotifierProvider<WorldNotifier, WorldState>(() {
  return WorldNotifier();
});
