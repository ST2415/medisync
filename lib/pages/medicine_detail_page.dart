import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';

class MedicineDetailPage extends StatefulWidget {
  final String name;

  const MedicineDetailPage({
    super.key,
    required this.name,
  });

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4E7F90),
      appBar: AppBar(
        backgroundColor: Color(0xFF294549),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFBBD7DA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // กล่องรูป

                Container(
                  width: double.infinity,
                  height: 220,

                  // ใส่รูปภาพ

                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Color(0xFFDCDCDC),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF294549),
                  ),
                ),
                const SizedBox(height: 16),

                _buildDetailRow('รักษา', 'อาการปวดหัว'),
                _buildDetailRow('รับประทานตอน', 'เช้า'),
                _buildDetailRow('ขนาด', '500 กรัม'),
                _buildDetailRow('รูปแบบทางเภสัชกรรม', 'ยาเม็ด'),
                _buildDetailRow('ผลข้างเคียง', 'มึนและวินเวียนศีรษะ'),
                _buildDetailRow('ข้อควรระวัง', 'ไม่ควรรับประทานขณะขับขี่'),
                _buildDetailRow('ตัวยาสำคัญ', 'amlodipine'),
              ],
            ),
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

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
