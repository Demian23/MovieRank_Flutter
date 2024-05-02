import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_rank/auth/auth_controller.dart';
import 'package:movie_rank/auth/login_screen.dart';
import 'package:movie_rank/bussiness_logic/movie_list.dart';
import 'package:movie_rank/bussiness_logic/profile_screen.dart';

class Root extends StatefulHookConsumerWidget {
  const Root({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RootState();
  }
}

class _RootState extends ConsumerState<Root> {
  int _selectedTabScreen = 0;
  static const List<Widget> _screens = <Widget>[
    MovieListScreen(),
    FavouritesListScreen(),
    ProfileScreen(),
  ];

  void _onTabPressed(int index) {
    setState(() {
      _selectedTabScreen = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    if (authController.firebaseUserSession != null) {
      return Scaffold(
        body: Center(
          child: _screens.elementAt(_selectedTabScreen),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
            BottomNavigationBarItem(
                icon: Icon(Icons.star), label: "Favourites"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: "Profile")
          ],
          currentIndex: _selectedTabScreen,
          onTap: _onTabPressed,
        ),
      );
    } else {
      return const LoginScreen();
    }
  }
}
