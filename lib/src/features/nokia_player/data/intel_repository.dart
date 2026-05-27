import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/intel_item.dart';

part 'intel_repository.g.dart';

class IntelRepository {
  final FirebaseFirestore _firestore;

  IntelRepository(this._firestore);

  Stream<List<String>> watchUnlockedIntelIds(String uid, String characterId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .doc(characterId)
        .collection('intel')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<List<IntelItem>> watchAllMediaAssets() {
    return _firestore
        .collection('mediaAssets')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IntelItem.fromFirestore(doc)).toList());
  }

  Future<String?> resolveQrCode(String code) async {
    try {
      final docSnap = await _firestore.collection('qrRedirects').doc(code).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        return data?['targetId'] as String?;
      }
    } catch (e) {
      print('Error resolving QR code redirect: $e');
    }
    return null;
  }

  Future<void> unlockIntel({
    required String uid,
    required String characterId,
    required String intelId,
    String? campaignId,
    String type = 'AUDIO',
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .doc(characterId)
        .collection('intel')
        .doc(intelId);

    await ref.set({
      'intelId': intelId,
      'unlockedAt': FieldValue.serverTimestamp(),
      'campaignId': campaignId,
      'type': type,
    }, SetOptions(merge: true));
  }
}

@riverpod
IntelRepository intelRepository(IntelRepositoryRef ref) {
  return IntelRepository(FirebaseFirestore.instance);
}
