import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:subtitle_downloader/features/file_manager/ui/file_manager_page.dart';

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
    return ValueListenableBuilder<VoidCallback?>(
      valueListenable: FileManagerPage.backHandler,
      builder: (context, backHandler, child) {
        final shouldIntercept = _selectedIndex == 2 && backHandler != null;
        return PopScope(
          canPop: !shouldIntercept,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && shouldIntercept) backHandler!();
          },
          child: child!,
        );
      },
      child: Scaffold(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),

            label: 'File Manager',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      ),
    );
  }
}
