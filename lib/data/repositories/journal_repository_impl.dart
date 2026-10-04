import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../../domain/models/journal_entry_with_details.dart';
import '../../domain/repositories/journal_repository.dart';

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
  Future<List<JournalEntryWithDetails>> getAllEntries() async {
    final entries = await _db.getAllEntries();
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
  }

  @override
  Future<JournalEntryWithDetails?> getEntryById(String id) async {
    final entry = await _db.getEntryById(id);
    if (entry == null) return null;
    final tags = await _db.getTagsForEntry(entry.id);
    final attachments = await _db.getAttachmentsForEntry(entry.id);
    return JournalEntryWithDetails(
      entry: entry,
      tags: tags,
      attachments: attachments,
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
}
