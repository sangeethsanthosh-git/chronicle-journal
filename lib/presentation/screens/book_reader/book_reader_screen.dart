import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/desk_theme.dart';
import '../../../core/utils/pdf_exporter.dart';
import '../../../core/widgets/book_spread_frame.dart';
import '../../../core/widgets/desk_background.dart';
import '../../../core/widgets/ring_binder_frame.dart';
import '../../../domain/models/journal_entry_with_details.dart';
import '../../../features/journal/presentation/widgets/illustrated_study_environment.dart';
import '../../../features/journal/presentation/widgets/journal_book.dart';
import '../../../features/journal/presentation/widgets/journal_page.dart';
import '../../../features/journal/presentation/widgets/journal_page_spread.dart';
import '../../../features/journal/presentation/widgets/page_turn_controller.dart';
import '../../../features/journal_reader/presentation/widgets/codex_achievements_page.dart';
import '../../../features/journal_reader/presentation/widgets/codex_audio_memo_page.dart';
import '../../../features/journal_reader/presentation/widgets/codex_photo_dossier_page.dart';
import '../../../features/journal_reader/presentation/widgets/codex_tab_header.dart';
import '../../providers/desk_theme_provider.dart';
import '../../providers/journal_providers.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/statistics_provider.dart';
import 'book_page_data.dart';
import '../../../features/soundtrack/presentation/widgets/now_playing_music_banner.dart';
import '../../../features/journal/presentation/widgets/paper_peel_engine.dart';
import '../../../core/widgets/reader_atmosphere_background.dart';
import 'package:image_picker/image_picker.dart';

enum ReaderBindingStyle {
  gameCodex,
  physicalStudy,
  ringBinder,
  hardcover,
  postcard,
}

