import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/campaign.dart';

part 'campaign_repository.g.dart';

class CampaignRepository {
  final FirebaseFirestore _firestore;

  CampaignRepository(this._firestore);

  Future<List<Campaign>> getActiveCampaigns() async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'Ativa')
        .get();
    return snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList();
  }

  Stream<List<Campaign>> watchActiveCampaigns() {
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'Ativa')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList());
  }

  Future<void> setActiveCampaign(String uid, String characterId, String campaignId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .doc(characterId)
        .update({'campaignId': campaignId});
  }
}

@riverpod
CampaignRepository campaignRepository(CampaignRepositoryRef ref) {
  return CampaignRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Campaign>> activeCampaigns(ActiveCampaignsRef ref) {
  return ref.watch(campaignRepositoryProvider).watchActiveCampaigns();
}
