import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/intel_item.dart';
import '../domain/nokia_sms.dart';
import 'intel_repository.dart';
import '../../campaigns/data/active_campaign_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../characters/data/character_providers.dart';

part 'nokia_providers.g.dart';

enum NokiaScreen {
  player,
  profile,
  scanner,
  smsDetail,
}

@Riverpod(keepAlive: true)
class NokiaScreenState extends _$NokiaScreenState {
  @override
  NokiaScreen build() => NokiaScreen.player;

  void setScreen(NokiaScreen screen) {
    state = screen;
  }
}

@Riverpod(keepAlive: true)
class NokiaVolume extends _$NokiaVolume {
  @override
  int build() => 80;

  void setVolume(int value) {
    state = value.clamp(0, 100);
  }
}

@Riverpod(keepAlive: true)
class NokiaMute extends _$NokiaMute {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setMute(bool value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
class ActiveAudioIntel extends _$ActiveAudioIntel {
  @override
  IntelItem? build() => null;

  void select(IntelItem item) {
    state = item;
  }

  void clear() {
    state = null;
  }
}

enum NokiaAudioStatus {
  idle,
  loading,
  loaded,
  playing,
  rewinding,
}

@Riverpod(keepAlive: true)
class NokiaAudioPlaybackStatus extends _$NokiaAudioPlaybackStatus {
  @override
  NokiaAudioStatus build() => NokiaAudioStatus.idle;

  void setStatus(NokiaAudioStatus status) {
    state = status;
  }
}

@Riverpod(keepAlive: true)
class NokiaActiveSms extends _$NokiaActiveSms {
  @override
  NokiaSms? build() => null;

  void select(NokiaSms sms) {
    state = sms;
  }

  void clear() {
    state = null;
  }
}

@Riverpod(keepAlive: true)
class NokiaSmsList extends _$NokiaSmsList {
  @override
  List<NokiaSms> build() {
    return [
      NokiaSms(
        id: '1',
        sender: 'DESCONHECIDO',
        text: 'Você ainda está aí?',
        time: '10:42',
        read: false,
      ),
      NokiaSms(
        id: '2',
        sender: 'AGENTE K',
        text: 'O pacote foi entregue no ponto de encontro.',
        time: 'Ontem',
        read: true,
      ),
      NokiaSms(
        id: '3',
        sender: 'SISTEMA',
        text: 'Nova pista detectada na zona sul.',
        time: 'Segunda',
        read: true,
      ),
      NokiaSms(
        id: '4',
        sender: 'OPERADOR',
        text: 'Mantenha silêncio de rádio até novas ordens.',
        time: '23/05',
        read: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final sms in state)
        if (sms.id == id) sms.copyWith(read: true) else sms,
    ];
  }
}

@Riverpod(keepAlive: true)
Stream<List<String>> unlockedIntelIds(UnlockedIntelIdsRef ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  final character = ref.watch(activeCharacterProvider);
  if (authState == null || character == null) {
    return Stream.value([]);
  }
  final intelRepo = ref.watch(intelRepositoryProvider);
  return intelRepo.watchUnlockedIntelIds(authState.uid, character.id);
}

@Riverpod(keepAlive: true)
Stream<List<IntelItem>> campaignIntelList(CampaignIntelListRef ref) {
  final intelRepo = ref.watch(intelRepositoryProvider);
  final activeCampaign = ref.watch(activeCampaignProvider).value;
  final unlockedIdsAsync = ref.watch(unlockedIntelIdsProvider);
  
  // Exposes a stream of all media assets from Firestore
  return intelRepo.watchAllMediaAssets().map((allMedia) {
    if (activeCampaign == null) return [];
    final unlockedIds = unlockedIdsAsync.value ?? [];
    
    // Filter to show only items matching active campaign AND are unlocked by this character
    return allMedia
        .where((item) =>
            (item.campaignId == null || item.campaignId == activeCampaign.id) &&
            unlockedIds.contains(item.id))
        .toList();
  });
}
