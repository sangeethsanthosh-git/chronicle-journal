import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/journal_statistics.dart';
import '../../domain/usecases/get_statistics_usecase.dart';
import 'journal_providers.dart';

final statisticsUseCaseProvider = Provider<GetStatisticsUseCase>((ref) {
  return GetStatisticsUseCase();
});

final statisticsProvider = Provider<JournalStatistics>((ref) {
  final entriesAsync = ref.watch(allEntriesStreamProvider);
  final useCase = ref.watch(statisticsUseCaseProvider);

  return entriesAsync.when(
    data: (entries) => useCase.execute(entries),
    loading: () => JournalStatistics.empty(),
    error: (err, stack) => JournalStatistics.empty(),
  );
});
