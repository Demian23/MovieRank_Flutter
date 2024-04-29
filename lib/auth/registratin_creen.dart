import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/auth/auth_repository.dart';
import 'package:movie_rank/model/user.dart';

class RegistrationScreen extends StatefulHookConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _country = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Movie Rank"),
        ),
        body: Center(
            child: Column(
          children: [
            TextField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: _country,
              decoration: const InputDecoration(labelText: "Country"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: _passwordConfirmation,
              decoration:
                  const InputDecoration(labelText: "Password Confirmation"),
            ),
            TextButton(
                onPressed: () {
                  ref.read(authRepositoryProvider).signUp(
                      email: _email.text,
                      password: _password.text,
                      firstName: _firstName.text,
                      lastName: _lastName.text,
                      country: _country.text,
                      role: Role.commonUser);
                },
                child: const Text("Sign up")),
          ],
        )));
  }
}
