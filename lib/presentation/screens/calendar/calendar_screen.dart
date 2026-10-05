import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/journal_entry_with_details.dart';
import '../../providers/journal_providers.dart';
import '../../providers/preferences_provider.dart';
import '../timeline/entry_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    final entriesAsync = ref.watch(allEntriesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: prefs.defaultPaperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Calendar',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.today_rounded),
              tooltip: 'Go to Today',
              onPressed: () {
                setState(() {
                  _focusedMonth = DateTime.now();
                  _selectedDay = DateTime.now();
                });
              },
            ),
          ],
        ),
        body: entriesAsync.when(
          data: (allEntries) {
            // Group entries by normalized date (YYYY-MM-DD)
            final Map<String, List<JournalEntryWithDetails>> entryMap = {};
            for (final e in allEntries) {
              final key = DateFormat('yyyy-MM-dd').format(e.entry.entryDate);
              entryMap.putIfAbsent(key, () => []).add(e);
            }

            final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
            final dayEntries = entryMap[selectedKey] ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final isShort = constraints.maxHeight < 620;

                final headerSection = [
                  // Month Header Navigator
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_focusedMonth),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Days of week header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                        return SizedBox(
                          width: 36,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.inkMutedDark
                                  : AppColors.inkMutedLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Calendar Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCalendarGrid(entryMap, isDark),
                  ),

                  const Divider(height: 24),

                  // Selected Day Header & Entries
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(_selectedDay),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Entry'),
                          onPressed: () {
                            final dateStr = _selectedDay.toIso8601String();
                            context.push('/editor?initialDate=$dateStr');
                          },
                        ),
                      ],
                    ),
                  ),
                ];

                if (isShort) {
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ...headerSection,
                      if (dayEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No entries for this day.',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: isDark
                                    ? AppColors.inkMutedDark
                                    : AppColors.inkMutedLight,
                              ),
                            ),
                          ),
                        )
                      else
                        ...dayEntries.map(
                          (e) => EntryCard(
                            entryWithDetails: e,
                            layout: prefs.defaultLayout,
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ...headerSection,
                    Expanded(
                      child: dayEntries.isEmpty
                          ? Center(
                              child: Text(
                                'No entries for this day.',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  color: isDark
                                      ? AppColors.inkMutedDark
                                      : AppColors.inkMutedLight,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: dayEntries.length,
                              itemBuilder: (context, index) {
                                return EntryCard(
                                  entryWithDetails: dayEntries[index],
                                  layout: prefs.defaultLayout,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              const Center(child: Text('Error loading calendar')),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
    Map<String, List<JournalEntryWithDetails>> entryMap,
    bool isDark,
  ) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final totalCells = ((startingWeekday + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final cellDate = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          dayNumber,
        );
        final dateKey = DateFormat('yyyy-MM-dd').format(cellDate);
        final hasEntries = entryMap.containsKey(dateKey);
        final dayEntries = entryMap[dateKey] ?? [];

        final isSelected =
            cellDate.year == _selectedDay.year &&
            cellDate.month == _selectedDay.month &&
            cellDate.day == _selectedDay.day;

        final isToday =
            cellDate.year == DateTime.now().year &&
            cellDate.month == DateTime.now().month &&
            cellDate.day == DateTime.now().day;

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = cellDate),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.vintageGold.withAlpha(50)
                  : (isToday
                        ? (isDark ? AppColors.paperCardDark : Colors.white)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.vintageGold
                    : (isToday
                          ? AppColors.paperCardBorderLight
                          : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    fontWeight: (isSelected || isToday)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isDark
                        ? AppColors.inkPrimaryDark
                        : AppColors.inkPrimaryLight,
                  ),
                ),
                if (hasEntries) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayEntries.take(3).map((e) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.mood.color,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
