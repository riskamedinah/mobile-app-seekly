import 'package:flutter/material.dart';
import '../../home/views/home_view.dart';
import '../../exam/views/exam_view.dart';
import '../../notification/views/notification_view.dart';
import '../../profile/views/profile_view.dart';

class NavbarView extends StatefulWidget {
  const NavbarView({Key? key}) : super(key: key);

  @override
  State<NavbarView> createState() => _NavbarViewState();
}

class _NavbarViewState extends State<NavbarView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    ExamView(),
    NotificationView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: Colors.grey[300]),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/home.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 0 ? Colors.deepOrange : Colors.grey,
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/document.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 1 ? Colors.deepOrange : Colors.grey,
                ),
                label: 'Ujian',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/notification.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 2 ? Colors.deepOrange : Colors.grey,
                ),
                label: 'Notifikasi',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'images/profile.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 3 ? Colors.deepOrange : Colors.grey,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
