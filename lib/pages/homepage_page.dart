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
  final HomeService _homeService = HomeService();

  bool isLoading = true;
  String userName = "กำลังโหลด...";

  // จำนวนยาแต่ละช่วงเวลา
  int morningCount = 0;
  int lunchCount = 0;
  int dinnerCount = 0;

  // URL รูปภาพของยาแต่ละช่วงเวลา
  String? morningImage;
  String? lunchImage;
  String? dinnerImage;

  // ข้อมูลยาช่วงเช้าตัวแรกสำหรับกล่องล่าง
  String? currentScheduleId;
  String? currentLogId; // เก็บ log_id สำหรับการอัปเดต/ลบรายการกินยา
  String currentMedicineName = "ไม่มีรายการยา";
  int currentDosage = 0;
  bool isTaken = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // วันที่จริงภาษาไทย
  String _getFormattedTodayDate() {
    final now = DateTime.now();

    const days = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์'
    ];

    const months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    final dayName = days[now.weekday - 1];
    final dayNum = now.day;
    final monthName = months[now.month - 1];
    final buddhistYear = now.year + 543;

    return '$dayNameที่ $dayNum $monthName $buddhistYear';
  }

  // ดึงข้อมูลผ่าน HomeService (แก้ไข Logic รวมเม็ดยาและรูปภาพ)
  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    const int targetUserId = 16;

    try {
      final data = await _homeService.fetchDashboardData(targetUserId);
      final List<dynamic> todaySchedules =
      await _homeService.fetchTodaySchedules(targetUserId);

      if (mounted) {
        int mCount = 0;
        int lCount = 0;
        int dCount = 0;
        String? mImg;
        String? lImg;
        String? dImg;
        String firstMorningMed = "ไม่มีรายการยา";
        int firstMorningDosage = 0;
        String? firstMorningScheduleId;
        String? firstMorningLogId;
        bool firstMorningTaken = false;

        // วน Loop อ่านรายการยาทั้งหมดโดยไม่มี break ตัดการทำงาน
        for (var item in todaySchedules) {
          final String timeToTake = (item['time_to_take'] ??
              item['time'] ??
              item['meal_time'] ??
              '')
              .toString();

          // รวม URL รูปภาพเต็ม (ต่อ http://127.0.0.1:8000 กรณี Backend ส่งมาเป็น Relative Path)
          String? rawImg = item['image_url'] ?? item['image'] ?? item['picture'];
          if (rawImg != null && rawImg.isNotEmpty && !rawImg.startsWith('http')) {
            rawImg = '${HomeService.baseUrl}${(rawImg.startsWith('/') ? '' : '/')}$rawImg';
          }

          // แปลงจำนวนเม็ดของยาตัวนั้นๆ
          final int dosage = int.tryParse(
              (item['dosage_amount'] ?? item['dosage'] ?? 1).toString()) ?? 1;

          if (timeToTake.contains('เช้า')) {
            mCount += dosage; // บวกจำนวนเม็ดรวม
            mImg ??= rawImg;  // เก็บรูปภาพใบแรกที่เจอ

            if (firstMorningMed == "ไม่มีรายการยา") {
              firstMorningScheduleId = item['schedule_id']?.toString();
              firstMorningLogId =
                  item['log_id']?.toString() ?? item['logId']?.toString();
              firstMorningMed = (item['trade_name'] ??
                  item['medicine_name'] ??
                  item['name'] ??
                  'ไม่ระบุชื่อยา')
                  .toString();
              firstMorningDosage = dosage;
              firstMorningTaken = item['is_taken'] == true ||
                  item['is_taken'] == 1 ||
                  item['status'] == 'taken' ||
                  item['status'] == 1;
            }
          } else if (timeToTake.contains('กลางวัน')) {
            lCount += dosage; // บวกจำนวนเม็ดรวม
            lImg ??= rawImg;  // เก็บรูปภาพใบแรกที่เจอ
          } else if (timeToTake.contains('เย็น')) {
            dCount += dosage; // บวกจำนวนเม็ดรวม
            dImg ??= rawImg;  // เก็บรูปภาพใบแรกที่เจอ
          }
        }

        debugPrint('Morning Schedule ID: $firstMorningScheduleId');
        debugPrint('Morning Log ID: $firstMorningLogId');

        setState(() {
          userName = data['userName'] ?? userName;
          morningCount = mCount;
          lunchCount = lCount;
          dinnerCount = dCount;
          morningImage = mImg;
          lunchImage = lImg;
          dinnerImage = dImg;
          currentScheduleId = firstMorningScheduleId;
          currentLogId = firstMorningLogId;
          currentMedicineName = firstMorningMed;
          currentDosage = firstMorningDosage;
          isTaken = firstMorningTaken;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = "ข้อมูลล้มเหลว";
          isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันสลับสถานะการกินยา พร้อม Alert ยืนยันเมื่อต้องการลบ/ยกเลิก
  Future<void> _toggleTakeMedicine() async {
    debugPrint('กดปุ่มกินยาแล้ว');
    debugPrint('scheduleId: $currentScheduleId');
    debugPrint('logId: $currentLogId');

    if (!isTaken) {
      try {
        final newLogId = await _homeService.addMedicationLog(
          userId: 16,
          scheduleId: currentScheduleId!,
          status: 'taken',
        );

        if (!mounted) return;

        if (newLogId != null) {
          setState(() {
            isTaken = true;
            currentLogId = newLogId;
          });

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('บันทึกเป็น "กินยาแล้ว" เรียบร้อยแล้ว')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลการกินยาได้')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
        );
      }
      return;
    }

    // กดเพื่อยืนยันลบ/ยกเลิกสถานะการกินยา (DELETE)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยกเลิกรายการกินยา'),
        content:
        const Text('ต้องการเปลี่ยนสถานะเป็น "ยังไม่ได้กินยา" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF294549),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (currentLogId != null) {
        await _homeService.deleteMedicationLog(currentLogId!);
      }

      if (!mounted) return;

      setState(() {
        isTaken = false;
        currentLogId = null;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('เปลี่ยนสถานะเป็น "ยังไม่ได้กินยา" เรียบร้อยแล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยกเลิกรายการไม่สำเร็จ: $e')),
      );
    }
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
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกอาการเรียบร้อยแล้ว')),
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
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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

                    Text(
                      _getFormattedTodayDate(),
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF294549)),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMealItem('เช้า', morningCount.toString(), morningImage),
                        _buildMealItem('กลางวัน', lunchCount.toString(), lunchImage),
                        _buildMealItem('เย็น', dinnerCount.toString(), dinnerImage),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const SearchMedicinePage(),
                                ),
                              );
                              _fetchDashboardData();
                            },
                            icon: const Icon(Icons.add,
                                color: Color(0xFF294549)),
                            label: const Text(
                              'เพิ่มรายการยา',
                              style: TextStyle(color: Color(0xFF294549)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF294549)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const HistoryTableListPage(),
                                ),
                              );
                              _fetchDashboardData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E7F90),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
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
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ],
                        ),
                        // ปุ่มไอคอนดินสอแก้ไขสถานะ
                        InkWell(
                          onTap: _toggleTakeMedicine,
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF294549),
                            child: Icon(Icons.edit,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // ปุ่มกินยาแล้ว / ยังไม่ได้กินยา
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleTakeMedicine,
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
                                  : const Color(0xFF4A807E),
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
                              side:
                              const BorderSide(color: Colors.black54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
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

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (int index) async {
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

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
          _fetchDashboardData();
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon:
            Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
            icon:
            Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon:
            Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon:
            Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications_none_outlined,
                color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.notifications_none_outlined,
                color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
          NavigationDestination(
            selectedIcon:
            Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
            icon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
            label: "",
          ),
        ],
      ),
    );
  }
}

Widget _buildMealItem(String title, String count, String? imageUrl) {
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
            child: imageUrl != null && imageUrl.trim().isNotEmpty
                ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_outlined,
                    size: 38,
                    color: Colors.black54,
                  );
                },
              ),
            )
                : const Icon(
              Icons.image_outlined,
              size: 38,
              color: Colors.black54,
            ),
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