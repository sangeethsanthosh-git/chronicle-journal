import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get mood => text().nullable()();
  IntColumn get moodIntensity => integer().withDefault(const Constant(3))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get locationName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get weatherSummary => text().nullable()();
  RealColumn get weatherTemperature => real().nullable()();
  TextColumn get coverImageUri => text().nullable()();
  TextColumn get layout => text().withDefault(const Constant('classic'))();
  TextColumn get paperStyle => text().withDefault(const Constant('plain'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get colorHex => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class EntryTagCrossRefs extends Table {
  TextColumn get entryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {entryId, tagId};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get uri => text()();
  TextColumn get type => text()(); // 'image' or 'audio'
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverImageUri => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get category => text().withDefault(const Constant('PERSONAL'))();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CollectionEntryCrossRefs extends Table {
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {collectionId, entryId};
}

class Soundtracks extends Table {
  TextColumn get id => text()();
  TextColumn get entryId =>
      text().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().nullable()();
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get artworkUri => text().nullable()();
  TextColumn get applicationName => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    JournalEntries,
    Tags,
    EntryTagCrossRefs,
    Attachments,
    Collections,
    CollectionEntryCrossRefs,
    Soundtracks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(collections, collections.category);
        await m.addColumn(collections, collections.colorHex);
        await m.addColumn(collections, collections.isArchived);
        await m.addColumn(collections, collections.updatedAt);
      }
      if (from < 3) {
        await m.createTable(soundtracks);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // Queries for Journal Entries
  Stream<List<JournalEntry>> watchAllEntries({bool includeDeleted = false}) {
    final query = select(journalEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.entryDate, mode: OrderingMode.desc),
      ]);
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    return query.watch();
  }

  Future<List<JournalEntry>> getAllEntries({bool includeDeleted = false}) {
    final query = select(journalEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.entryDate, mode: OrderingMode.desc),
      ]);
    if (!includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }
    return query.get();
  }

  Future<JournalEntry?> getEntryById(String id) {
    return (select(
      journalEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertOrUpdateEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insertOnConflictUpdate(entry);
  }

  Future<int> softDeleteEntry(String id) {
    return (update(journalEntries)..where((t) => t.id.equals(id))).write(
      JournalEntriesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<int> permanentlyDeleteEntry(String id) {
    return (delete(journalEntries)..where((t) => t.id.equals(id))).go();
  }

  // Tags
  Stream<List<Tag>> watchAllTags() => select(tags).watch();
  Future<List<Tag>> getAllTags() => select(tags).get();
  Future<int> insertTag(TagsCompanion tag) =>
      into(tags).insertOnConflictUpdate(tag);
  Future<int> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<List<Tag>> getTagsForEntry(String entryId) {
    final query = select(tags).join([
      innerJoin(entryTagCrossRefs, entryTagCrossRefs.tagId.equalsExp(tags.id)),
    ])..where(entryTagCrossRefs.entryId.equals(entryId));
    return query.map((row) => row.readTable(tags)).get();
  }

  Stream<List<Tag>> watchTagsForEntry(String entryId) {
    final query = select(tags).join([
      innerJoin(entryTagCrossRefs, entryTagCrossRefs.tagId.equalsExp(tags.id)),
    ])..where(entryTagCrossRefs.entryId.equals(entryId));
    return query.map((row) => row.readTable(tags)).watch();
  }

  Future<void> setTagsForEntry(String entryId, List<String> tagIds) async {
    await transaction(() async {
      await (delete(
        entryTagCrossRefs,
      )..where((t) => t.entryId.equals(entryId))).go();
      for (final tagId in tagIds) {
        await into(entryTagCrossRefs).insert(
          EntryTagCrossRefsCompanion(
            entryId: Value(entryId),
            tagId: Value(tagId),
          ),
        );
      }
    });
  }

  // Attachments
  Future<List<Attachment>> getAttachmentsForEntry(String entryId) {
    return (select(attachments)..where((t) => t.entryId.equals(entryId))).get();
  }

  Stream<List<Attachment>> watchAttachmentsForEntry(String entryId) {
    return (select(
      attachments,
    )..where((t) => t.entryId.equals(entryId))).watch();
  }

  Future<int> insertAttachment(AttachmentsCompanion attachment) {
    return into(attachments).insertOnConflictUpdate(attachment);
  }

  Future<int> deleteAttachment(String id) {
    return (delete(attachments)..where((t) => t.id.equals(id))).go();
  }

  // Soundtracks
  Future<List<Soundtrack>> getSoundtracksForEntry(String entryId) {
    return (select(soundtracks)..where((t) => t.entryId.equals(entryId))).get();
  }

  Stream<List<Soundtrack>> watchSoundtracksForEntry(String entryId) {
    return (select(
      soundtracks,
    )..where((t) => t.entryId.equals(entryId))).watch();
  }

  Future<int> insertOrUpdateSoundtrack(SoundtracksCompanion soundtrack) {
    return into(soundtracks).insertOnConflictUpdate(soundtrack);
  }

  Future<int> deleteSoundtrack(String id) {
    return (delete(soundtracks)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteSoundtracksForEntry(String entryId) {
    return (delete(soundtracks)..where((t) => t.entryId.equals(entryId))).go();
  }

  // Collections
  Stream<List<Collection>> watchAllCollections() => select(collections).watch();
  Future<List<Collection>> getAllCollections() => select(collections).get();
  Future<int> insertCollection(CollectionsCompanion col) =>
      into(collections).insertOnConflictUpdate(col);
  Future<int> updateCollection(CollectionsCompanion col) =>
      (update(collections)..where((t) => t.id.equals(col.id.value))).write(col);
  Future<int> setCollectionArchived(String id, bool isArchived) =>
      (update(collections)..where((t) => t.id.equals(id))).write(
        CollectionsCompanion(
          isArchived: Value(isArchived),
          updatedAt: Value(DateTime.now()),
        ),
      );
  Future<int> deleteCollection(String id) =>
      (delete(collections)..where((t) => t.id.equals(id))).go();

  Future<List<JournalEntry>> getEntriesForCollection(String collectionId) {
    final query =
        select(journalEntries).join([
          innerJoin(
            collectionEntryCrossRefs,
            collectionEntryCrossRefs.entryId.equalsExp(journalEntries.id),
          ),
        ])..where(
          collectionEntryCrossRefs.collectionId.equals(collectionId) &
              journalEntries.deletedAt.isNull(),
        );
    return query.map((row) => row.readTable(journalEntries)).get();
  }

  Stream<List<JournalEntry>> watchEntriesForCollection(String collectionId) {
    final query =
        select(journalEntries).join([
          innerJoin(
            collectionEntryCrossRefs,
            collectionEntryCrossRefs.entryId.equalsExp(journalEntries.id),
          ),
        ])..where(
          collectionEntryCrossRefs.collectionId.equals(collectionId) &
              journalEntries.deletedAt.isNull(),
        );
    return query.map((row) => row.readTable(journalEntries)).watch();
  }

  Future<void> addEntryToCollection(String collectionId, String entryId) {
    return into(collectionEntryCrossRefs).insert(
      CollectionEntryCrossRefsCompanion(
        collectionId: Value(collectionId),
        entryId: Value(entryId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeEntryFromCollection(String collectionId, String entryId) {
    return (delete(collectionEntryCrossRefs)..where(
          (t) =>
              t.collectionId.equals(collectionId) & t.entryId.equals(entryId),
        ))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chronicle.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
