import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_rank/auth/auth_repository.dart';
import 'package:movie_rank/user/user_repository.dart';
import 'package:movie_rank/model/user.dart' as mr;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, UserSession>(
  (ref) => AuthController(ref),
);

final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.read(authRepositoryProvider).authStateChanges,
);

class UserSession {
  User? firebaseUserSession;
  mr.User? userData;
  UserSession(this.firebaseUserSession, this.userData);
}

class AuthController extends StateNotifier<UserSession> {
  final Ref _ref;

  AuthController(this._ref) : super(UserSession(null, null)) {
    final authState = _ref.watch(authStateChangesProvider);
    authState.when(
      data: (user) async {
        if (user != null) {
          final userData =
              await _ref.read(userRepositoryProvider).fetchUser(uid: user.uid);
          state = UserSession(user, userData);
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }

  void resetPassword() {}

  void signOut() {
    _ref.read(authRepositoryProvider).signOut();
    state = UserSession(null, null);
  }
}
