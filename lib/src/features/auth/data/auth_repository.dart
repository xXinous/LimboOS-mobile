import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/master_account.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository(this._auth, this._firestore);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String _masterIdToEmail(String masterId) {
    final slug = masterId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
    return '$slug@runningman.local';
  }

  Future<MasterAccount> loginOrCreate(String masterId, String password) async {
    final isLegacyEmail = masterId.contains('@') && masterId.contains('.');
    final email = isLegacyEmail ? masterId.trim() : _masterIdToEmail(masterId);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getOrCreateMasterAccount(credential.user!, masterId: masterId);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _getOrCreateMasterAccount(credential.user!, masterId: masterId);
      }
      rethrow;
    }
  }

  Future<MasterAccount> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google Sign-In canceled');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _getOrCreateMasterAccount(userCredential.user!);
  }

  Future<MasterAccount> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    final AuthCredential authCredential = oAuthProvider.credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(authCredential);
    return _getOrCreateMasterAccount(userCredential.user!);
  }

  Future<MasterAccount> _getOrCreateMasterAccount(User user, {String? masterId}) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    
    if (!doc.exists) {
      final account = MasterAccount(
        uid: user.uid,
        email: user.email ?? '',
        masterName: masterId,
        displayName: user.displayName,
        role: 'player',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(account.toFirestore());
      return account;
    } else {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return MasterAccount.fromFirestore(doc);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
Stream<MasterAccount?> currentMasterAccount(CurrentMasterAccountRef ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots(includeMetadataChanges: true)
      .map((doc) => doc.exists ? MasterAccount.fromFirestore(doc) : null);
}
