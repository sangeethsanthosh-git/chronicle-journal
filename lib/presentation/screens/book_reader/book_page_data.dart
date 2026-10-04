import '../../../core/widgets/book_margin_doodles.dart';
import '../../../domain/models/journal_entry_with_details.dart';
import '../../../domain/models/mood.dart';

enum BookPageType {
  chapterOpening,
  storyContinuation,
  storyWithMedia,
  epilogueAndTags,
}

class BookPageData {
  final int pageNumber;
  final int totalPages;
  final BookPageType type;
  final String title;
  final String text;
  final bool hasDropCap;
  final String? photoPath;
  final String? audioPath;
  final DateTime date;
  final String? location;
  final String? weather;
  final Mood mood;
  final int moodIntensity;
  final List<String> tags;
  final bool isFavorite;
  final BookDoodleType? doodle;
  final String? caption;

  BookPageData({
    required this.pageNumber,
    required this.totalPages,
    required this.type,
    required this.title,
    required this.text,
    this.hasDropCap = false,
    this.photoPath,
    this.audioPath,
    required this.date,
    this.location,
    this.weather,
    required this.mood,
    required this.moodIntensity,
    this.tags = const [],
    this.isFavorite = false,
    this.doodle,
    this.caption,
  });
}

class BookPaginator {
  /// Splits a journal entry into an array of readable physical book pages
  static List<BookPageData> paginate(JournalEntryWithDetails entryWithDetails) {
    final entry = entryWithDetails.entry;
    final photos = entryWithDetails.photoAttachments;
    final audios = entryWithDetails.audioAttachments;
    final tags = entryWithDetails.tags.map((t) => t.name).toList();

    final rawContent = entry.content.trim();
    final paragraphs = rawContent.isEmpty
        ? <String>['(A quiet moment captured in memory...)']
        : rawContent
              .split(RegExp(r'\n\s*\n'))
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList();

    // Word count estimation to comfortably balance text per page
    const wordsPerPage = 110;
    final textChunks = <String>[];

    String currentChunk = '';
    int currentWords = 0;

    for (final p in paragraphs) {
      final pWords = p.split(RegExp(r'\s+')).length;
      if (currentWords + pWords > wordsPerPage && currentChunk.isNotEmpty) {
        textChunks.add(currentChunk.trim());
        currentChunk = p;
        currentWords = pWords;
      } else {
        if (currentChunk.isEmpty) {
          currentChunk = p;
        } else {
          currentChunk += '\n\n$p';
        }
        currentWords += pWords;
      }
    }
    if (currentChunk.isNotEmpty) {
      textChunks.add(currentChunk.trim());
    }

    // Ensure at least 2 pages for an authentic open-book feel
    if (textChunks.isEmpty) {
      textChunks.add('');
    }

    final pages = <BookPageData>[];
    final totalPageCount = (textChunks.length + (photos.length > 1 ? 1 : 0))
        .clamp(2, 20);

    // Page 1: Chapter Opening
    pages.add(
      BookPageData(
        pageNumber: 1,
        totalPages: totalPageCount,
        type: BookPageType.chapterOpening,
        title: entry.title.isEmpty ? 'Journal Entry' : entry.title,
        text: textChunks.first,
        hasDropCap: true,
        photoPath: photos.isNotEmpty ? photos.first.uri : null,
        caption: photos.isNotEmpty ? photos.first.caption : null,
        date: entry.entryDate,
        location: entry.locationName,
        weather: entry.weatherSummary != null
            ? '${entry.weatherSummary}${entry.weatherTemperature != null ? " • ${entry.weatherTemperature!.round()}°C" : ""}'
            : null,
        mood: entryWithDetails.mood,
        moodIntensity: entry.moodIntensity,
        tags: tags,
        isFavorite: entry.isFavorite,
        doodle: BookDoodleType.rocket,
      ),
    );

    // Intermediate Pages
    int photoIndex = 1;
    for (int i = 1; i < textChunks.length; i++) {
      final isLast =
          (i == textChunks.length - 1) && (photoIndex >= photos.length);
      final hasPhoto = photoIndex < photos.length;
      final currentPhoto = hasPhoto ? photos[photoIndex].uri : null;
      final currentCaption = hasPhoto ? photos[photoIndex].caption : null;
      if (hasPhoto) photoIndex++;

      final pageNum = pages.length + 1;
      pages.add(
        BookPageData(
          pageNumber: pageNum,
          totalPages: totalPageCount,
          type: isLast
              ? BookPageType.epilogueAndTags
              : (hasPhoto
                    ? BookPageType.storyWithMedia
                    : BookPageType.storyContinuation),
          title: entry.title,
          text: textChunks[i],
          hasDropCap: false,
          photoPath: currentPhoto,
          caption: currentCaption,
          audioPath: (i == 1 && audios.isNotEmpty) ? audios.first.uri : null,
          date: entry.entryDate,
          location: entry.locationName,
          mood: entryWithDetails.mood,
          moodIntensity: entry.moodIntensity,
          tags: isLast ? tags : const [],
          isFavorite: entry.isFavorite,
          doodle: i % 2 == 1
              ? BookDoodleType.boombox
              : BookDoodleType.puzzleCube,
        ),
      );
    }

    // If there's only 1 page so far, add a graceful facing reflection page
    if (pages.length == 1) {
      pages.add(
        BookPageData(
          pageNumber: 2,
          totalPages: 2,
          type: BookPageType.epilogueAndTags,
          title: entry.title,
          text:
              'Every day is a story waiting to be remembered. Keep writing, reflecting, and preserving life’s quiet wonders.',
          hasDropCap: false,
          audioPath: audios.isNotEmpty ? audios.first.uri : null,
          date: entry.entryDate,
          location: entry.locationName,
          mood: entryWithDetails.mood,
          moodIntensity: entry.moodIntensity,
          tags: tags,
          isFavorite: entry.isFavorite,
          doodle: BookDoodleType.boombox,
        ),
      );
    }

    return pages;
  }
}
