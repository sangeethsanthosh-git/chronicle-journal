import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/journal_layout.dart';
import '../../domain/models/paper_style.dart';
import '../../domain/repositories/preferences_repository.dart';
import 'database_provider.dart';

class PreferencesNotifier extends Notifier<UserPreferences> {
  late final PreferencesRepository _repo;

  @override
  UserPreferences build() {
    _repo = ref.watch(preferencesRepositoryProvider);
    _load();
    return const UserPreferences();
  }

  Future<void> _load() async {
    final prefs = await _repo.loadPreferences();
    state = prefs;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.setThemeMode(mode);
  }

  Future<void> setDefaultLayout(JournalLayout layout) async {
    state = state.copyWith(defaultLayout: layout);
    await _repo.setDefaultLayout(layout);
  }

  Future<void> setDefaultPaperStyle(PaperStyle style) async {
    state = state.copyWith(defaultPaperStyle: style);
    await _repo.setDefaultPaperStyle(style);
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    state = state.copyWith(isAppLockEnabled: enabled);
    await _repo.setAppLockEnabled(enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    state = state.copyWith(isBiometricEnabled: enabled);
    await _repo.setBiometricEnabled(enabled);
  }

  Future<void> setReminderEnabled(bool enabled) async {
    state = state.copyWith(isReminderEnabled: enabled);
    await _repo.setReminderEnabled(enabled);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _repo.setReminderTime(hour, minute);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    state = state.copyWith(isOnboardingCompleted: completed);
    await _repo.setOnboardingCompleted(completed);
  }

  Future<void> setShowQuotes(bool show) async {
    state = state.copyWith(showQuotes: show);
    await _repo.setShowQuotes(show);
  }

  Future<void> setMusicIntegrationEnabled(bool enabled) async {
    state = state.copyWith(isMusicIntegrationEnabled: enabled);
    await _repo.setMusicIntegrationEnabled(enabled);
  }

  Future<void> setReaderBackground({
    required String mode,
    required String asset,
    String? customPath,
  }) async {
    state = state.copyWith(
      readerBackgroundMode: mode,
      readerBackgroundAsset: asset,
      readerCustomImagePath: customPath,
      clearCustomImagePath: customPath == null,
    );
    await _repo.setReaderBackground(
      mode: mode,
      asset: asset,
      customPath: customPath,
    );
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, UserPreferences>(() {
      return PreferencesNotifier();
    });
