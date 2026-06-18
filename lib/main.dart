import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'src/core/theme.dart';
import 'src/core/app_startup_widget.dart';
import 'src/routing/app_router.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // Preserva a splash screen nativa enquanto o Firebase e os dados inicializam
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cache Firestore agressivo — offline-first
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    const ProviderScope(
      child: LimboOSApp(),
    ),
  );
  // Splash NÃO é removida aqui — será removida pelo AppStartupWidget
  // quando os providers principais estiverem carregados
}

class LimboOSApp extends ConsumerWidget {
  const LimboOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppStartupWidget(
      child: MaterialApp.router(
        title: 'Limbo OS',
        debugShowCheckedModeBanner: false,
        theme: RetroTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
