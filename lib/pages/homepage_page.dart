import 'package:flutter/material.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final String baseUrl = "http://127.0.0.1:8000";

  bool isLoading = true;
  String userName = "กำลังโหลด...";

  // จำนวนยาแต่ละช่วงเวลา
  int morningCount = 0;
  int lunchCount = 0;
  int dinnerCount = 0;

  // ข้อมูลยาช่วงเช้าตัวแรกสำหรับกล่องล่าง
  String currentMedicineName = "-";
  int currentDosage = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      const int targetUserId = 1; // ID คนไข้ที่ต้องการแสดง (เปลี่ยนได้ตามต้องการ)

      // ดึงข้อมูล User
      final userResponse = await http.get(Uri.parse('$baseUrl/user?user_id=$targetUserId'));

      // ดึงข้อมูล Schedules ของ User
      final scheduleResponse = await http.get(Uri.parse('$baseUrl/schedule?user_id=$targetUserId'));

      if (userResponse.statusCode == 200 && scheduleResponse.statusCode == 200) {
        final userData = jsonDecode(utf8.decode(userResponse.bodyBytes));
        final List<dynamic> schedules = jsonDecode(utf8.decode(scheduleResponse.bodyBytes));

        // นับจำนวนยาแต่ละช่วงเวลา
        int mCount = 0;
        int lCount = 0;
        int dCount = 0;
        String firstMedDesc = "ไม่มีรายการยา";
        int firstDosage = 0;

        for (var item in schedules) {
          String time = item['time_to_take'] ?? '';
          if (time.contains('เช้า')) {
            mCount++;
            if (firstMedDesc == "ไม่มีรายการยา") {
              firstDosage = item['dosage_amount'] ?? 1;
              firstMedDesc = "รหัสยา TPU: ${item['tpu_code']}";
            }
          } else if (time.contains('กลางวัน')) {
            lCount++;
          } else if (time.contains('เย็น')) {
            dCount++;
          }
        }

        // หากต้องการดึงชื่อยาจากตาราง medicines เพิ่มเติม
        if (schedules.isNotEmpty && schedules[0]['tpu_code'] != null) {
          final medRes = await http.get(
            Uri.parse('$baseUrl/medicine?tpu_code=${schedules[0]['tpu_code']}'),
          );
          if (medRes.statusCode == 200) {
            final medData = jsonDecode(utf8.decode(medRes.bodyBytes));
            firstMedDesc = medData['trade_name'] ?? firstMedDesc;
          }
        }

        setState(() {
          userName = userData['name'] ?? 'ไม่ระบุชื่อ';
          morningCount = mCount;
          lunchCount = lCount;
          dinnerCount = dCount;
          currentMedicineName = firstMedDesc;
          currentDosage = firstDosage;
          isLoading = false;
        });
      } else {
        setState(() {
          userName = "โหลดข้อมูลล้มเหลว";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        userName = "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สวัสดี !',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF294549),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'คุณ$userName',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF4E7F90),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFF294549),
                      child: Icon(
                        Icons.person,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBD7DA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยาวันนี้',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF294549)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'วันจันทร์ที่ 20 ตุลาคม 2569',
                        style: TextStyle(fontSize: 16, color: Color(0xFF294549)),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMealItem('เช้า', morningCount.toString()),
                          _buildMealItem('กลางวัน', lunchCount.toString()),
                          _buildMealItem('เย็น', dinnerCount.toString()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, color: Color(0xFF294549)),
                                label: const Text('เพิ่มรายการยา', style: TextStyle(color: Color(0xFF294549))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF294549)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E7F90),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('ดูตารางยาทั้งหมด', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // กล่องล่าง
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBD7DA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ตอนเช้า (หลังอาหาร)',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF294549),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currentMedicineName $currentDosage เม็ด',
                                style: const TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF294549),
                              child: Icon(Icons.edit, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('กินยาแล้ว', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E7F90),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              label: const Text('บันทึกอาการ', style: TextStyle(color: Colors.black87)),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      )


                      ],
                  ),
                ),
              ],
            ),
          ),
        ),

        //Bottom NavBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // ให้ล็อคไอคอน Home สว่างค้างไว้เป็นหน้าหลักเสมอ
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (int index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppointmentListPage()),
            );
          }
        },

        destinations: <Widget>[
          NavigationDestination(
              selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
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
              selectedIcon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
              icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
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

Widget _buildMealItem(String title, String count) {
  return Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xFFD6D6D6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.image_outlined, size: 38, color: Colors.black54),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF294549),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'x$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF294549),
        ),
      ),
    ],
  );
}
