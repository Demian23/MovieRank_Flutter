import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/auth/login_screen.dart';
import 'package:movie_rank/bussiness_logic/root.dart';

class AuthCheck extends ConsumerWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    if (authController.firebaseUserSession != null) {
      return const Root();
    } else {
      return const LoginScreen();
    }
  }
}
