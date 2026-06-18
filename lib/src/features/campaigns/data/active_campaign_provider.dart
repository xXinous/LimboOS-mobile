import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/campaign.dart';
import 'campaign_repository.dart';
import '../../characters/data/character_providers.dart';

part 'active_campaign_provider.g.dart';

@riverpod
Stream<Campaign?> activeCampaign(ActiveCampaignRef ref) {
  final activeCharacter = ref.watch(activeCharacterProvider);
  if (activeCharacter == null || activeCharacter.campaignId == null) {
    return Stream.value(null);
  }

  return ref.watch(campaignRepositoryProvider).watchActiveCampaigns().map(
    (campaigns) {
      try {
        return campaigns.firstWhere(
          (c) => c.id == activeCharacter.campaignId,
        );
      } catch (_) {
        // Campanha não encontrada na lista ativa — retorna null sem lançar exceção
        return null;
      }
    },
  );
}
