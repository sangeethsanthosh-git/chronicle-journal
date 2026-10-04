import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_memories_usecase.dart';
import 'journal_providers.dart';

final memoriesUseCaseProvider = Provider<GetMemoriesUseCase>((ref) {
  return GetMemoriesUseCase();
});

final memoriesProvider = Provider<List<MemoryFlashback>>((ref) {
  final entriesAsync = ref.watch(allEntriesStreamProvider);
  final useCase = ref.watch(memoriesUseCaseProvider);

  return entriesAsync.when(
    data: (entries) => useCase.execute(entries),
    loading: () => [],
    error: (err, stack) => [],
  );
});
