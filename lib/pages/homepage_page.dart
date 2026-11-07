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

  // 1. เพิ่มตัวแปรเก็บวันที่ที่เลือก (ค่าเริ่มต้นเป็นวันนี้)
  DateTime selectedDate = DateTime.now();

  // จำนวนยาแต่ละช่วงเวลา
  int morningCount = 0;
  int lunchCount = 0;
  int dinnerCount = 0;

  // URL รูปภาพของยาแต่ละช่วงเวลา
  String? morningImage;
  String? lunchImage;
  String? dinnerImage;

  // ข้อมูลยาช่วงเวลาดึงจากเซิร์ฟเวอร์
  String? currentScheduleId;
  String? currentLogId;
  String currentMedicineName = "ไม่มีรายการยา";
  String lunchMedicineName = "ไม่มีรายการยา";
  String dinnerMedicineName = "ไม่มีรายการยา";
  int currentDosage = 0;
  bool isTaken = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // คำนวณวันที่ทั้ง 7 วันของสัปดาห์ปัจจุบัน
  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _getDayShortName(int weekday) {
    const days = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัส', 'ศุกร์', 'เสาร์', 'อาทิตย์'];
    return days[weekday - 1];
  }

  // 2. ปรับให้แสดงวันที่ภาษาไทยตาม selectedDate ที่เลือก
  String _getFormattedDate(DateTime date) {
    const days = [
      'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี',
      'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์'
    ];
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final dayName = days[date.weekday - 1];
    final dayNum = date.day;
    final monthName = months[date.month - 1];
    final buddhistYear = date.year + 543;

    return '$dayNameที่ $dayNum $monthName $buddhistYear';
  }

  // 3. ฟังก์ชันดึงข้อมูลแดชบอร์ดตามวันที่เลือก
  Future<void> _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    const int targetUserId = 16;

    try {
      final data = await _homeService.fetchDashboardData(targetUserId);
      final List<dynamic> schedules =
      await _homeService.fetchTodaySchedules(targetUserId);

      if (mounted) {
        int mCount = 0;
        int lCount = 0;
        int dCount = 0;
        String? mImg;
        String? lImg;
        String? dImg;
        String firstMorningMed = "ไม่มีรายการยา";
        String firstLunchMed = "ไม่มีรายการยา";
        String firstDinnerMed = "ไม่มีรายการยา";
        int firstMorningDosage = 0;
        String? firstMorningScheduleId;
        String? firstMorningLogId;
        bool firstMorningTaken = false;

        for (var item in schedules) {
          final String timeToTake = (item['time_to_take'] ??
              item['time'] ??
              item['meal_time'] ??
              '')
              .toString();

          String? rawImg =
              item['image_url'] ?? item['image'] ?? item['picture'];
          if (rawImg != null &&
              rawImg.isNotEmpty &&
              !rawImg.startsWith('http')) {
            rawImg =
            '${HomeService.baseUrl}${(rawImg.startsWith('/') ? '' : '/')}$rawImg';
          }

          final int dosage = int.tryParse(
              (item['dosage_amount'] ?? item['dosage'] ?? 1).toString()) ??
              1;

          final String medName = (item['trade_name'] ??
              item['medicine_name'] ??
              item['name'] ??
              (item['tpu_code'] != null
                  ? 'รหัสยา TPU: ${item['tpu_code']}'
                  : 'ไม่ระบุชื่อยา'))
              .toString();

          if (timeToTake.contains('เช้า')) {
            mCount += dosage;
            mImg ??= rawImg;

            if (firstMorningMed == "ไม่มีรายการยา") {
              firstMorningScheduleId = item['schedule_id']?.toString();
              firstMorningLogId =
                  item['log_id']?.toString() ?? item['logId']?.toString();
              firstMorningMed = medName;
              firstMorningDosage = dosage;
              firstMorningTaken = item['is_taken'] == true ||
                  item['is_taken'] == 1 ||
                  item['status'] == 'taken' ||
                  item['status'] == 'ทานแล้ว' ||
                  item['status'] == 1;
            }
          } else if (timeToTake.contains('กลางวัน')) {
            lCount += dosage;
            lImg ??= rawImg;
            if (firstLunchMed == "ไม่มีรายการยา") {
              firstLunchMed = medName;
            }
          } else if (timeToTake.contains('เย็น')) {
            dCount += dosage;
            dImg ??= rawImg;
            if (firstDinnerMed == "ไม่มีรายการยา") {
              firstDinnerMed = medName;
            }
          }
        }

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
          lunchMedicineName = firstLunchMed;
          dinnerMedicineName = firstDinnerMed;
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

  Future<void> _toggleTakeMedicine() async {
    if (!isTaken) {
      try {
        final newLogId = await _homeService.addMedicationLog(
          userId: 16,
          scheduleId: currentScheduleId ?? '',
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
              content: Text('"กินยาแล้ว" เรียบร้อยแล้ว'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกไม่สำเร็จ: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFF294549)),
            SizedBox(width: 8),
            Text(
              'ยกเลิกรายการกินยา',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF294549),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'ต้องการเปลี่ยนสถานะเป็น "ยังไม่ได้กินยา" ใช่หรือไม่?',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF294549),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          content: Text('เปลี่ยนสถานะเป็น "ยังไม่ได้กินยา" เรียบร้อยแล้ว'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ยกเลิกรายการไม่สำเร็จ: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSymptomDialog() {
    final symptomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Color(0xFF294549), size: 26),
              SizedBox(width: 8),
              Text(
                'บันทึกอาการ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF294549),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: symptomController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'กรอกรายละเอียดอาการ เช่น ปวดหัว, คลื่นไส้...',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              filled: true,
              fillColor: const Color(0x4DBBD7DA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(0xFF294549), width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294549),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final inputSymptom = symptomController.text;
                if (inputSymptom.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('บันทึกอาการเรียบร้อยแล้ว'),
                      behavior: SnackBarBehavior.floating,
                    ),
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
    final weekDates = _getCurrentWeekDates();
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF294549),
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFF294549),
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วน Header และ Calendar Bar
              Container(
                padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF294549),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF90C2B7), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF4E7F90),
                            child: Icon(
                              Icons.person_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'สวัสดี !',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'คุณ$userName',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF90C2B7),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // แสดงวันที่ตามตัวแปร selectedDate
                              Text(
                                _getFormattedDate(selectedDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4. แถบปฏิทิน 7 วัน ที่สามารถแตะเลือกวันได้
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDates.map((date) {
                        // เช็กว่าเป็นวันที่กำลังเลือกอยู่หรือไม่
                        final isSelected = date.day == selectedDate.day &&
                            date.month == selectedDate.month &&
                            date.year == selectedDate.year;

                        return MouseRegion(
                            cursor: SystemMouseCursors.click, // เปลี่ยนเคอร์เซอร์เป็นรูปมือชี้เมื่อ Hover
                            child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date; // อัปเดตวันที่เลือก
                            });
                            _fetchDashboardData(); // รีเฟรชข้อมูลตามวันที่
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            children: [
                              Text(
                                _getDayShortName(date.weekday),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? const Color(0xFF90C2B7)
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF90C2B7)
                                      : Colors.black26,
                                  border: isSelected
                                      ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF294549)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // รายการยาประจำวัน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medication_liquid_rounded,
                              color: Color(0xFF294549),
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedDate.day == DateTime.now().day &&
                                  selectedDate.month == DateTime.now().month &&
                                  selectedDate.year == DateTime.now().year
                                  ? 'ยาที่ต้องกินวันนี้'
                                  : 'ยาที่ต้องกิน (วัน${_getDayShortName(selectedDate.weekday)}ที่ ${selectedDate.day})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF294549),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _showSymptomDialog,
                          icon: const Icon(
                            Icons.edit_note_rounded,
                            color: Color(0xFF294549),
                          ),
                          tooltip: 'บันทึกอาการ',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBD7DA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // 1. ช่วงเวลาตอนเช้า
                          _buildMealSection(
                            title: 'ตอนเช้า',
                            defaultTime: '08:00 น.',
                            medicineName: currentMedicineName,
                            dosageCount: morningCount > 0 ? morningCount : currentDosage,
                            imageUrl: morningImage,
                            isDone: isTaken,
                            onTapToggle: _toggleTakeMedicine,
                          ),

                          const SizedBox(height: 14),

                          // 2. ช่วงเวลาตอนกลางวัน
                          _buildMealSection(
                            title: 'ตอนกลางวัน',
                            defaultTime: '12:00 น.',
                            medicineName: lunchMedicineName,
                            dosageCount: lunchCount,
                            imageUrl: lunchImage,
                            isDone: lunchCount > 0 && isTaken,
                            onTapToggle: () {},
                          ),

                          const SizedBox(height: 14),

                          // 3. ช่วงเวลาตอนเย็น
                          _buildMealSection(
                            title: 'ตอนเย็น',
                            defaultTime: '18:00 น.',
                            medicineName: dinnerMedicineName,
                            dosageCount: dinnerCount,
                            imageUrl: dinnerImage,
                            isDone: dinnerCount > 0 && isTaken,
                            onTapToggle: () {},
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF294549),
                              size: 20,
                            ),
                            label: const Text(
                              'เพิ่มรายการยา',
                              style: TextStyle(
                                color: Color(0xFF294549),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xFF294549), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
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
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'ดูตารางยาทั้งหมด',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF294549),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF294549),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'หน้าแรก',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.medication_rounded,
              label: 'ยา',
              isSelected: false,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchMedicinePage(),
                  ),
                );
                _fetchDashboardData();
              },
            ),
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'ประวัติ',
              isSelected: false,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryTableListPage(),
                  ),
                );
                _fetchDashboardData();
              },
            ),
            _buildNavItem(
              icon: Icons.notifications_rounded,
              label: 'นัดหมาย',
              isSelected: false,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentListPage(),
                  ),
                );
                _fetchDashboardData();
              },
            ),
            // ไอคอนผู้ใช้ (User) ท้าย Navbar - ไม่มีพื้นหลัง และกดไม่ได้
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Icon(
                Icons.person_rounded, // หรือ Icons.person_outline_rounded
                color: Colors.white60, // สีขาวจางๆ สไตล์เดียวกับแท็บอื่นที่ไม่ได้เลือก
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimeRow({
    required String mealName,
    required String timeStr,
    required String medicineName,
    required int dosageCount,
    required String? imageUrl,
    required bool isDone,
    required VoidCallback onTapToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF294549),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl.trim().isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF90C2B7),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.medication_rounded,
                  color: Color(0xFF90C2B7),
                  size: 26,
                );
              },
            )
                : const Icon(
              Icons.medication_rounded,
              color: Color(0xFF90C2B7),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$timeStr • $mealName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E7F90),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medicineName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF294549),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dosageCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'รับประทาน $dosageCount เม็ด',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTapToggle,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: isDone
                    ? const Color(0xFF294549)
                    : Colors.black38,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: const Color(0xFF4E7F90),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF90C2B7) : Colors.white60,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection({
    required String title,
    required String defaultTime,
    required String medicineName,
    required int dosageCount,
    required String? imageUrl,
    required bool isDone,
    required VoidCallback onTapToggle,
  }) {
    final bool hasMedicine = medicineName.trim().isNotEmpty && medicineName != "ไม่มีรายการยา";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // หัวข้อช่วงเวลา (เช้า / กลางวัน / เย็น)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF4E7F90),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title ($defaultTime)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF294549),
                ),
              ),
            ],
          ),
        ),

        // กล่องแสดงผล: ถ้ามียา แสดงการ์ดยา | ถ้าไม่มียา แสดงข้อความว่าไม่มีรายการยา
        hasMedicine
            ? Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // เพิ่มเส้นขอบสีเขียวเข้มบางๆ เมื่อกินยาแล้ว (หรือเส้นขอบขาวนุ่มๆ)
            border: Border.all(
              color: isDone ? const Color(0xFF90C2B7) : Colors.white,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000), // เพิ่มเงาให้นุ่มและมีมิติลอยตัวขึ้น
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // รูปภาพยา (ใช้พื้นหลังสีเขียวเข้มเดิม ตัดกับสีขาวได้สวยมาก)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF294549),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.trim().isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.medication_rounded,
                    color: Color(0xFF90C2B7),
                    size: 28,
                  ),
                )
                    : const Icon(
                  Icons.medication_rounded,
                  color: Color(0xFF90C2B7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // รายละเอียดตัวยา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF294549),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'รับประทาน $dosageCount เม็ด (หลังอาหาร)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4E7F90),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ปุ่มสถานะติ๊กถูก
              InkWell(
                onTap: onTapToggle,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    color: isDone ? const Color(0xFF294549) : Colors.black38,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        )
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12, width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF294549)),
              SizedBox(width: 10),
              Text(
                'ไม่มีรายการยา',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF294549),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}