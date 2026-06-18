import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/character.dart';

part 'character_repository.g.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore;

  CharacterRepository(this._firestore);

  Future<List<Character>> getCharactersForUser(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .where('archived', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => Character.fromFirestore(doc)).toList();
  }

  Stream<List<Character>> watchCharactersForUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .where('archived', isEqualTo: false)   // filtro no servidor — economiza leituras e bytes
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          return snapshot.docs.map((doc) => Character.fromFirestore(doc)).toList();
        });
  }
}

@riverpod
CharacterRepository characterRepository(CharacterRepositoryRef ref) {
  return CharacterRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Character>> userCharacters(UserCharactersRef ref, String uid) {
  return ref.watch(characterRepositoryProvider).watchCharactersForUser(uid);
}
