import 'package:flutter/material.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/services/home_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // สร้างอินสแตนซ์เรียกใช้ HomeService
  final HomeService _homeService = HomeService();

  bool isLoading = true;
  String userName = "กำลังโหลด...";

  // จำนวนยาแต่ละช่วงเวลา
  int morningCount = 0;
  int lunchCount = 0;
  int dinnerCount = 0;

  // ข้อมูลยาช่วงเช้าตัวแรกสำหรับกล่องล่าง
  String currentMedicineName = "-";
  int currentDosage = 0;
  bool isTaken = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // ดึงข้อมูลผ่าน HomeService
  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    const int targetUserId = 16;
    final data = await _homeService.fetchDashboardData(targetUserId);

    if (mounted) {
      if (data.isNotEmpty) {
        setState(() {
          userName = data['userName'];
          morningCount = data['morningCount'] ?? 0;
          lunchCount = data['lunchCount'] ?? 0;
          dinnerCount = data['dinnerCount'] ?? 0;
          currentMedicineName = data['currentMedicineName'] ?? '-';
          currentDosage = data['currentDosage'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          userName = "ข้อมูลล้มเหลว";
          isLoading = false;
        });
      }
    }
  }

  // เปลี่ยนสถานะการกินยา
  void _showEditMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('แก้ไขสถานะการกินยา'),
          content: Text(
            isTaken
                ? 'ต้องการเปลี่ยนสถานะเป็น "ยังไม่ได้กิน" ใช่หรือไม่?'
                : 'ต้องการเปลี่ยนสถานะเป็น "กินยาแล้ว" ใช่หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294549),
              ),
              onPressed: () {
                setState(() {
                  isTaken = !isTaken;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTaken
                          ? 'บันทึกเป็น "กินยาแล้ว"'
                          : 'เปลี่ยนสถานะเป็น "ยังไม่ได้กิน" เรียบร้อยแล้ว',
                    ),
                  ),
                );
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // กรอกบันทึกอาการ
  void _showSymptomDialog() {
    final symptomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('บันทึกอาการ'),
          content: TextField(
            controller: symptomController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'กรอกรายละเอียดอาการ เช่น ปวดหัว, คลื่นไส้...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294549),
              ),
              onPressed: () {
                final inputSymptom = symptomController.text;
                if (inputSymptom.isNotEmpty) {
                  // ส่งข้อมูล inputSymptom ไปยัง API
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('บันทึกอาการเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'สวัสดี !',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF294549),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'คุณ$userName',
                        style: const TextStyle(
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

              // Card สรุปยาวันนี้
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF294549),
                      ),
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

                    Row(
                      children: [
                        // ปุ่มเพิ่มรายการยาไปหน้า SearchMedicinePage
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchMedicinePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Color(0xFF294549)),
                            label: const Text(
                              'เพิ่มรายการยา',
                              style: TextStyle(color: Color(0xFF294549)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF294549)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ปุ่มดูตารางยาทั้งหมดไปหน้า HistoryTableListPage
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryTableListPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E7F90),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'ดูตารางยาทั้งหมด',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card รายการยาล่าสุด/ยาถัดไป
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
                        // ปุ่มแก้ไขรายการยา
                        InkWell(
                          onTap: _showEditMedicineDialog,
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
                        // ปุ่มกินยาแล้ว
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isTaken = !isTaken;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isTaken
                                        ? 'บันทึกการกินยาเรียบร้อยแล้ว'
                                        : 'เปลี่ยนสถานะเป็น "ยังไม่ได้กินยา" แล้ว',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              isTaken ? Icons.check : Icons.circle_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              isTaken ? 'กินยาแล้ว' : 'ยังไม่ได้กินยา',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTaken
                                  ? const Color(0xFF4E7F90)
                                  : Color(0xFF4A807E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ปุ่มบันทึกอาการ
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showSymptomDialog,
                            label: const Text(
                              'บันทึกอาการ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.black87,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (int index) {
          if (index == 0) return;

          Widget targetPage;
          switch (index) {
            case 1:
              targetPage = const SearchMedicinePage();
              break;
            case 2:
              targetPage = const HistoryTableListPage();
              break;
            case 3:
              targetPage = const AppointmentListPage();
              break;
            default:
              return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
            icon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
            label: "",
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