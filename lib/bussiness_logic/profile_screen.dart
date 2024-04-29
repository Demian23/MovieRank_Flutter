import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/model/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User user = ref.read(authControllerProvider).userData!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey,
                  child: Text(user.initials)),
              Column(
                children: [
                  Text("${user.firstName} ${user.lastName}"),
                  Text(user.email)
                ],
              )
            ],
          ),
          Text(user.country),
          Text(user.role.toViewableString()),
          Text(user.country),
          Text(user.userScore.toString()),
          TextButton(
            child: const Text("SignOut"),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
          TextButton(
            child: const Text("Delete Account"),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).deleteAccount(),
          ),
          TextButton(
            child: const Text("Reset password"),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).resetPassword(),
          ),
        ],
      ),
    );
  }
}
