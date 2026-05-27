import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/retro_decorations.dart';
import '../../../core/widgets/retro_button.dart';
import '../../../core/widgets/retro_text_field.dart';
import '../data/auth_repository.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masterIdController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final error = useState<String?>(null);

    Future<void> handleLogin() async {
      if (masterIdController.text.isEmpty || passwordController.text.isEmpty) return;
      
      isLoading.value = true;
      error.value = null;
      try {
        await ref.read(authRepositoryProvider).loginOrCreate(
          masterIdController.text,
          passwordController.text,
        );
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleGoogleLogin() async {
      isLoading.value = true;
      error.value = null;
      try {
        await ref.read(authRepositoryProvider).signInWithGoogle();
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleAppleLogin() async {
      isLoading.value = true;
      error.value = null;
      try {
        await ref.read(authRepositoryProvider).signInWithApple();
      } catch (e) {
        error.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: RetroDecorations(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Section
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: RetroTheme.kPrimary, width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TERMINAL MESTRE',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        'PONTO DE ACESSO À REDE RUNNING MAN',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 48),

                // Form Section
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: RetroTheme.kSurfaceContainerLow,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      RetroTextField(
                        label: 'ID Mestre ou E-mail',
                        placeholder: 'RM-USER-01 ou e-mail',
                        controller: masterIdController,
                        prefixIcon: const Icon(LucideIcons.terminal, size: 18),
                      ),
                      const SizedBox(height: 24),
                      RetroTextField(
                        label: 'Chave de Segurança',
                        placeholder: '••••••••',
                        isPassword: true,
                        controller: passwordController,
                        prefixIcon: const Icon(LucideIcons.lock, size: 18),
                      ),
                      
                      if (error.value != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            border: const Border(
                              left: BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error.value!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      RetroButton(
                        label: 'Entrar no Sistema',
                        isLoading: isLoading.value,
                        onPressed: handleLogin,
                        icon: const Icon(Icons.chevron_right, size: 18),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'AVISO: O PAINEL DE ADMINISTRAÇÃO ESTÁ DISPONÍVEL EXCLUSIVAMENTE NA VERSÃO WEB.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 7,
                          letterSpacing: 1,
                          color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.5),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Social Login Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OU ACESSO RÁPIDO',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          Expanded(child: Divider(color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.1))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: RetroButton(
                              label: 'Google',
                              color: Colors.white10,
                              onPressed: handleGoogleLogin,
                              icon: const Icon(LucideIcons.mail, size: 18, color: Colors.white),
                            ),
                          ),
                          if (Platform.isIOS) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: RetroButton(
                                label: 'Apple',
                                color: Colors.white10,
                                onPressed: handleAppleLogin,
                                icon: const Icon(LucideIcons.apple, size: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 48),

                Text(
                  'INDÚSTRIAS SMILE © 2026',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 4.0,
                    color: RetroTheme.kIndustrialSilver.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
