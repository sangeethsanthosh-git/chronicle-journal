import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:chronicle/core/widgets/paper_background.dart';
import 'package:chronicle/domain/models/paper_style.dart';
import 'package:chronicle/features/scrapbook/domain/models/scrapbook_item.dart';
import 'package:chronicle/features/scrapbook/providers/scrapbook_provider.dart';
import 'package:chronicle/features/scrapbook/presentation/widgets/canvas_item_widget.dart';

class ScrapbookStudioScreen extends ConsumerStatefulWidget {
  const ScrapbookStudioScreen({super.key});

  @override
  ConsumerState<ScrapbookStudioScreen> createState() =>
      _ScrapbookStudioScreenState();
}

class _ScrapbookStudioScreenState extends ConsumerState<ScrapbookStudioScreen> {
  final Uuid _uuid = const Uuid();

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF6EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Add to Scrapbook',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2621),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD4B996),
                    child: Icon(Icons.photo_camera_back, color: Colors.white),
                  ),
                  title: const Text('Polaroid Photograph'),
                  subtitle: const Text('Add a photo with washi tape'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFA3B899),
                    child: Icon(Icons.note_alt_outlined, color: Colors.white),
                  ),
                  title: const Text('Torn Note Snippet'),
                  subtitle: const Text('Handwritten thought or quote'),
                  onTap: () {
                    Navigator.pop(context);
                    _promptAddNote();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4A6B82),
                    child: Icon(
                      Icons.markunread_mailbox_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text('Vintage Postal Stamp'),
                  subtitle: const Text(
                    'Authentic airmail cancellation postmark',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _addStamp();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4E853C),
                    child: Icon(Icons.eco_outlined, color: Colors.white),
                  ),
                  title: const Text('Pressed Botanical'),
                  subtitle: const Text('Dried wildflower or study fern'),
                  onTap: () {
                    Navigator.pop(context);
                    _addBotanical();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF8B2525),
                    child: Icon(Icons.shield_outlined, color: Colors.white),
                  ),
                  title: const Text('Crimson Wax Seal'),
                  subtitle: const Text('Embossed protective seal'),
                  onTap: () {
                    Navigator.pop(context);
                    _addWaxSeal();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    ref
        .read(scrapbookProvider.notifier)
        .addItem(
          ScrapbookItem(
            id: _uuid.v4(),
            type: ScrapbookItemType.photo,
            x: 0.45,
            y: 0.45,
            rotation: 0.04,
            content: file.path,
            styleMeta: 'Study Memory',
          ),
        );
  }

  void _promptAddNote() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF6EE),
          title: const Text(
            'Write Note Snippet',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter your handwritten thought...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A059),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  ref
                      .read(scrapbookProvider.notifier)
                      .addItem(
                        ScrapbookItem(
                          id: _uuid.v4(),
                          type: ScrapbookItemType.note,
                          x: 0.40,
                          y: 0.40,
                          rotation: -0.05,
                          content: text,
                        ),
                      );
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Place Note',
                style: TextStyle(color: Color(0xFF2C1B10)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addStamp() {
    ref
        .read(scrapbookProvider.notifier)
        .addItem(
          ScrapbookItem(
            id: _uuid.v4(),
            type: ScrapbookItemType.stamp,
            x: 0.50,
            y: 0.35,
            rotation: 0.06,
            content: 'POSTAGE - 1924',
          ),
        );
  }

  void _addBotanical() {
    ref
        .read(scrapbookProvider.notifier)
        .addItem(
          ScrapbookItem(
            id: _uuid.v4(),
            type: ScrapbookItemType.botanical,
            x: 0.52,
            y: 0.55,
            rotation: -0.08,
            content: 'Study Ivy & Heather',
          ),
        );
  }

  void _addWaxSeal() {
    ref
        .read(scrapbookProvider.notifier)
        .addItem(
          ScrapbookItem(
            id: _uuid.v4(),
            type: ScrapbookItemType.waxSeal,
            x: 0.48,
            y: 0.65,
            rotation: 0.0,
            content: 'seal',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(scrapbookProvider);
    final selectedId = ref.watch(selectedScrapbookItemIdProvider);
    final selectedItem = selectedId != null
        ? items.where((e) => e.id == selectedId).firstOrNull
        : null;

    return PaperBackground(
      paperStyle: PaperStyle.vintage,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Scrapbook Studio',
            style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Add Element',
              onPressed: _showAddItemSheet,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            final canvasHeight = constraints.maxHeight;

            return Stack(
              children: [
                // Background Click to deselect
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref
                        .read(selectedScrapbookItemIdProvider.notifier)
                        .select(null);
                  },
                  child: const SizedBox.expand(),
                ),

                // Canvas Items
                for (final item in items)
                  Positioned(
                    left: (item.x * canvasWidth) - 70,
                    top: (item.y * canvasHeight) - 60,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final newX = (item.x + (details.delta.dx / canvasWidth))
                            .clamp(0.05, 0.95);
                        final newY =
                            (item.y + (details.delta.dy / canvasHeight)).clamp(
                              0.05,
                              0.95,
                            );
                        ref
                            .read(scrapbookProvider.notifier)
                            .updateItemPosition(item.id, newX, newY);
                      },
                      child: CanvasItemWidget(
                        item: item,
                        isSelected: item.id == selectedId,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(selectedScrapbookItemIdProvider.notifier)
                              .select(item.id);
                        },
                        onDelete: () {
                          ref
                              .read(scrapbookProvider.notifier)
                              .removeItem(item.id);
                          ref
                              .read(selectedScrapbookItemIdProvider.notifier)
                              .select(null);
                        },
                        onBringToFront: () {
                          ref
                              .read(scrapbookProvider.notifier)
                              .bringToFront(item.id);
                        },
                      ),
                    ),
                  ),

                // Selected Item Transformation Toolbar (Bottom)
                if (selectedItem != null)
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xEE2C2621),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.rotate_right_rounded,
                            color: Color(0xFFD4B996),
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: selectedItem.rotation,
                              min: -0.6,
                              max: 0.6,
                              activeColor: const Color(0xFFC5A059),
                              inactiveColor: const Color(0x44FFFFFF),
                              onChanged: (val) {
                                ref
                                    .read(scrapbookProvider.notifier)
                                    .updateItemTransform(
                                      selectedItem.id,
                                      rotation: val,
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.zoom_in_rounded,
                            color: Color(0xFFD4B996),
                            size: 20,
                          ),
                          Expanded(
                            child: Slider(
                              value: selectedItem.scale,
                              min: 0.6,
                              max: 1.6,
                              activeColor: const Color(0xFFC5A059),
                              inactiveColor: const Color(0x44FFFFFF),
                              onChanged: (val) {
                                ref
                                    .read(scrapbookProvider.notifier)
                                    .updateItemTransform(
                                      selectedItem.id,
                                      scale: val,
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFC5A059),
          foregroundColor: const Color(0xFF2C1B10),
          tooltip: 'Add Scrapbook Item',
          onPressed: _showAddItemSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
