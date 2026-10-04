import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import 'vintage_postcard_widget.dart';

class PostcardCustomizationData {
  final String message;
  final String recipient;
  final String location;
  final DateTime date;
  final String? imagePath;
  final Color stampColor;
  final String stampLabel;

  const PostcardCustomizationData({
    required this.message,
    this.recipient = 'To: Dear Future Self',
    this.location = 'MIORA POST',
    required this.date,
    this.imagePath,
    this.stampColor = AppColors.postalStampRed,
    this.stampLabel = '15¢ POSTAGE',
  });

  PostcardCustomizationData copyWith({
    String? message,
    String? recipient,
    String? location,
    DateTime? date,
    String? imagePath,
    Color? stampColor,
    String? stampLabel,
  }) {
    return PostcardCustomizationData(
      message: message ?? this.message,
      recipient: recipient ?? this.recipient,
      location: location ?? this.location,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      stampColor: stampColor ?? this.stampColor,
      stampLabel: stampLabel ?? this.stampLabel,
    );
  }
}

/// Interactive Postcard Editor modal allowing the user to customize:
/// - Handwritten cursive message
/// - Recipient line
/// - Postmark location / city
/// - Postage stamp color & style
/// - Live instant preview
class PostcardEditorDialog extends StatefulWidget {
  final PostcardCustomizationData initialData;
  final ValueChanged<PostcardCustomizationData> onSave;

  const PostcardEditorDialog({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  static Future<PostcardCustomizationData?> show(
    BuildContext context, {
    required PostcardCustomizationData initialData,
    required ValueChanged<PostcardCustomizationData> onSave,
  }) {
    return showModalBottomSheet<PostcardCustomizationData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PostcardEditorDialog(initialData: initialData, onSave: onSave),
    );
  }

  @override
  State<PostcardEditorDialog> createState() => _PostcardEditorDialogState();
}

class _PostcardEditorDialogState extends State<PostcardEditorDialog> {
  late TextEditingController _messageController;
  late TextEditingController _recipientController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late Color _stampColor;
  late String _stampLabel;

  static const List<Map<String, dynamic>> _stampPresets = [
    {
      'label': '15¢ Floral',
      'color': AppColors.postalStampRed,
      'icon': Icons.local_florist,
    },
    {
      'label': '25¢ Alpine',
      'color': AppColors.postalStampBlue,
      'icon': Icons.terrain,
    },
    {
      'label': '10¢ Fern',
      'color': AppColors.postalStampGreen,
      'icon': Icons.eco,
    },
    {
      'label': '50¢ Royal',
      'color': AppColors.vintageGold,
      'icon': Icons.auto_awesome,
    },
  ];

  static const List<String> _popularCities = [
    'MIORA POST',
    'PARIS',
    'KYOTO',
    'NEW YORK',
    'ALPINE MEADOW',
    'MY QUIET STUDY',
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: widget.initialData.message,
    );
    _recipientController = TextEditingController(
      text: widget.initialData.recipient,
    );
    _locationController = TextEditingController(
      text: widget.initialData.location,
    );
    _selectedDate = widget.initialData.date;
    _stampColor = widget.initialData.stampColor;
    _stampLabel = widget.initialData.stampLabel;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recipientController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.initialData.copyWith(
      message: _messageController.text.trim(),
      recipient: _recipientController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate,
      stampColor: _stampColor,
      stampLabel: _stampLabel,
    );
    widget.onSave(updated);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      height: media.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F5EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2DACB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('✉️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Customize Vintage Postcard',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF2C2621),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2621),
                    foregroundColor: const Color(0xFFFAF7EE),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Save Postcard',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Editor Form & Live Preview
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Live Preview of the Postcard
                const Text(
                  'LIVE CARD PREVIEW',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6F62),
                  ),
                ),
                const SizedBox(height: 8),
                VintagePostcardWidget(
                  imagePath: widget.initialData.imagePath,
                  message: _messageController.text,
                  date: _selectedDate,
                  location: _locationController.text.toUpperCase(),
                  recipient: _recipientController.text,
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFDED6C4)),
                const SizedBox(height: 12),

                // 2. Handwritten Message
                const Text(
                  'HANDWRITTEN MESSAGE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6F62),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts or message onto the card...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDED6C4)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Recipient Line
                const Text(
                  'RECIPIENT ADDRESS',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6F62),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _recipientController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'To: Dear Future Self',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDED6C4)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Postal Location / City
                const Text(
                  'POSTMARK LOCATION',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6F62),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _locationController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. PARIS, KYOTO, NEW YORK',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFDED6C4)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _popularCities.map((city) {
                    return ActionChip(
                      label: Text(city),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'serif',
                      ),
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _locationController.text = city;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // 5. Postage Stamp Style Picker
                const Text(
                  'POSTAGE STAMP BADGE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A6F62),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _stampPresets.map((preset) {
                    final isSelected = _stampColor == preset['color'];
                    final color = preset['color'] as Color;
                    final label = preset['label'] as String;
                    final icon = preset['icon'] as IconData;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _stampColor = color;
                          _stampLabel = label;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(40)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : const Color(0xFFDED6C4),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, size: 20, color: color),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // 6. Postmark Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF8B2635),
                  ),
                  title: Text(
                    'Postmark Date: ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: const Text('Change Date'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
