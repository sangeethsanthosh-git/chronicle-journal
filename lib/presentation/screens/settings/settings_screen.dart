import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/desk_theme.dart';
import '../../../core/utils/backup_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/journal_layout.dart';
import '../../../domain/models/paper_style.dart';
import '../../../features/soundtrack/presentation/providers/soundtrack_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/desk_theme_provider.dart';
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
                  Consumer(
                    builder: (context, ref, _) {
                      final deskThemeType = ref.watch(deskThemeProvider);
                      final deskTheme = DeskThemeData.getTheme(deskThemeType);
                      return ListTile(
                        leading: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: deskTheme.deskColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFC5A059),
                              width: 1.5,
                            ),
                          ),
                        ),
                        title: const Text(
                          'Desk & Study Environment',
                          style: TextStyle(fontFamily: 'serif'),
                        ),
                        subtitle: Text(
                          '${deskTheme.name} • ${deskTheme.description}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: DropdownButton<DeskThemeType>(
                          value: deskThemeType,
                          underline: const SizedBox.shrink(),
                          onChanged: (theme) {
                            if (theme != null) {
                              ref
                                  .read(deskThemeProvider.notifier)
                                  .setTheme(theme);
                            }
                          },
                          items: DeskThemeType.values.map((t) {
                            final data = DeskThemeData.getTheme(t);
                            return DropdownMenuItem(
                              value: t,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: data.deskColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  Text(
                                    data.name,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
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

            // Integrations Section
            _buildSectionHeader('Integrations'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.music_note_outlined),
                    title: const Text(
                      'Detect currently playing music',
                      style: TextStyle(fontFamily: 'serif'),
                    ),
                    subtitle: const Text(
                      'Journal can optionally read information about the music currently playing on your device so you can attach it to your memories.',
                    ),
                    value: prefs.isMusicIntegrationEnabled,
                    onChanged: (val) async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setMusicIntegrationEnabled(val);
                      if (val) {
                        final musicService = ref.read(musicServiceProvider);
                        final hasPerm = await musicService.hasPermission();
                        if (!hasPerm && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Android requires Notification Access to detect media playback. Enable Miora in system settings.',
                              ),
                              action: SnackBarAction(
                                label: 'Settings',
                                onPressed: () =>
                                    musicService.requestPermission(),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  if (prefs.isMusicIntegrationEnabled) ...[
                    const Divider(height: 1),
                    Consumer(
                      builder: (context, ref, _) {
                        final availAsync = ref.watch(musicAvailabilityProvider);
                        final permAsync = ref.watch(musicPermissionProvider);

                        final isAvailable = availAsync.value ?? true;
                        final hasPermission = permAsync.value ?? false;

                        if (!isAvailable) {
                          return const ListTile(
                            leading: Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                            ),
                            title: Text("Music detection isn't available."),
                            subtitle: Text(
                              'Media session inspection is only supported on Android devices.',
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    hasPermission
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_rounded,
                                    size: 18,
                                    color: hasPermission
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      hasPermission
                                          ? 'Notification access granted. Ready to detect tracks.'
                                          : 'Notification access required by Android to read active media sessions.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hasPermission
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (!hasPermission)
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(musicServiceProvider)
                                            .requestPermission();
                                      },
                                      icon: const Icon(
                                        Icons.settings_outlined,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Grant Access in Settings',
                                      ),
                                    ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final track = await ref
                                          .read(musicServiceProvider)
                                          .getCurrentTrack();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              track != null
                                                  ? 'Now Playing: ${track.title} by ${track.artist ?? "Unknown"}'
                                                  : 'No active media session detected right now.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.vintageGold,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(
                                      Icons.play_circle_outline,
                                      size: 16,
                                    ),
                                    label: const Text('Test Track Detection'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
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
                    'Miora v1.0.0',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark
                          ? AppColors.inkPrimaryDark
                          : AppColors.inkPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your thoughts. Your moments. Your story.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.inkSecondaryDark
                          : AppColors.inkSecondaryLight,
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