/// Immersive Book Reader Screen allowing users to read their journal entries
/// like a real physical illustrated notebook resting on a desk (Rebecca Mock style),
/// a game codex notebook with protruding tabs, or as a classic ring binder / hardcover book spread.
class BookReaderScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const BookReaderScreen({super.key, this.entryId});

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  late PageController _pageController;
  late PageTurnController _pageTurnController;
  int _currentPageIndex = 0;
  bool _showControls = true;
  bool _isDualSpread = false;
  bool _isJournalOpen = true;
  ReaderBindingStyle _bindingStyle = ReaderBindingStyle.physicalStudy;
  CodexTab _codexTab = CodexTab.story;
  String? _selectedEntryId;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _selectedEntryId = widget.entryId;
    _pageController = PageController();
    _pageTurnController = PageTurnController();
    _pageTurnController.addListener(_onSpreadChanged);
  }

  void _onSpreadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleOrientation() async {
    final next = !_isLandscape;
    setState(() => _isLandscape = next);
    if (next) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _pageTurnController.removeListener(_onSpreadChanged);
    _pageController.dispose();
    _pageTurnController.dispose();
    super.dispose();
  }

  void _nextPage(int totalPages) {
    if (_currentPageIndex < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  List<JournalPageSpread> _buildJournalSpreads(
    List<JournalEntryWithDetails> entryList,
    DeskThemeData deskTheme,
  ) {
    final spreads = <JournalPageSpread>[];
    int pageCounter = 1;

    // Prioritize selected entry if one was passed in
    final orderedEntries = <JournalEntryWithDetails>[];
    if (_selectedEntryId != null) {
      final selected =
          entryList.where((e) => e.entry.id == _selectedEntryId).toList();
      final others =
          entryList.where((e) => e.entry.id != _selectedEntryId).toList();
      orderedEntries.addAll(selected);
      orderedEntries.addAll(others);
    } else {
      orderedEntries.addAll(entryList);
    }

    for (final item in orderedEntries) {
      final pages = JournalPageContent.fromEntry(item);
      for (int i = 0; i < pages.length; i += 2) {
        final leftContent = pages[i].copyWith(pageNumber: pageCounter++);
        final rightContent = (i + 1 < pages.length)
            ? pages[i + 1].copyWith(pageNumber: pageCounter++)
            : JournalPageContent(
                type: JournalPageType.quoteReflection,
                entry: item,
                title: 'Daily Reflection',
                bodyText:
                    '“Every page turned preserves a piece of your journey.”',
                pageNumber: pageCounter++,
              );

        spreads.add(
          JournalPageSpread(
            leftContent: leftContent,
            rightContent: rightContent,
            paperColor: deskTheme.paperColor,
            onTapLeft: () => _pageTurnController.previousPage(),
            onTapRight: () => _pageTurnController.nextPage(),
          ),
        );
      }
    }

    if (spreads.isEmpty) {
      spreads.add(
        JournalPageSpread(
          leftContent: const JournalPageContent(
            type: JournalPageType.textOpening,
            title: 'Welcome to Miora',
            bodyText:
                'Your thoughts. Your moments. Your story. Tap the pen to write your first entry.',
            pageNumber: 1,
          ),
          rightContent: const JournalPageContent(
            type: JournalPageType.quoteReflection,
            title: 'Daily Reflection',
            bodyText:
                '“Write what you cannot say aloud. Small moments build a lifetime of wonder.”',
            pageNumber: 2,
          ),
          paperColor: deskTheme.paperColor,
        ),
      );
    }

    return spreads;
  }

  List<JournalPageSpread> _buildPostcardSpreads(
    List<JournalEntryWithDetails> entries,
    DeskThemeData deskTheme,
  ) {
    final spreads = <JournalPageSpread>[];
    var pageCounter = 1;

    for (final item in entries) {
      final photoUri = item.photoAttachments.isNotEmpty
          ? item.photoAttachments.first.uri
          : null;

      final leftContent = JournalPageContent(
        type: photoUri != null
            ? JournalPageType.photoMemories
            : JournalPageType.quoteReflection,
        entry: item,
        title: item.entry.locationName ?? 'Vintage Postcard',
        bodyText:
            item.entry.title.isNotEmpty ? item.entry.title : 'Captured Memory',
        photoPaths: photoUri != null ? [photoUri] : const [],
        pageNumber: pageCounter++,
      );

      final rightContent = JournalPageContent(
        type: JournalPageType.textOpening,
        entry: item,
        title: 'Post Card • ${item.entry.locationName ?? "Miora Post"}',
        bodyText: item.entry.content.isNotEmpty
            ? item.entry.content
            : 'A silent memory etched into time.',
        pageNumber: pageCounter++,
      );

      spreads.add(
        JournalPageSpread(
          leftContent: leftContent,
          rightContent: rightContent,
          paperColor: const Color(0xFFFBF7EE),
          onTapLeft: () => _pageTurnController.previousPage(),
          onTapRight: () => _pageTurnController.nextPage(),
        ),
      );
    }

    if (spreads.isEmpty) {
      spreads.add(
        JournalPageSpread(
          leftContent: const JournalPageContent(
            type: JournalPageType.textOpening,
            title: 'Postcard Memory',
            bodyText: 'Your thoughts. Your moments. Your story.',
            pageNumber: 1,
          ),
          rightContent: const JournalPageContent(
            type: JournalPageType.quoteReflection,
            title: 'Miora Post',
            bodyText:
                '“Every postcard carries the warmth of where you have been.”',
            pageNumber: 2,
          ),
          paperColor: const Color(0xFFFBF7EE),
        ),
      );
    }

    return spreads;
  }

  void _showWallpaperPicker(BuildContext context) {
    final prefs = ref.read(preferencesProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFBF8EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🖼️ Reader Atmosphere & Backdrop',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2C241E),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Customize the visual world behind your physical journal.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 135,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...kReaderPresetWallpapers.map((opt) {
                        final isSelected =
                            prefs.readerBackgroundMode == 'asset' &&
                                prefs.readerBackgroundAsset == opt.assetPath;
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(preferencesProvider.notifier)
                                .setReaderBackground(
                                  mode: 'asset',
                                  asset: opt.assetPath,
                                );
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFC5A059)
                                    : Colors.black12,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(opt.assetPath, fit: BoxFit.cover),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withAlpha(190),
                                        ],
                                        stops: const [0.4, 1.0],
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFC5A059),
                                        size: 18,
                                      ),
                                    ),
                                  Positioned(
                                    left: 6,
                                    right: 6,
                                    bottom: 6,
                                    child: Text(
                                      opt.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      // Gallery Button
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            ref
                                .read(preferencesProvider.notifier)
                                .setReaderBackground(
                                  mode: 'custom',
                                  asset: picked.path,
                                  customPath: picked.path,
                                );
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C241E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: prefs.readerBackgroundMode == 'custom'
                                  ? const Color(0xFFC5A059)
                                  : Colors.black12,
                              width: prefs.readerBackgroundMode == 'custom'
                                  ? 2.5
                                  : 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Color(0xFFC5A059),
                                  size: 26,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gallery',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Desk Wood Button
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(preferencesProvider.notifier)
                              .setReaderBackground(
                                mode: 'desk',
                                asset: 'assets/botanical_deer.jpg',
                              );
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFF382315),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: prefs.readerBackgroundMode == 'desk'
                                  ? const Color(0xFFC5A059)
                                  : Colors.black12,
                              width: prefs.readerBackgroundMode == 'desk'
                                  ? 2.5
                                  : 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.table_restaurant_rounded,
                                  color: Color(0xFFC5A059),
                                  size: 26,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Desk Wood',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTableOfContents(
    BuildContext context,
    List<JournalEntryWithDetails> allEntries,
    List<BookPageData> currentPages,
  ) {
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
                      '📖 Table of Contents',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
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
                const SizedBox(height: 8),

                // Pages in current entry
                const Text(
                  'CURRENT ENTRY PAGES',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B8279),
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: List.generate(currentPages.length, (idx) {
                    final isCurrent = idx == _currentPageIndex;
                    return ChoiceChip(
                      label: Text('Page ${idx + 1}'),
                      selected: isCurrent,
                      selectedColor: const Color(0xFFC5A059),
                      backgroundColor: const Color(0xFFEFE9DA),
                      labelStyle: TextStyle(
                        fontFamily: 'serif',
                        color: isCurrent
                            ? Colors.white
                            : const Color(0xFF2C2621),
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        Navigator.pop(context);
                        _pageController.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFDED6C4)),

                // Other entries in journal
                const Text(
                  'OTHER JOURNAL ENTRIES',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B8279),
                  ),
                ),
                const SizedBox(height: 8),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allEntries.length,
                    itemBuilder: (context, index) {
                      final item = allEntries[index];
                      final isSelected = item.entry.id == _selectedEntryId;

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Text(
                          item.mood.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          item.entry.title.isEmpty
                              ? 'Untitled Entry'
                              : item.entry.title,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFFC5A059)
                                : const Color(0xFF2C2621),
                          ),
                        ),
                        subtitle: Text(
                          DateFormat(
                            'MMMM d, yyyy',
                          ).format(item.entry.entryDate),
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedEntryId = item.entry.id;
                            _currentPageIndex = 0;
                            _pageController.jumpToPage(0);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(allEntriesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2C1B10),
      resizeToAvoidBottomInset: false,
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return DeskBackground(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No journal entries yet to read.',
                        style: TextStyle(fontFamily: 'serif', fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Return'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Find targeted entry or default to latest
          JournalEntryWithDetails activeEntry = entries.first;
          if (_selectedEntryId != null) {
            final match = entries
                .where((e) => e.entry.id == _selectedEntryId)
                .toList();
            if (match.isNotEmpty) activeEntry = match.first;
          }

          final prefs = ref.watch(preferencesProvider);
          final deskThemeType = ref.watch(deskThemeProvider);
          final deskTheme = DeskThemeData.getTheme(deskThemeType);

          // Paginate active entry into physical book pages
          final bookPages = BookPaginator.paginate(activeEntry);
          final screenWidth = MediaQuery.of(context).size.width;
          final isWide = screenWidth > 600 || _isDualSpread;

          Widget readerContent;

          if (_bindingStyle == ReaderBindingStyle.gameCodex) {
            final stats = ref.watch(statisticsProvider);
            final achievements = ref.watch(achievementsProvider);

            Widget codexBody;
            switch (_codexTab) {
              case CodexTab.story:
                final spreads = _buildJournalSpreads(entries, deskTheme);
                codexBody = Center(
                  child: JournalBook(
                    spreads: spreads,
                    controller: _pageTurnController,
                    coverColor: deskTheme.coverColor,
                    paperColor: deskTheme.paperColor,
                    initialOpen: _isJournalOpen,
                    onBookOpened: () => setState(() => _isJournalOpen = true),
                    onBookClosed: () => setState(() => _isJournalOpen = false),
                  ),
                );
                break;
              case CodexTab.photos:
                codexBody = CodexPhotoDossierPage(entries: entries);
                break;
              case CodexTab.achievements:
                codexBody = CodexAchievementsPage(
                  achievements: achievements,
                  streak: stats.currentStreak,
                  totalEntries: entries.length,
                );
                break;
              case CodexTab.audio:
                codexBody = CodexAudioMemoPage(entries: entries);
                break;
            }

            readerContent = Container(
              color: deskTheme.deskColor,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    CodexTabHeader(
                      activeTab: _codexTab,
                      onTabSelected: (tab) => setState(() => _codexTab = tab),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: codexBody,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (_bindingStyle == ReaderBindingStyle.physicalStudy) {
            // Physical Illustrated Notebook in Study Room (Rebecca Mock inspiration)
            final spreads = _buildJournalSpreads(entries, deskTheme);
            readerContent = IllustratedStudyEnvironment(
              isJournalOpen: _isJournalOpen,
              deskTheme: deskTheme,
              isTransparentWall: prefs.readerBackgroundMode != 'desk',
              onTapOutside: () {
                setState(() => _isJournalOpen = false);
              },
              onTapBookshelf: () => context.push('/journal-stack'),
              child: JournalBook(
                spreads: spreads,
                controller: _pageTurnController,
                coverColor: deskTheme.coverColor,
                paperColor: deskTheme.paperColor,
                initialOpen: _isJournalOpen,
                onBookOpened: () => setState(() => _isJournalOpen = true),
                onBookClosed: () => setState(() => _isJournalOpen = false),
              ),
            );
          } else if (_bindingStyle == ReaderBindingStyle.postcard) {
            // Vintage Postcard Mode with Unified Paper Peel Animation
            final postcardSpreads = _buildPostcardSpreads(entries, deskTheme);
            readerContent = Center(
              child: AspectRatio(
                aspectRatio: 16 / 10.5,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(120),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PaperPeelPageTurn(
                      spreads: postcardSpreads,
                      controller: _pageTurnController,
                      paperColor: const Color(0xFFFBF7EE),
                    ),
                  ),
                ),
              ),
            );
          } else if (_bindingStyle == ReaderBindingStyle.ringBinder) {
            // Ring Binder Journal with Unified Paper Peel Animation
            final spreads = _buildJournalSpreads(entries, deskTheme);
            readerContent = RingBinderFrame(
              deskColor: deskTheme.deskColor,
              paperColor: deskTheme.paperColor,
              isDualSpread: isWide,
              reminderQuote: 'reminder: progress matters more than perfection.',
              child: PaperPeelPageTurn(
                spreads: spreads,
                controller: _pageTurnController,
                paperColor: deskTheme.paperColor,
              ),
            );
          } else {
            // Classic Leather Hardcover with Unified Paper Peel Animation
            final spreads = _buildJournalSpreads(entries, deskTheme);
            readerContent = Center(
              child: BookSpreadFrame(
                isDualSpread: isWide,
                coverColor: deskTheme.coverColor,
                paperColor: deskTheme.paperColor,
                child: PaperPeelPageTurn(
                  spreads: spreads,
                  controller: _pageTurnController,
                  paperColor: deskTheme.paperColor,
                ),
              ),
            );
          }

          final isPageTurnStyle =
              !(_bindingStyle == ReaderBindingStyle.gameCodex &&
                  _codexTab != CodexTab.story);
          final currentSpreads = _bindingStyle == ReaderBindingStyle.postcard
              ? _buildPostcardSpreads(entries, deskTheme)
              : _buildJournalSpreads(entries, deskTheme);

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              }
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: ReaderAtmosphereBackground(
                  mode: prefs.readerBackgroundMode,
                  assetPath: prefs.readerBackgroundAsset,
                  customImagePath: prefs.readerCustomImagePath,
                  deskFallbackColor: deskTheme.deskColor,
                  child: Stack(
                    children: [
                      // The Reader Workspace
                      Positioned.fill(
                        child: readerContent,
                      ),

                    // 1. Permanent Floating Back Button (ALWAYS accessible on screen)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(160),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFC5A059).withAlpha(160),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Overlay Controls (Top & Bottom Bar)
                    if (_showControls) ...[
                      // Top App Bar
                      Positioned(
                        top: 8,
                        left: 56,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  activeEntry.entry.title.isEmpty
                                      ? DateFormat(
                                          'MMMM d, yyyy',
                                        ).format(activeEntry.entry.entryDate)
                                      : activeEntry.entry.title,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Binding Style Selector (Binder / Hardcover / Postcard)
                              PopupMenuButton<ReaderBindingStyle>(
                                icon: const Icon(
                                  Icons.palette_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Switch Aesthetic Mode',
                                onSelected: (style) {
                                  setState(() => _bindingStyle = style);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: ReaderBindingStyle.hardcover,
                                    child:
                                        Text('📖 Hardcover Journal (3D Pages)'),
                                  ),
                                  const PopupMenuItem(
                                    value: ReaderBindingStyle.physicalStudy,
                                    child:
                                        Text('✨ Physical Illustrated Journal'),
                                  ),
                                  const PopupMenuItem(
                                    value: ReaderBindingStyle.gameCodex,
                                    child: Text(
                                      '🎮 Game Codex Notebook (References 1-4)',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: ReaderBindingStyle.ringBinder,
                                    child: Text('📋 Ring Binder Desk (Image 4)'),
                                  ),
                                  const PopupMenuItem(
                                    value: ReaderBindingStyle.postcard,
                                    child: Text('✉️ Vintage Postcard (Image 1)'),
                                  ),
                                ],
                              ),
                              // Wallpaper & Atmosphere Backdrop Switcher
                              IconButton(
                                icon: const Icon(
                                  Icons.wallpaper_rounded,
                                  color: Color(0xFFC5A059),
                                  size: 20,
                                ),
                                tooltip: 'Change Reader Atmosphere',
                                onPressed: () => _showWallpaperPicker(context),
                              ),
                              // Orientation Switcher (Landscape Spread vs Portrait)
                              IconButton(
                                icon: Icon(
                                  _isLandscape
                                      ? Icons.screen_lock_rotation_rounded
                                      : Icons.screen_rotation_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: _isLandscape
                                    ? 'Portrait View'
                                    : 'Landscape Mode (Physical Book Spread)',
                                onPressed: _toggleOrientation,
                              ),
                              // Spread Toggle (Single vs Dual Page)
                              if (_bindingStyle != ReaderBindingStyle.postcard &&
                                  _bindingStyle !=
                                      ReaderBindingStyle.physicalStudy)
                                IconButton(
                                  icon: Icon(
                                    isWide
                                        ? Icons.auto_stories
                                        : Icons.menu_book,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  tooltip: isWide
                                      ? 'Single Page View'
                                      : 'Two-Page Spread View',
                                  onPressed: () {
                                    setState(() {
                                      _isDualSpread = !_isDualSpread;
                                      _currentPageIndex = 0;
                                      _pageController = PageController();
                                    });
                                  },
                                ),
                              // Table of Contents
                              IconButton(
                                icon: const Icon(
                                  Icons.list_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Table of Contents',
                                onPressed: () => _showTableOfContents(
                                  context,
                                  entries,
                                  bookPages,
                                ),
                              ),
                              // Zen Mode / Fullscreen toggle
                              IconButton(
                                icon: const Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Zen Mode (Hide Bars)',
                                onPressed: () =>
                                    setState(() => _showControls = false),
                              ),
                              // Export to PDF (Exact Scrapbook & Journal replication)
                              IconButton(
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Export Journal Book as PDF',
                                onPressed: () => PdfExporter.exportEntriesToPdf(
                                    [activeEntry]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Live Music Soundtrack Banner in Book Reader
                      Positioned(
                        top: 54,
                        left: 16,
                        right: 16,
                        child: const NowPlayingMusicBanner(compact: true),
                      ),

                      // Bottom Navigation Bar
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(170),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous Page
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: isPageTurnStyle
                                    ? (_pageTurnController.canTurnBackward
                                        ? () =>
                                            _pageTurnController.previousPage()
                                        : null)
                                    : (_currentPageIndex > 0 ? _prevPage : null),
                              ),

                              // Page Counter & Date Indicator
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isPageTurnStyle
                                        ? 'Spread ${_pageTurnController.currentSpreadIndex + 1} of ${currentSpreads.length}'
                                        : 'Page ${_currentPageIndex + 1} of ${bookPages.length}',
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(activeEntry.entry.entryDate),
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),

                              // Quick Edit Entry
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Edit Journal Entry',
                                onPressed: () {
                                  context.push(
                                    '/editor?id=${activeEntry.entry.id}',
                                  );
                                },
                              ),

                              // Next Page
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: isPageTurnStyle
                                    ? (_pageTurnController.canTurnForward
                                        ? () => _pageTurnController.nextPage()
                                        : null)
                                    : (_currentPageIndex < bookPages.length - 1
                                        ? () => _nextPage(bookPages.length)
                                        : null),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Floating button to restore controls when in Zen mode
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => setState(() => _showControls = true),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(160),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFC5A059).withAlpha(160),
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fullscreen_exit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading journal: $err')),
      ),
    );
  }
}
