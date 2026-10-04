import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/security_service.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/preferences_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return JournalRepositoryImpl(db);
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl();
});

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});
