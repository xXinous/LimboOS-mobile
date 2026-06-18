import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../features/auth/data/auth_repository.dart';

/// Widget que mantém a splash screen nativa visível até que os providers
/// principais (auth state) tenham resolvido.
///
/// Garante que o usuário nunca veja um spinner genérico na primeira tela.
/// Quando a splash desaparece, a UI já está renderizada com dados.
class AppStartupWidget extends ConsumerStatefulWidget {
  final Widget child;

  const AppStartupWidget({super.key, required this.child});

  @override
  ConsumerState<AppStartupWidget> createState() => _AppStartupWidgetState();
}

class _AppStartupWidgetState extends ConsumerState<AppStartupWidget> {
  bool _splashRemoved = false;
  bool _timeoutScheduled = false; // guard: cria o timeout apenas uma vez

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    // Quando auth resolver (logado ou não), remove a splash imediatamente.
    if (!_splashRemoved) {
      authState.whenData((_) {
        _removeSplash();
      });

      // Timeout de segurança: se auth demorar mais de 3s (ex: sem rede no
      // primeiro launch), remove a splash para exibir a tela de login.
      // O guard `_timeoutScheduled` garante que só um Future seja criado.
      if (authState.isLoading && !_timeoutScheduled) {
        _timeoutScheduled = true;
        Future.delayed(const Duration(seconds: 3), _removeSplash);
      }
    }

    return widget.child;
  }

  void _removeSplash() {
    if (!_splashRemoved && mounted) {
      _splashRemoved = true;
      FlutterNativeSplash.remove();
    }
  }
}
