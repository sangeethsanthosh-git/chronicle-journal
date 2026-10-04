import 'package:flutter/material.dart';

enum CodexTab {
  story('Story', Icons.auto_stories_outlined, Color(0xFFC86D51)),
  photos('Media', Icons.photo_library_outlined, Color(0xFF3D6B7D)),
  achievements('Trophy', Icons.emoji_events_outlined, Color(0xFFC99A3E)),
  audio('Cassette', Icons.mic_none_outlined, Color(0xFF7E5B6E));

  final String label;
  final IconData icon;
  final Color tabColor;

  const CodexTab(this.label, this.icon, this.tabColor);
}

/// Protruding top index tabs matching References 1, 2, 4 (Game Codex & Notebook)
class CodexTabHeader extends StatelessWidget {
  final CodexTab activeTab;
  final ValueChanged<CodexTab> onTabSelected;

  const CodexTabHeader({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: CodexTab.values.map((tab) {
          final isSelected = tab == activeTab;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 10,
                  vertical: isSelected ? 7 : 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? tab.tabColor : const Color(0xFFE2DDD1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: isSelected ? tab.tabColor : const Color(0xFFC9C1B0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: isSelected ? 14 : 12,
                      color: isSelected
                          ? const Color(0xFFFAF7EE)
                          : const Color(0xFF6B5E50),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tab.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: isSelected ? 11 : 9.5,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        letterSpacing: 0.8,
                        color: isSelected
                            ? const Color(0xFFFAF7EE)
                            : const Color(0xFF6B5E50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
