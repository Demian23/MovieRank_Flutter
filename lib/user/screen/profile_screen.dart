import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rank/user/user_controller.dart';
import 'package:movie_rank/auth/auth_exception.dart';
import 'package:movie_rank/auth/auth_repository.dart';
import 'package:movie_rank/aux/text_with_icon_and_label.dart';
import 'package:movie_rank/movies/movies_controller.dart';
import 'package:movie_rank/model/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(userControllerProvider);
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
                            label: "Sign Out",
                            icon: Icons.exit_to_app,
                            text: ''),
                        onPressed: () {
                          ref.read(userControllerProvider.notifier).signOut();
                          ref
                              .read(moviesControllerProvider.notifier)
                              .clearCaches();
                        }),
                    TextButton(
                      child: const TextWithIconLabel(
                          label: "Delete Account",
                          icon: Icons.delete_forever,
                          text: ''),
                      onPressed: () async {
                        try {
                          await ref
                              .read(authRepositoryProvider)
                              .deleteAccount();
                          ref.read(userControllerProvider.notifier).signOut();
                        } on AuthException catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(e.msg!), // TODO use colors from theme
                            ));
                          }
                        }
                      },
                    ),
                    TextButton(
                      child: const TextWithIconLabel(
                          label: "Reset password", icon: Icons.loop, text: ''),
                      onPressed: () => ref
                          .read(userControllerProvider.notifier)
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
