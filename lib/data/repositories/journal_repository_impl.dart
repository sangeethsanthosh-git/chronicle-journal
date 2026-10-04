import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../../domain/models/journal_entry_with_details.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../features/journal_stack/domain/models/journal_stack_item.dart';
import '../../features/soundtrack/domain/models/now_playing.dart';

class JournalRepositoryImpl implements JournalRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  JournalRepositoryImpl(this._db);

  @override
  Stream<List<JournalEntryWithDetails>> watchAllEntries() {
    return _db.watchAllEntries().asyncMap((entries) async {
      final list = <JournalEntryWithDetails>[];
      for (final entry in entries) {
        final tags = await _db.getTagsForEntry(entry.id);
        final attachments = await _db.getAttachmentsForEntry(entry.id);
        final soundtracks = await _db.getSoundtracksForEntry(entry.id);
        list.add(
          JournalEntryWithDetails(
            entry: entry,
            tags: tags,
            attachments: attachments,
            soundtracks: soundtracks,
          ),
        );
      }
      return list;
    });
  }

  @override
  Future<List<JournalEntryWithDetails>> getAllEntries() async {
    final entries = await _db.getAllEntries();
    final list = <JournalEntryWithDetails>[];
    for (final entry in entries) {
      final tags = await _db.getTagsForEntry(entry.id);
      final attachments = await _db.getAttachmentsForEntry(entry.id);
      final soundtracks = await _db.getSoundtracksForEntry(entry.id);
      list.add(
        JournalEntryWithDetails(
          entry: entry,
          tags: tags,
          attachments: attachments,
          soundtracks: soundtracks,
        ),
      );
    }
    return list;
  }

  @override
  Future<JournalEntryWithDetails?> getEntryById(String id) async {
    final entry = await _db.getEntryById(id);
    if (entry == null) return null;
    final tags = await _db.getTagsForEntry(entry.id);
    final attachments = await _db.getAttachmentsForEntry(entry.id);
    final soundtracks = await _db.getSoundtracksForEntry(entry.id);
    return JournalEntryWithDetails(
      entry: entry,
      tags: tags,
      attachments: attachments,
      soundtracks: soundtracks,
    );
  }

  @override
  Future<void> saveEntry({
    required String id,
    required String title,
    required String content,
    required DateTime entryDate,
    String? mood,
    int moodIntensity = 3,
    bool isFavorite = false,
    String? locationName,
    double? latitude,
    double? longitude,
    String? weatherSummary,
    double? weatherTemperature,
    String? coverImageUri,
    String layout = 'classic',
    String paperStyle = 'plain',
    List<String> tagIds = const [],
    List<String> photoPaths = const [],
    List<String> audioPaths = const [],
    NowPlaying? soundtrack,
  }) async {
    final now = DateTime.now();
    final existing = await _db.getEntryById(id);

    final companion = JournalEntriesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
      entryDate: Value(entryDate),
      mood: Value(mood),
      moodIntensity: Value(moodIntensity),
      isFavorite: Value(isFavorite),
      locationName: Value(locationName),
      latitude: Value(latitude),
      longitude: Value(longitude),
      weatherSummary: Value(weatherSummary),
      weatherTemperature: Value(weatherTemperature),
      coverImageUri: Value(coverImageUri),
      layout: Value(layout),
      paperStyle: Value(paperStyle),
    );

    await _db.insertOrUpdateEntry(companion);
    await _db.setTagsForEntry(id, tagIds);

    // Save attachments
    final currentAttachments = await _db.getAttachmentsForEntry(id);
    final existingUris = currentAttachments.map((a) => a.uri).toSet();

    for (final path in photoPaths) {
      if (!existingUris.contains(path)) {
        await _db.insertAttachment(
          AttachmentsCompanion(
            id: Value(_uuid.v4()),
            entryId: Value(id),
            uri: Value(path),
            type: const Value('image'),
            createdAt: Value(DateTime.now()),
          ),
        );
      }
    }

    for (final path in audioPaths) {
      if (!existingUris.contains(path)) {
        await _db.insertAttachment(
          AttachmentsCompanion(
            id: Value(_uuid.v4()),
            entryId: Value(id),
            uri: Value(path),
            type: const Value('audio'),
            createdAt: Value(DateTime.now()),
          ),
        );
      }
    }

    // Save soundtrack if provided
    if (soundtrack != null) {
      final existingSoundtracks = await _db.getSoundtracksForEntry(id);
      final soundtrackId = existingSoundtracks.isNotEmpty
          ? existingSoundtracks.first.id
          : _uuid.v4();

      await _db.insertOrUpdateSoundtrack(
        SoundtracksCompanion(
          id: Value(soundtrackId),
          entryId: Value(id),
          title: Value(soundtrack.title),
          artist: Value(soundtrack.artist),
          album: Value(soundtrack.album),
          artworkUri: Value(soundtrack.artworkUri),
          applicationName: Value(soundtrack.applicationName),
          durationMs: Value(soundtrack.duration?.inMilliseconds),
          capturedAt: Value(soundtrack.capturedAt),
        ),
      );
    }
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final entry = await _db.getEntryById(id);
    if (entry != null) {
      await _db.insertOrUpdateEntry(
        entry.toCompanion(true).copyWith(isFavorite: Value(isFavorite)),
      );
    }
  }

  @override
  Future<void> softDeleteEntry(String id) async {
    await _db.softDeleteEntry(id);
  }

  @override
  Future<void> deleteEntryPermanently(String id) async {
    await _db.permanentlyDeleteEntry(id);
  }

  @override
  Stream<List<Tag>> watchAllTags() => _db.watchAllTags();

  @override
  Future<List<Tag>> getAllTags() => _db.getAllTags();

  @override
  Future<void> createTag(String name, String colorHex) {
    return _db.insertTag(
      TagsCompanion(
        id: Value(_uuid.v4()),
        name: Value(name),
        colorHex: Value(colorHex),
      ),
    );
  }

  @override
  Future<void> deleteTag(String id) => _db.deleteTag(id);

  @override
  Stream<List<Collection>> watchAllCollections() => _db.watchAllCollections();

  @override
  Future<List<Collection>> getAllCollections() => _db.getAllCollections();

  @override
  Future<void> createCollection(
    String name,
    String? description,
    String? coverImageUri,
  ) {
    return _db.insertCollection(
      CollectionsCompanion(
        id: Value(_uuid.v4()),
        name: Value(name),
        description: Value(description),
        coverImageUri: Value(coverImageUri),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCollection(String id) => _db.deleteCollection(id);

  @override
  Stream<List<JournalEntryWithDetails>> watchEntriesForCollection(
    String collectionId,
  ) {
    return _db.watchEntriesForCollection(collectionId).asyncMap((
      entries,
    ) async {
      final list = <JournalEntryWithDetails>[];
      for (final entry in entries) {
        final tags = await _db.getTagsForEntry(entry.id);
        final attachments = await _db.getAttachmentsForEntry(entry.id);
        list.add(
          JournalEntryWithDetails(
            entry: entry,
            tags: tags,
            attachments: attachments,
          ),
        );
      }
      return list;
    });
  }

  @override
  Future<void> addEntryToCollection(String collectionId, String entryId) {
    return _db.addEntryToCollection(collectionId, entryId);
  }

  @override
  Future<void> removeEntryFromCollection(String collectionId, String entryId) {
    return _db.removeEntryFromCollection(collectionId, entryId);
  }

  @override
  Stream<List<JournalStackItem>> watchJournalStackItems() {
    return _db.watchAllCollections().asyncMap((collections) async {
      final items = <JournalStackItem>[];
      for (final col in collections) {
        final entries = await _db.getEntriesForCollection(col.id);
        int photoCount = 0;
        DateTime? minDate;
        DateTime? maxDate;
        final moodCounts = <String, int>{};

        for (final e in entries) {
          final attachments = await _db.getAttachmentsForEntry(e.id);
          photoCount += attachments.where((a) => a.type == 'image').length;

          if (minDate == null || e.entryDate.isBefore(minDate)) {
            minDate = e.entryDate;
          }
          if (maxDate == null || e.entryDate.isAfter(maxDate)) {
            maxDate = e.entryDate;
          }
          if (e.mood != null && e.mood!.isNotEmpty) {
            moodCounts[e.mood!] = (moodCounts[e.mood!] ?? 0) + 1;
          }
        }

        String? moodSummary;
        if (moodCounts.isNotEmpty) {
          final topMood = moodCounts.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
          moodSummary = 'Mostly $topMood';
        } else {
          moodSummary = 'Ready for reflections';
        }

        final cat = JournalCategory.fromString(col.category);
        Color spineColor = cat.defaultColor;
        if (col.colorHex != null && col.colorHex!.isNotEmpty) {
          try {
            final hex = col.colorHex!.replaceFirst('#', '');
            final val = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
            spineColor = Color(val);
          } catch (_) {}
        }

        items.add(
          JournalStackItem(
            id: col.id,
            title: col.name,
            description: col.description,
            coverImage: col.coverImageUri,
            category: cat,
            spineColor: spineColor,
            createdAt: col.createdAt,
            updatedAt: col.updatedAt ?? col.createdAt,
            startDate: minDate,
            endDate: maxDate,
            entryCount: entries.length,
            photoCount: photoCount,
            isArchived: col.isArchived,
            moodSummary: moodSummary,
            entryIds: entries.map((e) => e.id).toList(),
          ),
        );
      }
      return items;
    });
  }

  @override
  Future<void> createJournalVolume({
    required String title,
    String? description,
    String? coverImage,
    required String category,
    String? colorHex,
  }) {
    final catEnum = JournalCategory.fromString(category);
    final chosenColorHex =
        colorHex ??
        '#${catEnum.defaultColor.toARGB32().toRadixString(16).padLeft(8, '0')}';
    final now = DateTime.now();
    return _db.insertCollection(
      CollectionsCompanion(
        id: Value(_uuid.v4()),
        name: Value(title),
        description: Value(description),
        coverImageUri: Value(coverImage),
        category: Value(category),
        colorHex: Value(chosenColorHex),
        isArchived: const Value(false),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateJournalVolume({
    required String id,
    String? title,
    String? description,
    String? coverImage,
    String? category,
    String? colorHex,
  }) async {
    final existing = await (_db.select(
      _db.collections,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    await _db.updateCollection(
      CollectionsCompanion(
        id: Value(id),
        name: title != null ? Value(title) : Value(existing.name),
        description: description != null
            ? Value(description)
            : Value(existing.description),
        coverImageUri: coverImage != null
            ? Value(coverImage)
            : Value(existing.coverImageUri),
        category: category != null ? Value(category) : Value(existing.category),
        colorHex: colorHex != null ? Value(colorHex) : Value(existing.colorHex),
        isArchived: Value(existing.isArchived),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> toggleArchiveJournalVolume(String id, bool isArchived) {
    return _db.setCollectionArchived(id, isArchived);
  }

  @override
  Future<void> deleteJournalVolume(String id) {
    return _db.deleteCollection(id);
  }

  // Soundtracks
  @override
  Future<List<Soundtrack>> getSoundtracksForEntry(String entryId) {
    return _db.getSoundtracksForEntry(entryId);
  }

  @override
  Future<void> attachSoundtrack(String entryId, NowPlaying soundtrack) async {
    final existing = await _db.getSoundtracksForEntry(entryId);
    final soundtrackId = existing.isNotEmpty ? existing.first.id : _uuid.v4();

    await _db.insertOrUpdateSoundtrack(
      SoundtracksCompanion(
        id: Value(soundtrackId),
        entryId: Value(entryId),
        title: Value(soundtrack.title),
        artist: Value(soundtrack.artist),
        album: Value(soundtrack.album),
        artworkUri: Value(soundtrack.artworkUri),
        applicationName: Value(soundtrack.applicationName),
        durationMs: Value(soundtrack.duration?.inMilliseconds),
        capturedAt: Value(soundtrack.capturedAt),
      ),
    );
  }

  @override
  Future<void> removeSoundtrack(String soundtrackId) {
    return _db.deleteSoundtrack(soundtrackId);
  }
}
