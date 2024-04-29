import 'package:flutter/material.dart';
import 'package:movie_rank/bussiness_logic/movie_list.dart';
import 'package:movie_rank/bussiness_logic/profile_screen.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _selectedTabPage = 0;
  static const List<Widget> _pages = <Widget>[
    MovieListScreen(),
    Icon(Icons.alarm),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedTabPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favourites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile")
        ],
        currentIndex: _selectedTabPage,
        onTap: _onTabPressed,
      ),
    );
  }

  void _onTabPressed(int index) {
    setState(() {
      _selectedTabPage = index;
    });
  }
}
