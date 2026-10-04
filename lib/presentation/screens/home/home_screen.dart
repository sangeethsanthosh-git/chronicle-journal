import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/desk_theme.dart';
import '../../../core/widgets/cassette_tape_widget.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/polaroid_card.dart';
import '../../../core/widgets/postcard_editor_dialog.dart';
import '../../../core/widgets/postal_stamp.dart';
import '../../../core/widgets/ring_binder_frame.dart';
import '../../../core/widgets/torn_paper_card.dart';
import '../../../core/widgets/vintage_postcard_widget.dart';
import '../../../core/widgets/vintage_rubber_stamp.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../providers/database_provider.dart';
import '../../providers/desk_theme_provider.dart';
import '../../providers/journal_providers.dart';
import '../../providers/memories_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../../features/soundtrack/presentation/widgets/now_playing_music_banner.dart';

enum HomeDeskMode { ringBinder, postcardRack }

/// The primary Home Screen built entirely around the tactile physical
/// Ring-Binder Journal & Scrapbook / Postcard interface from reference Images 1-4:
/// - Open 3-ring binder on calm slate-blue desk with metallic binder rings
/// - Paperclipped notes, polaroid photos, and washi tapes
/// - Retro cassette tape player for voice memos
/// - Distressed circular rubber stamps and postal cancellation postmarks
/// - Bottom desk reminder quote bar: "reminder: progress matters more than perfection."
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeDeskMode _deskMode = HomeDeskMode.ringBinder;
  int _quoteIndex = 0;

  static const List<String> _deskQuotes = [
    'reminder: progress matters more than perfection.',
    'every day holds a memory waiting to be preserved.',
    'write what you cannot say aloud.',
    'small moments build a lifetime of wonder.',
    'be gentle with yourself on this page.',
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _cycleQuote() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _deskQuotes.length;
    });
  }

  void _showDeskThemePicker(BuildContext context) {
    final currentTheme = ref.read(deskThemeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFBF8EE),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🎨 Select Desk Surface',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2621),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFDED6C4)),
                const SizedBox(height: 6),
                ...DeskThemeType.values.map((themeType) {
                  final themeData = DeskThemeData.getTheme(themeType);
                  final isSelected = themeType == currentTheme;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: themeData.deskColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC5A059)
                              : Colors.black26,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      themeData.name,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: const Color(0xFF2C2621),
                      ),
                    ),
                    subtitle: Text(
                      themeData.description,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'serif',
                        color: Color(0xFF6E655F),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFFC5A059),
                          )
                        : null,
                    onTap: () {
                      ref.read(deskThemeProvider.notifier).setTheme(themeType);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deskThemeType = ref.watch(deskThemeProvider);
    final deskTheme = DeskThemeData.getTheme(deskThemeType);
    final todayEntry = ref.watch(todayEntryProvider);
    final stats = ref.watch(statisticsProvider);
    final memories = ref.watch(memoriesProvider);
    final recentEntries = ref.watch(filteredEntriesProvider);
    final activeQuote = _deskQuotes[_quoteIndex];

    return Scaffold(
      backgroundColor: deskTheme.deskColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MIORA',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2.2,
                  color: Color(0xFFFAF7EE),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5A059),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'VOL. 1',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shelves, color: Colors.white),
            tooltip: 'Journal Stack (Bookshelf)',
            onPressed: () => context.push('/journal-stack'),
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
            tooltip: 'Read as Physical Book',
            onPressed: () => context.push('/book-reader'),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            tooltip: 'Search Archive',
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            tooltip: 'More Options',
            onSelected: (val) {
              if (val == 'theme') {
                _showDeskThemePicker(context);
              } else if (val == 'mode') {
                setState(() {
                  _deskMode = _deskMode == HomeDeskMode.ringBinder
                      ? HomeDeskMode.postcardRack
                      : HomeDeskMode.ringBinder;
                });
              } else if (val == 'stack') {
                context.push('/journal-stack');
              } else if (val == 'collections') {
                context.push('/collections');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stack',
                child: Row(
                  children: [
                    Icon(Icons.shelves, size: 18),
                    SizedBox(width: 8),
                    Text('Journal Stack'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Desk: ${deskTheme.name}'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mode',
                child: Row(
                  children: [
                    Icon(
                      _deskMode == HomeDeskMode.ringBinder
                          ? Icons.markunread_mailbox_outlined
                          : Icons.auto_stories_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _deskMode == HomeDeskMode.ringBinder
                          ? 'Postcard Rack Mode'
                          : 'Ring Binder Mode',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'collections',
                child: Row(
                  children: [
                    Icon(Icons.collections_bookmark_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Collections'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _deskMode == HomeDeskMode.ringBinder
          ? RingBinderFrame(
              deskColor: deskTheme.deskColor,
              paperColor: deskTheme.paperColor,
              reminderQuote: activeQuote,
              onReminderTap: _cycleQuote,
              isDualSpread: false,
              child: _buildBinderPageContent(
                context,
                todayEntry: todayEntry,
                stats: stats,
                memories: memories,
                recentEntries: recentEntries,
              ),
            )
          : _buildPostcardRackView(context, recentEntries: recentEntries),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C2621),
        foregroundColor: const Color(0xFFFAF7EE),
        tooltip: 'Write New Entry',
        onPressed: () => context.push('/editor'),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  /// The scrollable page content resting inside the 3-ring binder
  Widget _buildBinderPageContent(
    BuildContext context, {
    required dynamic todayEntry,
    required dynamic stats,
    required List<dynamic> memories,
    required List<dynamic> recentEntries,
  }) {
    final now = DateTime.now();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allEntriesStreamProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // 1. Header Stamp, Greeting & Postal Cancellation Mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1A17),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(now),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF453D37),
                      ),
                    ),
                  ],
                ),
              ),
              // Postal cancellation stamp in the corner
              PostalStamp(
                dateText: DateFormat('dd.MM.yy').format(now),
                locationText: 'MIORA',
                size: 44,
                color: AppColors.postalStampBlue,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Tactile Stationery Action Strip (pinned like index tabs)
          _buildStationeryTabs(context),

          const SizedBox(height: 10),

          // 2a. Live Soundtrack Music Banner
          const NowPlayingMusicBanner(showHintWhenIdle: true),

          const SizedBox(height: 10),

          // 2b. Physical Illustrated Bookshelf Shortcut Banner
          _buildJournalStackBanner(context),

          const SizedBox(height: 18),

          // 3. Today's Entry Section (Image 4: Pinned with paperclip or taped)
          _buildTodayBinderSection(context, todayEntry),

          const SizedBox(height: 20),

          // 4. Streak & Vintage Star Rubber Stamp Seal (Image 2)
          _buildStreakAndSealSection(stats),

          const SizedBox(height: 22),

          // 5. Memories & Pinned Keepsakes ("On This Day")
          if (memories.isNotEmpty) ...[
            _buildMemoriesSection(context, memories),
            const SizedBox(height: 22),
          ],

          // 6. Recent Journal Pages (Binder Archive)
          _buildRecentPagesSection(context, recentEntries),
        ],
      ),
    );
  }

  /// Tactile stationery tab strip (Write, Voice Memo, Polaroid, Mood)
  Widget _buildStationeryTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECE1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCD2C0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabButton(
            icon: Icons.edit_note_rounded,
            label: 'Write',
            onTap: () => context.push('/editor'),
          ),
          _buildTabDivider(),
          _buildTabButton(
            icon: Icons.mic_none_rounded,
            label: 'Cassette Memo',
            onTap: () => context.push('/editor?recordAudio=true'),
          ),
          _buildTabDivider(),
          _buildTabButton(
            icon: Icons.camera_alt_outlined,
            label: 'Polaroid',
            onTap: () => context.push('/editor?pickPhoto=true'),
          ),
          _buildTabDivider(),
          _buildTabButton(
            icon: Icons.mood_rounded,
            label: 'Mood Seal',
            onTap: () => context.push('/editor?focusMood=true'),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalStackBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/journal-stack'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2E8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDECDB7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2218),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shelves,
                color: Color(0xFFFAF7EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOURNAL STACK',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF1E1A17),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Browse volumes on the physical bookshelf',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: Color(0xFF453D37),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFF8C7355),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabDivider() {
    return Container(width: 1, height: 24, color: const Color(0xFFD4C8B5));
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF8B2635)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4036),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Today's Entry presentation:
  /// If written: renders with washi tape, paperclip, photo polaroid, and cassette player!
  /// If not written: renders torn prompt card pinned with metallic PaperclipWidget.
  Widget _buildTodayBinderSection(BuildContext context, dynamic todayEntry) {
    if (todayEntry == null) {
      // Unwritten today page with silver paperclip clasping the prompt note
      return TornPaperCard(
        pinnedWithPaperclip: true,
        backgroundColor: const Color(0xFFFFFDF8),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('🖋️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text(
                  'TODAY\'S CLEAN PAGE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Color(0xFF2C2621),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'How was your day? Record your thoughts, quiet observations, and memories before the night falls.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF5E544A),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2621),
                foregroundColor: const Color(0xFFFAF7EE),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => context.push('/editor'),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text(
                'Pick up the pen & write',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Today's completed entry inside binder
    final entry = todayEntry.entry;
    final photos = todayEntry.photoAttachments;
    final audio = todayEntry.audioAttachments;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDED6C4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with washi tape & mood
          Row(
            children: [
              const WashiTape(
                width: 55,
                height: 14,
                rotationDegrees: -3,
                color: AppColors.washiTapeRose,
              ),
              const Spacer(),
              MoodBadge(mood: todayEntry.mood, intensity: entry.moodIntensity),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          if (entry.title.isNotEmpty) ...[
            Text(
              entry.title,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C2621),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Content snippet
          Text(
            entry.content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF3C352D),
            ),
          ),

          // Taped Polaroid Photo if present
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 14),
            Center(
              child: PolaroidCard(
                imagePath: photos.first.uri,
                caption: photos.first.caption,
                pinnedWithPaperclip: true,
                width: 170,
              ),
            ),
          ],

          // Retro Audio Cassette Tape if voice memo present
          if (audio.isNotEmpty) ...[
            const SizedBox(height: 12),
            CassetteTapeWidget(
              audioPath: audio.first.uri,
              label: 'TODAY\'S VOICE MEMO',
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5DDD0)),

          // Actions: Read in Book & Edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.auto_stories_outlined, size: 16),
                label: const Text('Read in Book'),
                onPressed: () => context.push('/book-reader?id=${entry.id}'),
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Page'),
                onPressed: () => context.push('/editor?id=${entry.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Streak counter with authentic distressed vintage rubber stamp seal (Image 2)
  Widget _buildStreakAndSealSection(dynamic stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5EA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2DACB)),
      ),
      child: Row(
        children: [
          // Circular Distressed Rubber Stamp Seal
          const VintageRubberStamp(
            size: 60,
            text: 'MIORA ARCHIVE • BESPOKE QUALITY',
            centerText: 'ACTIVE',
            color: Color(0xFF8B2635),
            rotationDegrees: -8,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreak} Day Writing Streak',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1A17),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stats.longestStreak > 0
                      ? 'Best streak: ${stats.longestStreak} days preserved'
                      : 'Every day recorded keeps the archive alive.',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    color: Color(0xFF453D37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Keepsakes & Memories Section ("On This Day")
  Widget _buildMemoriesSection(BuildContext context, List<dynamic> memories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Keepsakes & Memories',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2621),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/memories'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              final item = memory.entry;
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDED6C4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push('/entry/${item.entry.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const WashiTape(
                            width: 40,
                            height: 12,
                            color: AppColors.washiTapeSage,
                          ),
                          Text(
                            memory.timeAgoDescription,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC5A059),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.entry.title.isEmpty
                            ? 'Untitled Moment'
                            : item.entry.title,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2621),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          item.entry.content,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 11,
                            height: 1.4,
                            color: Color(0xFF6E655F),
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Recent Pages Section in the Binder
  Widget _buildRecentPagesSection(
    BuildContext context,
    List<dynamic> recentEntries,
  ) {
    if (recentEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Your binder is empty.\nTap + below to start your personal archive.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 13,
              color: Color(0xFF8B8279),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Binder Pages',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2621),
          ),
        ),
        const SizedBox(height: 8),
        ...recentEntries.take(5).map((entryDetails) {
          final entry = entryDetails.entry;
          final photos = entryDetails.photoAttachments;
          final audio = entryDetails.audioAttachments;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDED6C4)),
            ),
            child: InkWell(
              onTap: () => context.push('/entry/${entry.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(entry.entryDate),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A6F62),
                        ),
                      ),
                      MoodBadge(
                        mood: entryDetails.mood,
                        intensity: entry.moodIntensity,
                        showLabel: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (entry.title.isNotEmpty) ...[
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2621),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 12.5,
                      color: Color(0xFF5E544A),
                      height: 1.45,
                    ),
                  ),
                  if (photos.isNotEmpty || audio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (photos.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 14,
                                  color: Color(0xFF8B8279),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${photos.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (audio.isNotEmpty)
                          Row(
                            children: const [
                              Icon(
                                Icons.audiotrack_outlined,
                                size: 14,
                                color: Color(0xFF8B8279),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Audio Memo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// The Postcard Rack view (reproducing Image 1 across recent entries)
  Widget _buildPostcardRackView(
    BuildContext context, {
    required List<dynamic> recentEntries,
  }) {
    if (recentEntries.isEmpty) {
      return const Center(
        child: Text(
          'No postcards in the rack yet.\nWrite a journal entry with a photo to create one!',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            color: Color(0xFFFAF7EE),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: recentEntries.length,
      itemBuilder: (context, index) {
        final item = recentEntries[index];
        final entry = item.entry;
        final photoPath = item.photoAttachments.isNotEmpty
            ? item.photoAttachments.first.uri
            : null;

        return VintagePostcardWidget(
          imagePath: photoPath,
          message: entry.content,
          date: entry.entryDate,
          location: entry.locationName ?? 'CHRONICLE POST',
          recipient: 'To: Dear Future Self',
          isEditable: true,
          onEdit: () {
            PostcardEditorDialog.show(
              context,
              initialData: PostcardCustomizationData(
                message: entry.content,
                recipient: 'To: Dear Future Self',
                location: entry.locationName ?? 'CHRONICLE POST',
                date: entry.entryDate,
                imagePath: photoPath,
              ),
              onSave: (customized) async {
                final repo = ref.read(journalRepositoryProvider);
                await repo.saveEntry(
                  id: entry.id,
                  title: entry.title,
                  content: customized.message,
                  entryDate: entry.entryDate,
                  mood: entry.mood,
                  moodIntensity: entry.moodIntensity,
                  isFavorite: entry.isFavorite,
                  locationName: customized.location,
                  latitude: entry.latitude,
                  longitude: entry.longitude,
                  weatherSummary: entry.weatherSummary,
                  weatherTemperature: entry.weatherTemperature,
                  coverImageUri: entry.coverImageUri,
                  layout: entry.layout,
                  paperStyle: entry.paperStyle,
                  tagIds: item.tags.map((t) => t.id).toList(),
                  photoPaths: item.photoAttachments.map((a) => a.uri).toList(),
                  audioPaths: item.audioAttachments.map((a) => a.uri).toList(),
                );
                ref.invalidate(allEntriesStreamProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✉️ Postcard updated & preserved!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
          onTap: () => context.push('/entry/${entry.id}'),
        );
      },
    );
  }
}
