import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp();

  // Hive yerel depolama başlatma
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: CoografistApp(),
    ),
  );
}

class CoografistApp extends ConsumerWidget {
  const CoografistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router   = ref.watch(routerProvider);
    final darkMode = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title:          'Coğrafist',
      debugShowCheckedModeBanner: false,
      theme:          AppTheme.light,
      darkTheme:      AppTheme.dark,
      themeMode:      darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig:   router,
    );
  }
}
