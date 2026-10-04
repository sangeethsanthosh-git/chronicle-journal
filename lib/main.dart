import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';
import 'presentation/providers/preferences_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  runApp(const ProviderScope(child: ChronicleApp()));
}

class ChronicleApp extends ConsumerWidget {
  const ChronicleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Chronicle',
      debugShowCheckedModeBanner: false,
      theme: ChronicleTheme.lightTheme,
      darkTheme: ChronicleTheme.darkTheme,
      themeMode: prefs.themeMode,
      routerConfig: router,
    );
  }
}
