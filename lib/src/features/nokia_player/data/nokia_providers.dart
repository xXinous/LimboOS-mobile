import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/intel_item.dart';
import '../domain/nokia_sms.dart';
import 'intel_repository.dart';
import '../../campaigns/data/active_campaign_provider.dart';

part 'nokia_providers.g.dart';

enum NokiaScreen {
  player,
  profile,
  scanner,
  smsDetail,
}

@riverpod
class NokiaScreenState extends _$NokiaScreenState {
  @override
  NokiaScreen build() => NokiaScreen.player;

  void setScreen(NokiaScreen screen) {
    state = screen;
  }
}

@riverpod
class NokiaVolume extends _$NokiaVolume {
  @override
  int build() => 80;

  void setVolume(int value) {
    state = value.clamp(0, 100);
  }
}

@riverpod
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

@riverpod
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

@riverpod
class NokiaAudioPlaybackStatus extends _$NokiaAudioPlaybackStatus {
  @override
  NokiaAudioStatus build() => NokiaAudioStatus.idle;

  void setStatus(NokiaAudioStatus status) {
    state = status;
  }
}

@riverpod
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

@riverpod
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

@riverpod
Stream<List<IntelItem>> campaignIntelList(CampaignIntelListRef ref) {
  final intelRepo = ref.watch(intelRepositoryProvider);
  final activeCampaign = ref.watch(activeCampaignProvider).value;
  
  // Exposes a stream of all media assets from Firestore
  return intelRepo.watchAllMediaAssets().map((allMedia) {
    if (activeCampaign == null) return [];
    // Filter to show only items matching active campaign or items without campaignId
    return allMedia
        .where((item) =>
            item.campaignId == null || item.campaignId == activeCampaign.id)
        .toList();
  });
}
