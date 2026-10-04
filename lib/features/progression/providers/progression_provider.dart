import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/achievement_data.dart';
import '../domain/models/user_progress_data.dart';

const String _kUserProgressKey = 'chronicle_user_progress_v1';

class ProgressionNotifier extends Notifier<UserProgressData> {
  @override
  UserProgressData build() {
    _loadFromStorage();
    return const UserProgressData();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kUserProgressKey);
      if (raw != null) {
        state = UserProgressData.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> _saveToStorage(UserProgressData data) async {
    state = data;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUserProgressKey, jsonEncode(data.toJson()));
    } catch (_) {}
  }

  /// Awards Thought XP and recalculates Sanctuary level.
  Future<bool> awardXp(int xpAmount, {String? reason}) async {
    final newXp = state.totalXp + xpAmount;
    final newLevel = 1 + (newXp ~/ 100);
    final didLevelUp = newLevel > state.currentLevel;

    final updated = state.copyWith(
      totalXp: newXp,
      currentLevel: newLevel,
      lastJournalDate: DateTime.now(),
    );

    await _saveToStorage(updated);
    return didLevelUp;
  }

  Future<void> recordEntryWritten() async {
    await awardXp(25, reason: 'Journal Entry Written');
    final updated = state.copyWith(
      totalEntriesWritten: state.totalEntriesWritten + 1,
      lastJournalDate: DateTime.now(),
    );
    await _saveToStorage(updated);
  }

  Future<void> recordPhotoSaved() async {
    await awardXp(10, reason: 'Photo Memory Preserved');
    final updated = state.copyWith(
      totalMemoriesSaved: state.totalMemoriesSaved + 1,
    );
    await _saveToStorage(updated);
  }

  Future<void> recordScrapbookCreated() async {
    await awardXp(30, reason: 'Scrapbook Page Created');
    final updated = state.copyWith(
      totalScrapbooksCreated: state.totalScrapbooksCreated + 1,
    );
    await _saveToStorage(updated);
  }

  Future<void> recordVoiceReflection() async {
    await awardXp(15, reason: 'Voice Reflection Recorded');
  }
}

final userProgressProvider =
    NotifierProvider<ProgressionNotifier, UserProgressData>(() {
      return ProgressionNotifier();
    });

/// Provider for list of achievements and unlock checks.
final achievementsProvider = Provider<List<AchievementData>>((ref) {
  final progress = ref.watch(userProgressProvider);
  return AchievementData.defaults.map((achievement) {
    final unlocked = progress.totalXp >= achievement.requiredXp;
    return achievement.copyWith(isUnlocked: unlocked);
  }).toList();
});
