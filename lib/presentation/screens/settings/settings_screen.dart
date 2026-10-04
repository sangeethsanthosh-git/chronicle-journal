import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/backup_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/journal_layout.dart';
import '../../../domain/models/paper_style.dart';
import '../../providers/database_provider.dart';
import '../../providers/preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Settings & Preferences',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance & Aesthetics'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text(
                      'Theme Mode',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: Text(prefs.themeMode.name.toUpperCase()),
                    trailing: DropdownButton<ThemeMode>(
                      value: prefs.themeMode,
                      underline: const SizedBox.shrink(),
                      onChanged: (mode) {
                        if (mode != null) {
                          ref
                              .read(preferencesProvider.notifier)
                              .setThemeMode(mode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.line_weight_rounded),
                    title: const Text(
                      'Default Paper Texture',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: Text(prefs.defaultPaperStyle.label),
                    trailing: DropdownButton<PaperStyle>(
                      value: prefs.defaultPaperStyle,
                      underline: const SizedBox.shrink(),
                      onChanged: (style) {
                        if (style != null) {
                          ref
                              .read(preferencesProvider.notifier)
                              .setDefaultPaperStyle(style);
                        }
                      },
                      items: PaperStyle.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.label));
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.auto_stories_outlined),
                    title: const Text(
                      'Default Journal Layout',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: Text(prefs.defaultLayout.label),
                    trailing: DropdownButton<JournalLayout>(
                      value: prefs.defaultLayout,
                      underline: const SizedBox.shrink(),
                      onChanged: (layout) {
                        if (layout != null) {
                          ref
                              .read(preferencesProvider.notifier)
                              .setDefaultLayout(layout);
                        }
                      },
                      items: JournalLayout.values.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l.label));
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.format_quote_outlined),
                    title: const Text(
                      'Daily Reflective Quotes',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Show inspiring literary prompts on home screen',
                    ),
                    value: prefs.showQuotes,
                    onChanged: (val) {
                      ref.read(preferencesProvider.notifier).setShowQuotes(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Privacy & Security Section
            _buildSectionHeader('Privacy & Security'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.lock_outline),
                    title: const Text(
                      'App Lock (4-Digit PIN)',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Require secret PIN on application launch',
                    ),
                    value: prefs.isAppLockEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final sec = ref.read(securityServiceProvider);
                        final hasPin = await sec.isPinSet();
                        if (!hasPin && context.mounted) {
                          context.push('/lock?setPin=true');
                        }
                      }
                      ref
                          .read(preferencesProvider.notifier)
                          .setAppLockEnabled(val);
                    },
                  ),
                  if (prefs.isAppLockEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.password_rounded),
                      title: const Text(
                        'Change Security PIN',
                        style: TextStyle(fontFamily: 'serif'),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/lock?setPin=true'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Daily Reminders Section
            _buildSectionHeader('Gentle Reminders'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text(
                      'Daily Journal Reminder',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: Text(
                      prefs.isReminderEnabled
                          ? 'Scheduled for ${TimeOfDay(hour: prefs.reminderHour, minute: prefs.reminderMinute).format(context)}'
                          : 'Receive a subtle reminder to reflect',
                    ),
                    value: prefs.isReminderEnabled,
                    onChanged: (val) async {
                      ref
                          .read(preferencesProvider.notifier)
                          .setReminderEnabled(val);
                      if (val) {
                        await NotificationService.scheduleDailyReminder(
                          hour: prefs.reminderHour,
                          minute: prefs.reminderMinute,
                        );
                      } else {
                        await NotificationService.cancelDailyReminder();
                      }
                    },
                  ),
                  if (prefs.isReminderEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time_outlined),
                      title: const Text(
                        'Reminder Time',
                        style: TextStyle(fontFamily: 'serif'),
                      ),
                      trailing: Text(
                        TimeOfDay(
                          hour: prefs.reminderHour,
                          minute: prefs.reminderMinute,
                        ).format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: prefs.reminderHour,
                            minute: prefs.reminderMinute,
                          ),
                        );
                        if (picked != null) {
                          await ref
                              .read(preferencesProvider.notifier)
                              .setReminderTime(picked.hour, picked.minute);
                          await NotificationService.scheduleDailyReminder(
                            hour: picked.hour,
                            minute: picked.minute,
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Backup & Data Export Section
            _buildSectionHeader('Data Portability & Backup'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: const Text(
                      'Export Journal to PDF',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Generate an elegant printable book of your entries',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final entries = await ref
                          .read(journalRepositoryProvider)
                          .getAllEntries();
                      if (entries.isNotEmpty) {
                        await PdfExporter.exportEntriesToPdf(entries);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No journal entries to export.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text(
                      'Export JSON Archive',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Export structured backup file for safekeeping',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final entries = await ref
                          .read(journalRepositoryProvider)
                          .getAllEntries();
                      if (entries.isNotEmpty) {
                        await BackupService.shareJsonBackup(entries);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.text_snippet_outlined),
                    title: const Text(
                      'Export Plaintext (.txt)',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Human-readable compilation of all entries',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final entries = await ref
                          .read(journalRepositoryProvider)
                          .getAllEntries();
                      if (entries.isNotEmpty) {
                        await BackupService.exportAsPlainText(entries);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Chronicle v1.0.0',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.inkSecondaryDark
                          : AppColors.inkSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Offline-first, artisanal journaling for Flutter.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.inkMutedDark
                          : AppColors.inkMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'serif',
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: AppColors.vintageGold,
        ),
      ),
    );
  }
}
