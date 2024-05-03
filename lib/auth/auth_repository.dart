import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_exception.dart';
import 'package:movie_rank/bussiness_logic/user_repository.dart';
import 'package:movie_rank/model/user.dart' as mr;
import 'package:movie_rank/providers.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthRepository {
  AuthRepository(this._ref);
  final Ref _ref;

  Stream<User?> get authStateChanges =>
      _ref.read(firebaseAuthProvider).authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(msg: e.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _ref.read(firebaseAuthProvider).currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(msg: e.message);
      // TODO handle reauthanticate
    }
  }

  Future<String> createNewUserAndReturnId(
      {required String email, required String password}) async {
    try {
      final UserCredential cred = await _ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
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

  Future<void> signUp(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required mr.Role role,
      required String country}) async {
    final uid =
        await createNewUserAndReturnId(email: email, password: password);
    await _ref
        .read(userRepositoryProvider)
        .createNewUser(mr.User(uid, firstName, lastName, email, role, country));
    await signIn(email: email, password: password);
  }

  void signOut() async {
    await _ref.read(firebaseAuthProvider).signOut();
  }
}
