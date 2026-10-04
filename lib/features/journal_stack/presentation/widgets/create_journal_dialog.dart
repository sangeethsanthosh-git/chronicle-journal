import 'package:flutter/material.dart';
import '../../domain/models/journal_stack_item.dart';

/// Modal dialog allowing the user to craft a new physical journal volume
/// or customize an existing one: title, description, category, and spine color.
class CreateJournalDialog extends StatefulWidget {
  final JournalStackItem? existingItem;
  final void Function({
    required String title,
    String? description,
    String? coverImage,
    required JournalCategory category,
    String? colorHex,
  })
  onSave;

  const CreateJournalDialog({
    super.key,
    this.existingItem,
    required this.onSave,
  });

  @override
  State<CreateJournalDialog> createState() => _CreateJournalDialogState();
}

class _CreateJournalDialogState extends State<CreateJournalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late JournalCategory _selectedCategory;
  late Color _selectedColor;

  static const List<Color> _palette = [
    Color(0xFFC86D51), // Terracotta
    Color(0xFF3D6B7D), // Slate Teal
    Color(0xFF4A6B5B), // Sage Forest
    Color(0xFFC99A3E), // Amber Gold
    Color(0xFFC0787A), // Dusty Rose
    Color(0xFF7E5B6E), // Mauve Plum
    Color(0xFF414B66), // Midnight Blue
    Color(0xFF8A5E44), // Leather Espresso
    Color(0xFF5D5A56), // Vintage Charcoal
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingItem?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _selectedCategory =
        widget.existingItem?.category ?? JournalCategory.personal;
    _selectedColor =
        widget.existingItem?.spineColor ?? _selectedCategory.defaultColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(JournalCategory cat) {
    setState(() {
      _selectedCategory = cat;
      // Auto-update default color if user hasn't explicitly customized
      if (widget.existingItem == null) {
        _selectedColor = cat.defaultColor;
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0')}';

    widget.onSave(
      title: title,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      category: _selectedCategory,
      colorHex: colorHex,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7EE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDDD6C7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 16),
                  blurRadius: 32,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'EDIT JOURNAL' : 'NEW JOURNAL VOLUME',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF2C2218),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2218),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Journal Title',
                      hintText: 'e.g. Summer Travels 2026',
                      filled: true,
                      fillColor: const Color(0xFFF3EEE2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C7)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description Field
                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A3E31),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Short Subtitle / Description',
                      hintText: 'A personal collection of moments and thoughts',
                      filled: true,
                      fillColor: const Color(0xFFF3EEE2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDD6C7)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Category Selection
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF8C7355),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: JournalCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        avatar: Icon(
                          cat.icon,
                          size: 14,
                          color: isSelected
                              ? const Color(0xFFFAF7EE)
                              : cat.defaultColor,
                        ),
                        label: Text(cat.label),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2C2218),
                        backgroundColor: const Color(0xFFF3EEE2),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFFAF7EE)
                              : const Color(0xFF4A3E31),
                        ),
                        onSelected: (_) => _onCategoryChanged(cat),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Spine & Cover Color Palette
                  const Text(
                    'SPINE COLOR',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF8C7355),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _palette.map((color) {
                      final isSelected =
                          _selectedColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2C2218)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2218),
                        foregroundColor: const Color(0xFFFAF7EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        isEditing ? 'SAVE CHANGES' : 'CREATE JOURNAL',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
