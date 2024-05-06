import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _goToBranch(index);
        },
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_rounded),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv_rounded),
            label: 'TV',
          ),
        ],
      ),
    );
  }
}
