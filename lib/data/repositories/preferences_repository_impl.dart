import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/journal_layout.dart';
import '../../domain/models/paper_style.dart';
import '../../domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  static const _keyTheme = 'theme_mode';
  static const _keyLayout = 'default_layout';
  static const _keyPaper = 'default_paper_style';
  static const _keyLock = 'app_lock_enabled';
  static const _keyBiometric = 'biometric_enabled';
  static const _keyReminder = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _keyOnboarding = 'onboarding_completed';
  static const _keyQuotes = 'show_quotes';
  static const _keyMusicIntegration = 'music_integration_enabled';
  static const _keyReaderBgMode = 'reader_bg_mode';
  static const _keyReaderBgAsset = 'reader_bg_asset';
  static const _keyReaderCustomImg = 'reader_custom_img_path';

  @override
  Future<UserPreferences> loadPreferences() async {
    final sp = await SharedPreferences.getInstance();

    final themeStr = sp.getString(_keyTheme) ?? 'system';
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () => ThemeMode.system,
    );

    final layoutStr = sp.getString(_keyLayout);
    final layout = JournalLayout.fromString(layoutStr);

    final paperStr = sp.getString(_keyPaper);
    final paper = PaperStyle.fromString(paperStr);

    return UserPreferences(
      themeMode: themeMode,
      defaultLayout: layout,
      defaultPaperStyle: paper,
      isAppLockEnabled: sp.getBool(_keyLock) ?? false,
      isBiometricEnabled: sp.getBool(_keyBiometric) ?? false,
      isReminderEnabled: sp.getBool(_keyReminder) ?? false,
      reminderHour: sp.getInt(_keyHour) ?? 21,
      reminderMinute: sp.getInt(_keyMinute) ?? 0,
      isOnboardingCompleted: sp.getBool(_keyOnboarding) ?? false,
      showQuotes: sp.getBool(_keyQuotes) ?? true,
      isMusicIntegrationEnabled: sp.getBool(_keyMusicIntegration) ?? true,
      readerBackgroundMode: sp.getString(_keyReaderBgMode) ?? 'asset',
      readerBackgroundAsset:
          sp.getString(_keyReaderBgAsset) ?? 'assets/botanical_deer.jpg',
      readerCustomImagePath: sp.getString(_keyReaderCustomImg),
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyTheme, mode.name);
  }

  @override
  Future<void> setDefaultLayout(JournalLayout layout) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyLayout, layout.name);
  }

  @override
  Future<void> setDefaultPaperStyle(PaperStyle style) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyPaper, style.name);
  }

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyLock, enabled);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyBiometric, enabled);
  }

  @override
  Future<void> setReminderEnabled(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyReminder, enabled);
  }

  @override
  Future<void> setReminderTime(int hour, int minute) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_keyHour, hour);
    await sp.setInt(_keyMinute, minute);
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyOnboarding, completed);
  }

  @override
  Future<void> setShowQuotes(bool show) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyQuotes, show);
  }

  @override
  Future<void> setMusicIntegrationEnabled(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyMusicIntegration, enabled);
  }

  @override
  Future<void> setReaderBackground({
    required String mode,
    required String asset,
    String? customPath,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyReaderBgMode, mode);
    await sp.setString(_keyReaderBgAsset, asset);
    if (customPath != null) {
      await sp.setString(_keyReaderCustomImg, customPath);
    } else {
      await sp.remove(_keyReaderCustomImg);
    }
  }
}
