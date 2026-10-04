import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../core/widgets/washi_tape.dart';
import '../../providers/preferences_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'emoji': '📖',
      'title': 'Welcome to Miora',
      'subtitle':
          'Your thoughts. Your moments. Your story. An artisanal sanctuary inspired by physical scrapbooks, polaroids, washi tape, and living books.',
    },
    {
      'emoji': '🔒',
      'title': 'Offline-First & Private',
      'subtitle':
          'Zero tracking, zero cloud dependencies. Your memories, photographs, and voice memos remain entirely on your personal device.',
    },
    {
      'emoji': '🎨',
      'title': '7 Nostalgic Layouts',
      'subtitle':
          'Switch seamlessly between Classic postmarks, Scrapbooks, Vintage Postcards, Open Ring Binders, and Polaroid Photo Stories.',
    },
    {
      'emoji': '🕰️',
      'title': 'Time Capsule Memories',
      'subtitle':
          'Look back across years on this exact date. Rediscover forgotten days and celebrate your personal growth.',
    },
  ];

  Future<void> _completeOnboarding() async {
    await ref.read(preferencesProvider.notifier).setOnboardingCompleted(true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontFamily: 'serif'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.paperCardDark
                                      : AppColors.paperCardLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.paperCardBorderDark
                                        : AppColors.paperCardBorderLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 10,
                                      offset: const Offset(2, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item['emoji']!,
                                  style: const TextStyle(fontSize: 72),
                                ),
                              ),
                              const Positioned(
                                top: -10,
                                right: 20,
                                child: WashiTape(
                                  width: 80,
                                  height: 22,
                                  color: AppColors.washiTapeSage,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item['subtitle']!,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 14,
                              height: 1.6,
                              color: isDark
                                  ? AppColors.inkSecondaryDark
                                  : AppColors.inkSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicators & Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(_pages.length, (idx) {
                        final isSel = idx == _currentPage;
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: isSel ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isSel
                                ? AppColors.vintageGold
                                : AppColors.paperCardBorderLight,
                          ),
                        );
                      }),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vintageGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                        ),
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
}
