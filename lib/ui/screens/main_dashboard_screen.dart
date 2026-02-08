import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    StoreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 5, 5, 17),
        elevation: 8,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[200],
        unselectedItemColor: Colors.grey[300],
        selectedLabelStyle: const TextStyle(
          fontFamily: 'MedievalSharp',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'MedievalSharp',
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Misiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_mall),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
