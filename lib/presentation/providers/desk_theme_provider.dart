import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/desk_theme.dart';

final deskThemeProvider = NotifierProvider<DeskThemeNotifier, DeskThemeType>(
  () {
    return DeskThemeNotifier();
  },
);

class DeskThemeNotifier extends Notifier<DeskThemeType> {
  static const _prefKey = 'selected_desk_theme';

  @override
  DeskThemeType build() {
    _loadFromPrefs();
    return DeskThemeType.slateBlue;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        final match = DeskThemeType.values.firstWhere(
          (t) => t.name == saved,
          orElse: () => DeskThemeType.slateBlue,
        );
        state = match;
      }
    } catch (_) {}
  }

  Future<void> setTheme(DeskThemeType type) async {
    state = type;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, type.name);
    } catch (_) {}
  }
}
