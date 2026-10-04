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
import '../../../core/widgets/vintage_postcard_widget.dart';
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
import '../../providers/statistics_provider.dart';
import 'book_3d_page_view.dart';
import 'book_page_data.dart';

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
  ReaderBindingStyle _bindingStyle = ReaderBindingStyle.gameCodex;
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

    for (final item in entryList) {
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
            title: 'Welcome to Chronicle',
            bodyText:
                'A quiet place for your thoughts, memories, and stories. Tap the pen to write your first entry.',
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
            // Vintage Postcard Mode (Image 1)
            readerContent = Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 60, bottom: 80),
                child: VintagePostcardWidget(
                  imagePath: activeEntry.photoAttachments.isNotEmpty
                      ? activeEntry.photoAttachments.first.uri
                      : null,
                  message: activeEntry.entry.content,
                  date: activeEntry.entry.entryDate,
                  location: activeEntry.entry.locationName ?? 'CHRONICLE POST',
                  recipient: 'To: Dear Future Self',
                ),
              ),
            );
          } else if (_bindingStyle == ReaderBindingStyle.ringBinder) {
            // Ring Binder Journal on Selected Desk Surface
            readerContent = RingBinderFrame(
              deskColor: deskTheme.deskColor,
              paperColor: deskTheme.paperColor,
              isDualSpread: isWide,
              reminderQuote: 'reminder: progress matters more than perfection.',
              child: Book3DPageView(
                pages: bookPages,
                controller: _pageController,
                isDualSpread: isWide,
                onPageChanged: (idx) {
                  setState(() => _currentPageIndex = idx);
                },
              ),
            );
          } else {
            // Classic Leather Hardcover on Wood Desk
            readerContent = DeskBackground(
              child: BookSpreadFrame(
                isDualSpread: isWide,
                isLeftPage: _currentPageIndex % 2 == 0,
                child: Book3DPageView(
                  pages: bookPages,
                  controller: _pageController,
                  isDualSpread: isWide,
                  onPageChanged: (idx) {
                    setState(() => _currentPageIndex = idx);
                  },
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: _bindingStyle == ReaderBindingStyle.ringBinder
                ? deskTheme.deskColor
                : deskTheme.coverColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // The Reader Workspace
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showControls = !_showControls);
                      },
                      child: readerContent,
                    ),
                  ),

                  // Overlay Controls (Top & Bottom Bar)
                  if (_showControls) ...[
                    // Top App Bar
                    Positioned(
                      top: 8,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              tooltip: 'Back',
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                activeEntry.entry.title.isEmpty
                                    ? DateFormat(
                                        'MMMM d, yyyy',
                                      ).format(activeEntry.entry.entryDate)
                                    : activeEntry.entry.title,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 15,
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
                              ),
                              tooltip: 'Switch Aesthetic Mode',
                              onSelected: (style) {
                                setState(() => _bindingStyle = style);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: ReaderBindingStyle.gameCodex,
                                  child: Text(
                                    '🎮 Game Codex Notebook (References 1-4)',
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: ReaderBindingStyle.physicalStudy,
                                  child: Text('✨ Physical Illustrated Journal'),
                                ),
                                const PopupMenuItem(
                                  value: ReaderBindingStyle.ringBinder,
                                  child: Text('📋 Ring Binder Desk (Image 4)'),
                                ),
                                const PopupMenuItem(
                                  value: ReaderBindingStyle.hardcover,
                                  child: Text('📖 Hardcover Journal'),
                                ),
                                const PopupMenuItem(
                                  value: ReaderBindingStyle.postcard,
                                  child: Text('✉️ Vintage Postcard (Image 1)'),
                                ),
                              ],
                            ),
                            // Orientation Switcher (Landscape Spread vs Portrait)
                            IconButton(
                              icon: Icon(
                                _isLandscape
                                    ? Icons.screen_lock_rotation_rounded
                                    : Icons.screen_rotation_rounded,
                                color: Colors.white,
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
                                  isWide ? Icons.auto_stories : Icons.menu_book,
                                  color: Colors.white,
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
                              ),
                              tooltip: 'Table of Contents',
                              onPressed: () => _showTableOfContents(
                                context,
                                entries,
                                bookPages,
                              ),
                            ),
                            // Export to PDF (Exact Scrapbook & Journal replication)
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: Colors.white,
                              ),
                              tooltip: 'Export Journal Book as PDF',
                              onPressed: () =>
                                  PdfExporter.exportEntriesToPdf([activeEntry]),
                            ),
                          ],
                        ),
                      ),
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
                              onPressed:
                                  _bindingStyle ==
                                      ReaderBindingStyle.physicalStudy
                                  ? (_pageTurnController.currentSpreadIndex > 0
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
                                  _bindingStyle ==
                                          ReaderBindingStyle.physicalStudy
                                      ? 'Spread ${_pageTurnController.currentSpreadIndex + 1} of ${_buildJournalSpreads(entries, deskTheme).length}'
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
                              onPressed:
                                  _bindingStyle ==
                                      ReaderBindingStyle.physicalStudy
                                  ? (_pageTurnController.currentSpreadIndex <
                                            _buildJournalSpreads(
                                                  entries,
                                                  deskTheme,
                                                ).length -
                                                1
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
                  ],
                ],
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
