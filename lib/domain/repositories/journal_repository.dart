import '../../data/local/app_database.dart';
import '../../features/journal_stack/domain/models/journal_stack_item.dart';
import '../../features/soundtrack/domain/models/now_playing.dart';
import '../models/journal_entry_with_details.dart';

abstract class JournalRepository {
  Stream<List<JournalEntryWithDetails>> watchAllEntries();
  Future<List<JournalEntryWithDetails>> getAllEntries();
  Future<JournalEntryWithDetails?> getEntryById(String id);
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
  });
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> softDeleteEntry(String id);
  Future<void> deleteEntryPermanently(String id);

  // Tags
  Stream<List<Tag>> watchAllTags();
  Future<List<Tag>> getAllTags();
  Future<void> createTag(String name, String colorHex);
  Future<void> deleteTag(String id);

  // Collections / Journal Stack
  Stream<List<Collection>> watchAllCollections();
  Future<List<Collection>> getAllCollections();
  Future<void> createCollection(
    String name,
    String? description,
    String? coverImageUri,
  );
  Future<void> deleteCollection(String id);
  Stream<List<JournalEntryWithDetails>> watchEntriesForCollection(
    String collectionId,
  );
  Future<void> addEntryToCollection(String collectionId, String entryId);
  Future<void> removeEntryFromCollection(String collectionId, String entryId);

  // Journal Stack
  Stream<List<JournalStackItem>> watchJournalStackItems();
  Future<void> createJournalVolume({
    required String title,
    String? description,
    String? coverImage,
    required String category,
    String? colorHex,
  });
  Future<void> updateJournalVolume({
    required String id,
    String? title,
    String? description,
    String? coverImage,
    String? category,
    String? colorHex,
  });
  Future<void> toggleArchiveJournalVolume(String id, bool isArchived);
  Future<void> deleteJournalVolume(String id);

  // Soundtracks
  Future<List<Soundtrack>> getSoundtracksForEntry(String entryId);
  Future<void> attachSoundtrack(String entryId, NowPlaying soundtrack);
  Future<void> removeSoundtrack(String soundtrackId);
}
