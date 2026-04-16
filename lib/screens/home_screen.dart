import 'package:flutter/material.dart';
import 'analyze_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshResults() {
    setState(() {}); // MapScreen에서 StreamBuilder가 자동 갱신되므로 단순 갱신 호출
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      AnalyzeScreen(onResultSaved: _refreshResults),
      MapScreen(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '분석'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
        ],
      ),
    );
  }
}
