import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(



      //Bottom NavBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // ให้ล็อคไอคอน Home สว่างค้างไว้เป็นหน้าหลักเสมอ
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
            );
          }
        },

        destinations: <Widget>[
          NavigationDestination(
              selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF4A807E), size: 36),
              icon: Icon(Icons.home_outlined, color: Color(0xFF4A807E), size: 36),
              label: ""
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
              icon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
              label: ""
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
              icon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
              label: ""
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.notifications_none_outlined, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF90C2B7), size: 36),
              label: ""
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
              icon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
              label: ""
          ),
        ],
      ),
    );
  }
}
