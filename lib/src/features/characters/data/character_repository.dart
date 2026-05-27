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
    print('DEBUG: Watching characters for UID: $uid');
    // Try without filter first to see if anything comes back
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('characters')
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Raw Snapshot for $uid. Total docs in subcollection: ${snapshot.docs.length}');
          
          final characters = snapshot.docs.map((doc) {
            final data = doc.data();
            print('DEBUG: Processing doc: ${doc.id}');
            print('DEBUG: Doc data: $data');
            return Character.fromFirestore(doc);
          }).toList();

          // Client-side filtering as a fallback/test
          final filtered = characters.where((c) => !c.archived).toList();
          print('DEBUG: After client-side archive filter: ${filtered.length}');
          
          return filtered;
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
