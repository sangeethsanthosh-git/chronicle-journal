import 'package:flutter/material.dart';
import '../models/journal_layout.dart';
import '../models/paper_style.dart';

class UserPreferences {
  final ThemeMode themeMode;
  final JournalLayout defaultLayout;
  final PaperStyle defaultPaperStyle;
  final bool isAppLockEnabled;
  final bool isBiometricEnabled;
  final bool isReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool isOnboardingCompleted;
  final bool showQuotes;
  final bool isMusicIntegrationEnabled;
  final String readerBackgroundMode; // 'asset', 'custom', 'desk'
  final String readerBackgroundAsset; // e.g. 'assets/botanical_deer.jpg'
  final String? readerCustomImagePath;

  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.defaultLayout = JournalLayout.classic,
    this.defaultPaperStyle = PaperStyle.plain,
    this.isAppLockEnabled = false,
    this.isBiometricEnabled = false,
    this.isReminderEnabled = false,
    this.reminderHour = 21,
    this.reminderMinute = 0,
    this.isOnboardingCompleted = false,
    this.showQuotes = true,
    this.isMusicIntegrationEnabled = true,
    this.readerBackgroundMode = 'asset',
    this.readerBackgroundAsset = 'assets/botanical_deer.jpg',
    this.readerCustomImagePath,
  });

  UserPreferences copyWith({
    ThemeMode? themeMode,
    JournalLayout? defaultLayout,
    PaperStyle? defaultPaperStyle,
    bool? isAppLockEnabled,
    bool? isBiometricEnabled,
    bool? isReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? isOnboardingCompleted,
    bool? showQuotes,
    bool? isMusicIntegrationEnabled,
    String? readerBackgroundMode,
    String? readerBackgroundAsset,
    String? readerCustomImagePath,
    bool clearCustomImagePath = false,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      defaultLayout: defaultLayout ?? this.defaultLayout,
      defaultPaperStyle: defaultPaperStyle ?? this.defaultPaperStyle,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      showQuotes: showQuotes ?? this.showQuotes,
      isMusicIntegrationEnabled:
          isMusicIntegrationEnabled ?? this.isMusicIntegrationEnabled,
      readerBackgroundMode: readerBackgroundMode ?? this.readerBackgroundMode,
      readerBackgroundAsset:
          readerBackgroundAsset ?? this.readerBackgroundAsset,
      readerCustomImagePath: clearCustomImagePath
          ? null
          : (readerCustomImagePath ?? this.readerCustomImagePath),
    );
  }
}

abstract class PreferencesRepository {
  Future<UserPreferences> loadPreferences();
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setDefaultLayout(JournalLayout layout);
  Future<void> setDefaultPaperStyle(PaperStyle style);
  Future<void> setAppLockEnabled(bool enabled);
  Future<void> setBiometricEnabled(bool enabled);
  Future<void> setReminderEnabled(bool enabled);
  Future<void> setReminderTime(int hour, int minute);
  Future<void> setOnboardingCompleted(bool completed);
  Future<void> setShowQuotes(bool show);
  Future<void> setMusicIntegrationEnabled(bool enabled);
  Future<void> setReaderBackground({
    required String mode,
    required String asset,
    String? customPath,
  });
}
