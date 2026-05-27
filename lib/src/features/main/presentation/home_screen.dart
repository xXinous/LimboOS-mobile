import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../characters/data/character_providers.dart';
import '../../campaigns/data/active_campaign_provider.dart';
import '../../campaigns/domain/campaign.dart';
import '../../nokia_player/data/nokia_providers.dart';
import '../../nokia_player/presentation/nokia_device_wrapper.dart';
import '../../nokia_player/presentation/nokia_player_view.dart';
import '../../nokia_player/presentation/nokia_profile_view.dart';
import '../../nokia_player/presentation/nokia_scanner_view.dart';
import '../../nokia_player/presentation/nokia_sms_detail_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(activeCharacterProvider);
    final activeCampaignAsync = ref.watch(activeCampaignProvider);

    return activeCampaignAsync.when(
      data: (campaign) {
        if (campaign != null && campaign.playerType == PlayerType.nokia) {
          final nokiaScreen = ref.watch(nokiaScreenStateProvider);

          Widget innerView;
          switch (nokiaScreen) {
            case NokiaScreen.player:
              innerView = const NokiaPlayerView();
              break;
            case NokiaScreen.profile:
              innerView = const NokiaProfileView();
              break;
            case NokiaScreen.scanner:
              innerView = const NokiaScannerView();
              break;
            case NokiaScreen.smsDetail:
              innerView = const NokiaSmsDetailView();
              break;
          }

          return NokiaDeviceWrapper(child: innerView);
        }

        // Default Walkman/Placeholder view
        return Scaffold(
          appBar: AppBar(
            title: const Text('LIMBO OS'),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(activeCharacterProvider.notifier).clear();
                },
                icon: const Icon(Icons.switch_account),
                tooltip: 'Trocar Agente',
              ),
              IconButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('AGENTE ATIVO: ${character?.codinome ?? 'NENHUM'}'),
                const SizedBox(height: 20),
                const Text('PLAYER RETRO EM BREVE... (WALKMAN)'),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Erro ao carregar campanha: $err'),
        ),
      ),
    );
  }
}
