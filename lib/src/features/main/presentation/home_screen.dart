import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/retro_skeleton.dart';
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

          // Map screens to IndexedStack indices (scanner is handled separately)
          int stackIndex;
          switch (nokiaScreen) {
            case NokiaScreen.profile:
              stackIndex = 1;
              break;
            case NokiaScreen.smsDetail:
              stackIndex = 2;
              break;
            case NokiaScreen.player:
            case NokiaScreen.scanner:
              stackIndex = 0;
              break;
          }

          // IndexedStack preserves state of all children (scroll, text fields, etc.)
          // Scanner is overlaid conditionally to avoid keeping camera active in background
          return NokiaDeviceWrapper(
            child: Stack(
              children: [
                IndexedStack(
                  index: stackIndex,
                  children: const [
                    NokiaPlayerView(),
                    NokiaProfileView(),
                    NokiaSmsDetailView(),
                  ],
                ),
                if (nokiaScreen == NokiaScreen.scanner)
                  const Positioned.fill(child: NokiaScannerView()),
              ],
            ),
          );
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
      loading: () => Scaffold(
        backgroundColor: Colors.black,
        body: RetroSkeleton.fullScreen(),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Erro ao carregar campanha: $err'),
        ),
      ),
    );
  }
}
