import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/aux/text_with_icon_and_label.dart';
import 'package:movie_rank/model/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(authControllerProvider);
    if (controller.userData != null) {
      final user = controller.userData!;
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(user.initials)),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      children: [
                        Text("${user.firstName} ${user.lastName}",
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(user.email,
                            style: Theme.of(context).textTheme.labelLarge)
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextWithIconLabel(
                        label: "Country: ",
                        icon: Icons.place,
                        text: user.country),
                    TextWithIconLabel(
                        label: "Role: ",
                        icon: Icons.work,
                        text: user.role.toViewableString()),
                    TextWithIconLabel(
                        label: "Score: ",
                        icon: Icons.score,
                        text: user.userScore.toString()),
                    TextButton(
                      child: const TextWithIconLabel(
                          label: "Sign Out", icon: Icons.exit_to_app, text: ''),
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                    ),
                    TextButton(
                      child: const TextWithIconLabel(
                          label: "Delete Account",
                          icon: Icons.delete_forever,
                          text: ''),
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .deleteAccount(),
                    ),
                    TextButton(
                      child: const TextWithIconLabel(
                          label: "Reset password", icon: Icons.loop, text: ''),
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .resetPassword(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
