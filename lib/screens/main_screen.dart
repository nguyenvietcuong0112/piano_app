import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/theme_tab.dart';
import 'tabs/piano_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    ThemeTab(),
    PianoTab(),
  ];

  final List<String> _titles = const [
    "The Piano",
    "Themes",
    "Piano",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF1E0248),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF1F0248),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: "Themes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.piano),
            label: "Piano",
          ),
        ],
      ),
    );
  }
}
