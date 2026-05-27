import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/characters/data/character_providers.dart';
import '../features/characters/presentation/select_agent_screen.dart';
import '../features/campaigns/presentation/campaign_selection_screen.dart';
import '../features/main/presentation/home_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final activeCharacter = ref.watch(activeCharacterProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // Se logado mas sem agente selecionado
      if (activeCharacter == null) {
        return state.matchedLocation == '/select-agent' ? null : '/select-agent';
      }

      // Se tem agente mas não tem campanha
      if (activeCharacter.campaignId == null) {
        return state.matchedLocation == '/select-campaign' ? null : '/select-campaign';
      }

      // Se tem agente e campanha, mas está em telas de seleção ou login
      if (isLoggingIn || 
          state.matchedLocation == '/select-agent' || 
          state.matchedLocation == '/select-campaign') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-agent',
        builder: (context, state) => const SelectAgentScreen(),
      ),
      GoRoute(
        path: '/select-campaign',
        builder: (context, state) => const CampaignSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
