import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';

class MedicineDetailPage extends StatefulWidget {
  const MedicineDetailPage({super.key});

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(



      //Bottom NavBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // ให้ล็อคไอคอน Home สว่างค้างไว้เป็นหน้าหลักเสมอ
        onDestinationSelected: (int index) {},
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,
        destinations: <Widget>[
          NavigationDestination(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Icon(Icons.home_outlined, color: Color(0xFF4A807E), size: 36),
            ),
            label: "",
          ),
          NavigationDestination(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
                );
              },
              child: const Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
            ),
            label: "",
          ),
          NavigationDestination(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
                );
              },
              child: const Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
            ),
            label: "",
          ),
          NavigationDestination(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentListPage()),
                );
              },
              child: const Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
            ),
            label: "",
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
              label: ""
          ),
        ],
      ),
    );
  }
}
