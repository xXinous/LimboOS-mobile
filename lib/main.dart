import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';
import 'src/core/theme.dart';
import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/auth/data/auth_repository.dart';

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
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Running Man - Limbo OS',
      debugShowCheckedModeBanner: false,
      theme: RetroTheme.darkTheme,
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          }
          // For now, return a placeholder for the main app
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SESSÃO ATIVA: ${user.email}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text('LOGOUT'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('ERRO DE SISTEMA: $err')),
        ),
      ),
    );
  }
}
