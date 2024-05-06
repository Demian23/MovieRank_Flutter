import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/auth/auth_exception.dart';
import 'package:movie_rank/auth/screen/registratin_creen.dart';

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Movie Rank"),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset("assets/images/MovieRankLogo.png"),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                TextButton(
                    onPressed: () async {
                      try {
                        await authController.signIn(
                            email: _emailController.text,
                            password: _passwordController.text);
                      } on AuthException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.msg!), // TODO use colors from theme
                          ));
                        }
                      }
                    },
                    child: const Text("Login")),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const RegistrationScreen()));
                    },
                    child: const Text("Need to Sign Up?"))
              ],
            )));
  }
}
