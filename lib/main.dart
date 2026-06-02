import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'src/core/theme.dart';
import 'src/routing/app_router.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Preserva a splash screen nativa enquanto o Firebase e o Flutter inicializam
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: RunningManApp(),
    ),
  );
  
  // Remove a splash screen nativa quando o app estiver pronto para interagir
  FlutterNativeSplash.remove();
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
