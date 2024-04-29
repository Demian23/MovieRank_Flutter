class AuthException implements Exception {
  final String? msg;
  const AuthException({this.msg = "Unknown authentication error"});
  @override
  String toString() => "AuthException {msg: $msg}";
}
