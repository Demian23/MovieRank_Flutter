import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_exception.dart';
import 'package:movie_rank/auth/auth_repository.dart';
import 'package:movie_rank/model/user.dart';
import 'package:movie_rank/user/user_repository.dart';

final authControllerProvider = Provider<AuthController>((ref) => AuthController(
    ref.read(authRepositoryProvider), ref.read(userRepositoryProvider)));

class AuthController {
  final AuthRepository _authRep;
  final UserRepository _userRep;

  AuthController(this._authRep, this._userRep);

  Future<void> signUp(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required Role role,
      required String country}) async {
    _throwIfSignUpDataInvalid(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        country: country);
    final uid = await _authRep.createNewUserAndReturnId(
        email: email, password: password);
    await _userRep
        .createNewUser(User(uid, firstName, lastName, email, role, country));
    await _authRep.signIn(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    _throwIfSignInDataInvalid(email: email, password: password);
    await _authRep.signIn(email: email, password: password);
  }

  void _throwIfSignUpDataInvalid(
      {required String email,
      required String password,
      required String firstName,
      required String lastName,
      required Role role,
      required String country}) {
    bool result = email.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        country.isNotEmpty &&
        password.length > 6;
    if (!result) throw const AuthException(msg: "Invalid sign up data!");
  }

  void _throwIfSignInDataInvalid(
      {required String email, required String password}) {
    bool result =
        email.isNotEmpty && password.isNotEmpty && password.length > 6;
    if (!result) throw const AuthException(msg: "Invalid credentials!");
  }

  // TODO implement sign in here with complete validation for all here
}
