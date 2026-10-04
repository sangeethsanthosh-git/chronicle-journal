import 'package:flutter/material.dart';
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
import '../../providers/desk_theme_provider.dart';
import '../../providers/journal_providers.dart';
import 'book_3d_page_view.dart';
import 'book_page_data.dart';

enum ReaderBindingStyle { ringBinder, hardcover, postcard }

/// Immersive Book Reader Screen allowing users to read their journal entries
/// like a real physical ring binder or hardcover book resting on a desk,
/// or as an authentic vintage postcard spread.
class BookReaderScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const BookReaderScreen({super.key, this.entryId});

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  bool _showControls = true;
  bool _isDualSpread = false;
  ReaderBindingStyle _bindingStyle = ReaderBindingStyle.ringBinder;
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _selectedEntryId = widget.entryId;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

          if (_bindingStyle == ReaderBindingStyle.postcard) {
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
                            // Spread Toggle (Single vs Dual Page)
                            if (_bindingStyle != ReaderBindingStyle.postcard)
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
                              onPressed: _currentPageIndex > 0
                                  ? _prevPage
                                  : null,
                            ),

                            // Page Counter & Date Indicator
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Page ${_currentPageIndex + 1} of ${bookPages.length}',
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
                                  _currentPageIndex < bookPages.length - 1
                                  ? () => _nextPage(bookPages.length)
                                  : null,
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
