import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';
import 'src/core/theme.dart';
import 'src/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: RunningManApp(),
    ),
  );
}

class RunningManApp extends ConsumerWidget {
  const RunningManApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Running Man - Limbo OS',
      debugShowCheckedModeBanner: false,
      theme: RetroTheme.darkTheme,
      routerConfig: router,
    );
  }
}
