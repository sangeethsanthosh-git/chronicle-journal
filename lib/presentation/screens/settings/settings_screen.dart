import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/desk_theme.dart';
import '../../../core/utils/backup_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/reader_atmosphere_background.dart';
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

    final cardBg = isDark ? const Color(0xFF231C16) : const Color(0xFFFBF8F1);
    final cardBorder = isDark
        ? const Color(0xFF4A3B2C).withAlpha(120)
        : const Color(0xFFC5A059).withAlpha(55);

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings & Atmosphere',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                'Your thoughts. Your moments. Your story.',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.inkSecondaryDark
                      : AppColors.inkSecondaryLight,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // 1. Reader Atmosphere & Wallpaper (FEATURED)
            _buildSectionHeader('Reader Atmosphere & Wallpaper'),
            _buildWallpaperGallery(context, ref, prefs, cardBg, cardBorder),
            const SizedBox(height: 22),

            // 2. Visual Style & Theme
            _buildSectionHeader('Appearance & Aesthetics'),
            _buildAestheticsCard(context, ref, prefs, cardBg, cardBorder),
            const SizedBox(height: 22),

            // 3. Privacy & PIN Lock
            _buildSectionHeader('Privacy & Security'),
            _buildSecurityCard(context, ref, prefs, cardBg, cardBorder),
            const SizedBox(height: 22),

            // 4. Gentle Daily Reminders
            _buildSectionHeader('Gentle Reminders'),
            _buildRemindersCard(context, ref, prefs, cardBg, cardBorder),
            const SizedBox(height: 22),

            // 5. Soundtrack & Music Integration
            _buildSectionHeader('Soundtrack & Music Integration'),
            _buildSoundtrackCard(context, ref, prefs, cardBg, cardBorder),
            const SizedBox(height: 22),

            // 6. Data Portability & Archive
            _buildSectionHeader('Data Portability & Backup'),
            _buildBackupCard(context, ref, cardBg, cardBorder),
            const SizedBox(height: 28),

            // 7. About Miora Branding Footer
            _buildAboutFooter(isDark),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. Reader Atmosphere & Wallpaper Gallery
  // ─────────────────────────────────────────────────────────────

  Widget _buildWallpaperGallery(
    BuildContext context,
    WidgetRef ref,
    dynamic prefs,
    Color cardBg,
    Color cardBorder,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.vintageGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Physical Book Backdrop',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                prefs.readerBackgroundMode == 'custom'
                    ? 'Custom Photo'
                    : prefs.readerBackgroundMode == 'desk'
                        ? 'Desk Timber'
                        : 'Art Gallery',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11,
                  color: AppColors.vintageGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose the backdrop that appears behind your physical book reader. Tap any artwork or pick a custom wallpaper from your gallery.',
            style: TextStyle(fontSize: 12, height: 1.35, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          // Horizontal scroll list of artistic wallpaper options
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                // Presets from assets/
                ...kReaderPresetWallpapers.map((opt) {
                  final isSelected = prefs.readerBackgroundMode == 'asset' &&
                      prefs.readerBackgroundAsset == opt.assetPath;

                  return _buildWallpaperCard(
                    title: opt.title,
                    subtitle: opt.subtitle,
                    isSelected: isSelected,
                    imageWidget: Image.asset(
                      opt.assetPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    onTap: () {
                      ref
                          .read(preferencesProvider.notifier)
                          .setReaderBackground(
                            mode: 'asset',
                            asset: opt.assetPath,
                          );
                    },
                  );
                }),

                // Custom Gallery Image Option
                _buildCustomGalleryCard(
                  context: context,
                  ref: ref,
                  prefs: prefs,
                ),

                // Classic Timber Desk Option
                _buildWallpaperCard(
                  title: 'Classic Desk',
                  subtitle: 'Warm Timber Grain',
                  isSelected: prefs.readerBackgroundMode == 'desk',
                  imageWidget: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF382315),
                          Color(0xFF26180E),
                          Color(0xFF190F08),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.table_restaurant_rounded,
                        color: Color(0xFFC5A059),
                        size: 32,
                      ),
                    ),
                  ),
                  onTap: () {
                    ref.read(preferencesProvider.notifier).setReaderBackground(
                          mode: 'desk',
                          asset: 'assets/botanical_deer.jpg',
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required Widget imageWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.vintageGold : Colors.black12,
            width: isSelected ? 2.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.vintageGold.withAlpha(90)
                  : Colors.black.withAlpha(20),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              // Dark gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                      Colors.black.withAlpha(220),
                    ],
                    stops: const [0.4, 0.75, 1.0],
                  ),
                ),
              ),
              // Selection Badge
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.vintageGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Title and Subtitle
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGalleryCard({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic prefs,
  }) {
    final isSelected = prefs.readerBackgroundMode == 'custom';
    final customPath = prefs.readerCustomImagePath;
    final hasValidFile = customPath != null &&
        customPath.isNotEmpty &&
        File(customPath).existsSync();

    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          ref.read(preferencesProvider.notifier).setReaderBackground(
                mode: 'custom',
                asset: picked.path,
                customPath: picked.path,
              );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.vintageGold : Colors.black12,
            width: isSelected ? 2.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.vintageGold.withAlpha(90)
                  : Colors.black.withAlpha(20),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasValidFile)
                Image.file(
                  File(customPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                Container(
                  color: const Color(0xFF2C241E),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.vintageGold,
                          size: 30,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'From Gallery',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                      Colors.black.withAlpha(220),
                    ],
                    stops: const [0.4, 0.75, 1.0],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.vintageGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              const Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Gallery',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Choose Photo',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. Appearance & Aesthetics Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildAestheticsCard(
    BuildContext context,
    WidgetRef ref,
    dynamic prefs,
    Color cardBg,
    Color cardBorder,
  ) {
    return _buildCard(
      cardBg: cardBg,
      cardBorder: cardBorder,
      children: [
        // Theme Mode Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.palette_outlined, size: 20, color: AppColors.vintageGold),
                  SizedBox(width: 10),
                  Text(
                    'Color Theme',
                    style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildSegmentButton(
                      label: 'System',
                      icon: Icons.brightness_auto_rounded,
                      isSelected: prefs.themeMode == ThemeMode.system,
                      onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeMode.system),
                    ),
                    _buildSegmentButton(
                      label: 'Light',
                      icon: Icons.light_mode_rounded,
                      isSelected: prefs.themeMode == ThemeMode.light,
                      onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeMode.light),
                    ),
                    _buildSegmentButton(
                      label: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      isSelected: prefs.themeMode == ThemeMode.dark,
                      onTap: () => ref.read(preferencesProvider.notifier).setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Default Paper Texture Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.line_weight_rounded, size: 20, color: AppColors.vintageGold),
                      SizedBox(width: 10),
                      Text(
                        'Paper Texture',
                        style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Text(
                    prefs.defaultPaperStyle.label,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: AppColors.vintageGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaperStyle.values.map((style) {
                  final isSelected = prefs.defaultPaperStyle == style;
                  return ChoiceChip(
                    label: Text(style.label),
                    selected: isSelected,
                    selectedColor: AppColors.vintageGold,
                    backgroundColor: Colors.black.withAlpha(10),
                    labelStyle: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        ref.read(preferencesProvider.notifier).setDefaultPaperStyle(style);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Default Journal Layout Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories_outlined, size: 20, color: AppColors.vintageGold),
                      SizedBox(width: 10),
                      Text(
                        'Default Layout',
                        style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Text(
                    prefs.defaultLayout.label,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: AppColors.vintageGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: JournalLayout.values.map((layout) {
                  final isSelected = prefs.defaultLayout == layout;
                  return ChoiceChip(
                    label: Text(layout.label),
                    selected: isSelected,
                    selectedColor: AppColors.vintageGold,
                    backgroundColor: Colors.black.withAlpha(10),
                    labelStyle: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        ref.read(preferencesProvider.notifier).setDefaultLayout(layout);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Desk & Study Surface Theme
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
                    color: AppColors.vintageGold,
                    width: 1.5,
                  ),
                ),
              ),
              title: const Text(
                'Desk Surface Theme',
                style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${deskTheme.name} • ${deskTheme.description}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDeskThemePicker(context, ref, deskThemeType),
            );
          },
        ),
        const Divider(height: 1),

        // Daily Reflective Quotes Toggle
        SwitchListTile(
          secondary: const Icon(Icons.format_quote_outlined, color: AppColors.vintageGold),
          title: const Text(
            'Daily Reflective Quotes',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Inspiring literary prompts on home screen', style: TextStyle(fontSize: 12)),
          value: prefs.showQuotes,
          activeThumbColor: AppColors.vintageGold,
          onChanged: (val) {
            ref.read(preferencesProvider.notifier).setShowQuotes(val);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. Privacy & Security Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildSecurityCard(
    BuildContext context,
    WidgetRef ref,
    dynamic prefs,
    Color cardBg,
    Color cardBorder,
  ) {
    return _buildCard(
      cardBg: cardBg,
      cardBorder: cardBorder,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.lock_outline, color: AppColors.vintageGold),
          title: const Text(
            'App Lock (4-Digit PIN)',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Require secret PIN on application launch',
            style: TextStyle(fontSize: 12),
          ),
          value: prefs.isAppLockEnabled,
          activeThumbColor: AppColors.vintageGold,
          onChanged: (val) async {
            if (val) {
              final sec = ref.read(securityServiceProvider);
              final hasPin = await sec.isPinSet();
              if (!hasPin && context.mounted) {
                context.push('/lock?setPin=true');
              }
            }
            ref.read(preferencesProvider.notifier).setAppLockEnabled(val);
          },
        ),
        if (prefs.isAppLockEnabled) ...[
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.password_rounded, color: AppColors.vintageGold),
            title: const Text(
              'Change Security PIN',
              style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Update your private 4-digit code', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/lock?setPin=true'),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. Gentle Daily Reminders Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildRemindersCard(
    BuildContext context,
    WidgetRef ref,
    dynamic prefs,
    Color cardBg,
    Color cardBorder,
  ) {
    return _buildCard(
      cardBg: cardBg,
      cardBorder: cardBorder,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.vintageGold),
          title: const Text(
            'Daily Journal Reminder',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            prefs.isReminderEnabled
                ? 'Scheduled for ${TimeOfDay(hour: prefs.reminderHour, minute: prefs.reminderMinute).format(context)}'
                : 'Receive a subtle notification to record your day',
            style: const TextStyle(fontSize: 12),
          ),
          value: prefs.isReminderEnabled,
          activeThumbColor: AppColors.vintageGold,
          onChanged: (val) async {
            ref.read(preferencesProvider.notifier).setReminderEnabled(val);
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
            leading: const Icon(Icons.access_time_outlined, color: AppColors.vintageGold),
            title: const Text(
              'Reminder Time',
              style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.vintageGold.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.vintageGold.withAlpha(90)),
              ),
              child: Text(
                TimeOfDay(
                  hour: prefs.reminderHour,
                  minute: prefs.reminderMinute,
                ).format(context),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: AppColors.vintageGold,
                ),
              ),
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
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. Soundtrack & Music Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildSoundtrackCard(
    BuildContext context,
    WidgetRef ref,
    dynamic prefs,
    Color cardBg,
    Color cardBorder,
  ) {
    return _buildCard(
      cardBg: cardBg,
      cardBorder: cardBorder,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.music_note_outlined, color: AppColors.vintageGold),
          title: const Text(
            'Detect Playing Music',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Attach current song title & artist to journal memories on demand',
            style: TextStyle(fontSize: 12),
          ),
          value: prefs.isMusicIntegrationEnabled,
          activeThumbColor: AppColors.vintageGold,
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
                      'Android requires Notification Access to detect media playback. Enable Miora in settings.',
                    ),
                    action: SnackBarAction(
                      label: 'Settings',
                      onPressed: () => musicService.requestPermission(),
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
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Media session inspection is only supported on Android devices.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasPermission
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          size: 18,
                          color: hasPermission ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasPermission
                                ? 'Permission active. Ready to capture tracks.'
                                : 'Notification access required to read media metadata.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: hasPermission ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (!hasPermission) ...[
                          OutlinedButton.icon(
                            onPressed: () => ref.read(musicServiceProvider).requestPermission(),
                            icon: const Icon(Icons.settings_outlined, size: 15),
                            label: const Text('Grant Access', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: () async {
                            final track = await ref.read(musicServiceProvider).getCurrentTrack();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    track != null
                                        ? 'Now Playing: ${track.title} by ${track.artist ?? "Unknown"}'
                                        : 'No active music playback detected on device.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vintageGold,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.play_circle_outline, size: 15),
                          label: const Text('Test Track Detection', style: TextStyle(fontSize: 12)),
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
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 6. Data Portability & Backup Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildBackupCard(
    BuildContext context,
    WidgetRef ref,
    Color cardBg,
    Color cardBorder,
  ) {
    return _buildCard(
      cardBg: cardBg,
      cardBorder: cardBorder,
      children: [
        ListTile(
          leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.vintageGold),
          title: const Text('Export Journal to PDF', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
          subtitle: const Text('Printable illustrated scrapbook reproduction', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final entries = await ref.read(journalRepositoryProvider).getAllEntries();
            if (entries.isNotEmpty) {
              await PdfExporter.exportEntriesToPdf(entries);
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No journal entries to export.')),
              );
            }
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.share_outlined, color: AppColors.vintageGold),
          title: const Text('Export JSON Archive', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
          subtitle: const Text('Complete encrypted database backup for safekeeping', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final entries = await ref.read(journalRepositoryProvider).getAllEntries();
            if (entries.isNotEmpty) {
              await BackupService.shareJsonBackup(entries);
            }
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.text_snippet_outlined, color: AppColors.vintageGold),
          title: const Text('Export Plaintext (.txt)', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
          subtitle: const Text('Human-readable chronological text archive', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final entries = await ref.read(journalRepositoryProvider).getAllEntries();
            if (entries.isNotEmpty) {
              await BackupService.exportAsPlainText(entries);
            }
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────────────────────────

  Widget _buildCard({
    required Color cardBg,
    required Color cardBorder,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: children,
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

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.vintageGold : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.vintageGold.withAlpha(80),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeskThemePicker(
    BuildContext context,
    WidgetRef ref,
    DeskThemeType currentTheme,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Desk Surface',
                  style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ...DeskThemeType.values.map((t) {
                  final data = DeskThemeData.getTheme(t);
                  final isSelected = t == currentTheme;

                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: data.deskColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.vintageGold),
                      ),
                    ),
                    title: Text(data.name, style: const TextStyle(fontFamily: 'serif')),
                    subtitle: Text(data.description, style: const TextStyle(fontSize: 11)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.vintageGold)
                        : null,
                    onTap: () {
                      ref.read(deskThemeProvider.notifier).setTheme(t);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutFooter(bool isDark) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.vintageGold.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.vintageGold,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Miora',
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark ? AppColors.inkPrimaryDark : AppColors.inkPrimaryLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Your thoughts. Your moments. Your story.',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.inkSecondaryDark : AppColors.inkSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Version 1.0.1 • Offline First & End-to-End Private',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
