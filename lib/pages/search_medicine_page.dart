import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/pages/medicine_detail_page.dart';

class SearchMedicinePage extends StatefulWidget {
  const SearchMedicinePage({super.key});

  @override
  State<SearchMedicinePage> createState() => _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {

  final List<Map<String, String>> medicineList = [
    {'name': 'ชื่อยา', 'time': 'เช้า', 'quantity': 'x1'},
    {'name': 'ชื่อยา', 'time': 'เช้า', 'quantity': 'x1'},
    {'name': 'ชื่อยา', 'time': 'เช้า', 'quantity': 'x1'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4E7F90),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                    'ค้นหายาของคุณ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ชื่อยา หรือ กลุ่มอาการ',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF294549)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                    child: ListView.separated(
                        itemCount: medicineList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = medicineList[index];
                          return _MedicineCard(
                            name: item['name']!,
                            time: item['time']!,
                            quantity: item['quantity']!,
                          );
                        },

                    ),
                ),
              ],
            ),
          ),
      ),



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
              selectedIcon: Icon(Icons.search, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.search, color: Color(0xFF90C2B7), size: 36),
              label: ""
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
      )
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String quantity;

  const _MedicineCard({
    required this.name,
    required this.time,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailPage(name: name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFBBD7DA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // กล่องสี่เหลี่ยมรูปภาพยา
            Container(
              width: 110,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(12),
              ),

              // ใส่รูป
              child: const Icon(
                Icons.image_outlined,
                size: 44,
                color: Color(0xFFDCDCDC),
              ),
            ),
            const SizedBox(width: 16),

            // รายละเอียดข้อความฝั่งขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}