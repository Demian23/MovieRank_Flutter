import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_exception.dart';
import 'package:movie_rank/global_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(firebaseAuthProvider)));

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(msg: e.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(msg: e.message);
      // TODO handle reauthanticate
    }
  }

  Future<String> createNewUserAndReturnId(
      {required String email, required String password}) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException(msg: "$email is already in use!");
        case 'invalid-email':
          throw AuthException(msg: "$email is invalid email!");
        case 'weak-password':
          throw AuthException(msg: "$password is too week!");
        default:
          throw const AuthException();
      }
    }
  }

  void signOut() async {
    await _auth.signOut();
  }
}
