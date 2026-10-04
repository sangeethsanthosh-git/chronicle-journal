import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../progression/providers/progression_provider.dart';
import '../domain/models/scrapbook_item.dart';

const String _kScrapbookCanvasKey = 'chronicle_scrapbook_items_v1';

class ScrapbookNotifier extends Notifier<List<ScrapbookItem>> {
  @override
  List<ScrapbookItem> build() {
    _loadFromStorage();
    return _initialDefaultItems;
  }

  static List<ScrapbookItem> get _initialDefaultItems => [
    const ScrapbookItem(
      id: 'default_note_1',
      type: ScrapbookItemType.note,
      x: 0.25,
      y: 0.22,
      rotation: -0.06,
      scale: 1.0,
      content:
          'A quiet afternoon in the study.\nThe sunlight was amber and warm.',
      styleMeta: 'kraft',
    ),
    const ScrapbookItem(
      id: 'default_stamp_1',
      type: ScrapbookItemType.stamp,
      x: 0.72,
      y: 0.18,
      rotation: 0.08,
      scale: 1.1,
      content: 'AIR MAIL - PARIS',
      styleMeta: 'stamp_blue',
    ),
    const ScrapbookItem(
      id: 'default_botanical_1',
      type: ScrapbookItemType.botanical,
      x: 0.68,
      y: 0.48,
      rotation: 0.12,
      scale: 1.0,
      content: 'Dried Fern & Wildflower',
      styleMeta: 'fern',
    ),
  ];

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kScrapbookCanvasKey);
      if (raw != null) {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        state = list
            .map((item) => ScrapbookItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((e) => e.toJson()).toList();
      await prefs.setString(_kScrapbookCanvasKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  void addItem(ScrapbookItem item) {
    state = [...state, item];
    _saveToStorage();
    // Award Thought XP for crafting a scrapbook element
    ref.read(userProgressProvider.notifier).recordScrapbookCreated();
  }

  void updateItemPosition(String id, double x, double y) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(x: x, y: y) else item,
    ];
    _saveToStorage();
  }

  void updateItemTransform(String id, {double? scale, double? rotation}) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            scale: scale ?? item.scale,
            rotation: rotation ?? item.rotation,
          )
        else
          item,
    ];
    _saveToStorage();
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveToStorage();
  }

  void bringToFront(String id) {
    final item = state.firstWhere((e) => e.id == id, orElse: () => state.first);
    state = [...state.where((e) => e.id != id), item];
    _saveToStorage();
  }
}

final scrapbookProvider =
    NotifierProvider<ScrapbookNotifier, List<ScrapbookItem>>(() {
      return ScrapbookNotifier();
    });

class SelectedScrapbookItemIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedScrapbookItemIdProvider =
    NotifierProvider<SelectedScrapbookItemIdNotifier, String?>(() {
      return SelectedScrapbookItemIdNotifier();
    });
