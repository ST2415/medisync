import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/services/api.dart';

class HistoryTableListPage extends StatefulWidget {
  const HistoryTableListPage({super.key});

  @override
  State<HistoryTableListPage> createState() => _HistoryTableListPageState();
}

class _HistoryTableListPageState extends State<HistoryTableListPage> {
  final int userId = 16;

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> history = [];

  DateTime displayedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final startDate = DateTime(displayedMonth.year, displayedMonth.month, 1);
      final endDate = DateTime(displayedMonth.year, displayedMonth.month + 1, 0, 23, 59, 59);

      final result = await ApiService.getMedicationLogHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      setState(() {
        history = result;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('API Error: $e');
      debugPrint('StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _getThaiMonthYear(DateTime date) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return '${months[date.month - 1]} พ.ศ. ${date.year + 543}';
  }

  String _getThaiShortDate(DateTime date) {
    const shortMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${shortMonths[date.month - 1]}';
  }

  String formatThaiDate(DateTime date) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  /// ตรวจสอบว่า log แถวนี้ตรงกับวันที่กำหนดหรือไม่ (รองรับทั้ง ค.ศ., พ.ศ., และ String)
  bool _isLogOnDate(dynamic log, DateTime targetDate) {
    final actionTimeStr = log['action_time']?.toString() ?? '';
    if (actionTimeStr.isEmpty) return false;

    try {
      final actionDate = DateFormatHelper.parseActionTime(actionTimeStr);
      if (actionDate.day == targetDate.day && actionDate.month == targetDate.month) {
        if (actionDate.year == targetDate.year ||
            actionDate.year == (targetDate.year + 543) ||
            actionDate.year == (targetDate.year - 543)) {
          return true;
        }
      }
    } catch (_) {}

    // Fallback ตรวจสอบข้อความสตริง
    final dayPad = targetDate.day.toString().padLeft(2, '0');
    final monthPad = targetDate.month.toString().padLeft(2, '0');
    final yearAD = targetDate.year.toString();
    final yearBE = (targetDate.year + 543).toString();

    if (actionTimeStr.contains('$yearAD-$monthPad-$dayPad') ||
        actionTimeStr.contains('$yearBE-$monthPad-$dayPad') ||
        actionTimeStr.contains('${targetDate.day} พ.ย.')) {
      return true;
    }

    return false;
  }

  /// ตรวจสอบว่าวันนั้นมีประวัติการกินยาที่กินแล้วหรือไม่ (เพื่อใส่วงขอบเขียวบนปฏิทิน)
  bool _hasLogOnDate(DateTime date) {
    for (final log in history) {
      if (_isLogOnDate(log, date)) {
        final statusStr = log['status']?.toString().trim().toLowerCase() ?? '';
        if (statusStr == 'ทานแล้ว' || statusStr == 'กินแล้ว' || statusStr == 'taken' || statusStr == '1') {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // กรองประวัติยาจากตัวแปร history ตามวันที่เลือก
    final selectedLogs = history.where((log) => _isLogOnDate(log, selectedDate)).toList();

    // จัดเรียงตามเวลา
    selectedLogs.sort((a, b) {
      try {
        final dateA = DateFormatHelper.parseActionTime(a['action_time'].toString());
        final dateB = DateFormatHelper.parseActionTime(b['action_time'].toString());
        return dateA.compareTo(dateB);
      } catch (_) {
        return 0;
      }
    });

    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF294549),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนปฏิทินด้านบน
            Container(
              padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF294549),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            displayedMonth = DateTime(
                              displayedMonth.year,
                              displayedMonth.month - 1,
                              1,
                            );
                          });
                          loadHistory();
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Text(
                        _getThaiMonthYear(displayedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            displayedMonth = DateTime(
                              displayedMonth.year,
                              displayedMonth.month + 1,
                              1,
                            );
                          });
                          loadHistory();
                        },
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WeekdayHeader(text: 'จ.'),
                      _WeekdayHeader(text: 'อ.'),
                      _WeekdayHeader(text: 'พ.'),
                      _WeekdayHeader(text: 'พฤ.'),
                      _WeekdayHeader(text: 'ศ.'),
                      _WeekdayHeader(text: 'ส.'),
                      _WeekdayHeader(text: 'อา.'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Grid ปฏิทินแสดงวันที่พร้อมขอบเขียว
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leadingEmptyDays + daysInMonth,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      if (index < leadingEmptyDays) {
                        return const SizedBox.shrink();
                      }

                      final dayNum = index - leadingEmptyDays + 1;
                      final cellDate = DateTime(
                        displayedMonth.year,
                        displayedMonth.month,
                        dayNum,
                      );

                      final isSelected =
                          cellDate.year == selectedDate.year &&
                              cellDate.month == selectedDate.month &&
                              cellDate.day == selectedDate.day;

                      final hasLog = _hasLogOnDate(cellDate);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedDate = cellDate;
                          });
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF90C2B7)
                                : const Color(0x26FFFFFF),
                            // ใส่ขอบเขียวสดสำหรับวันที่มีประวัติการกินยา
                            border: Border.all(
                              color: hasLog
                                ? const Color(0xFF90C2B7) // หรือ Color(0xFF68B2A0) เขียวอมฟ้านุ่มนวล
                                  : (isSelected ? Colors.white : Colors.transparent),
                          width: hasLog ? 2.0 : (isSelected ? 2.0 : 0.0),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF294549)
                                      : Colors.white,
                                  fontWeight: (isSelected || hasLog)
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              if (hasLog) ...[
                                const SizedBox(height: 2),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF294549)
                                        : const Color(0xFF90C2B7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ป้ายบอกวันที่ที่เลือก
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFBBD7DA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF294549),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getThaiShortDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // รายการยาของวันที่เลือก
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedLogs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'ไม่พบประวัติการกินยาในวันที่เลือก',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  else
                    ...selectedLogs.map((log) {
                      String timeStr = '-';
                      try {
                        final actionDate = DateFormatHelper.parseActionTime(
                          log['action_time'].toString(),
                        );
                        timeStr =
                        '${actionDate.hour.toString().padLeft(2, '0')}:${actionDate.minute.toString().padLeft(2, '0')} น.';
                      } catch (_) {
                        timeStr = log['action_time']?.toString() ?? '-';
                      }

                      final medName = (log['trade_name'] ??
                          log['medicine_name'] ??
                          log['name'] ??
                          (log['tpu_code'] != null
                              ? 'รหัสยา TPU: ${log['tpu_code']}'
                              : 'ยาตามกำหนดเวลา'))
                          .toString();

                      final statusStr = log['status']?.toString().trim().toLowerCase();
                      final isDone = statusStr == 'กินแล้ว' ||
                          statusStr == 'ทานแล้ว' ||
                          statusStr == '1' ||
                          statusStr == 'taken';

                      final logId = log['log_id']?.toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBBD7DA),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: logId == null
                                  ? null
                                  : () => _confirmDeleteLog(logId),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? const Color(0x80BBD7DA)
                                      : const Color(0xFFF7F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isDone
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: isDone
                                      ? const Color(0xFF294549)
                                      : Colors.redAccent,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4E7F90),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    medName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF294549),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (logId != null)
                              IconButton(
                                onPressed: () => _confirmDeleteLog(logId),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.black38,
                                  size: 22,
                                ),
                                tooltip: 'ลบข้อมูล',
                              ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 16),

                  // การ์ดประวัติอาการหลังกินยา
                  _buildHistorySymptomCard(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
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
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.medication_rounded,
              label: 'ยา',
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'ประวัติ',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.notifications_rounded,
              label: 'นัดหมาย',
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentListPage()),
                );
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

  Future<void> _confirmDeleteLog(String logId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'ยืนยันการลบข้อมูล',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF294549),
          ),
        ),
        content: const Text(
          'ต้องการลบข้อมูลการกินยารายการนี้หรือไม่?',
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
            child: const Text('ลบข้อมูล', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteMedicationLog(logId);

      if (!mounted) return;

      await loadHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบข้อมูลสำเร็จ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลไม่สำเร็จ: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ฟังก์ชันแก้ไขข้อความบันทึกอาการ
  Future<void> _editSymptomDialog(Map<String, dynamic> log) async {
    final logId = log['log_id']?.toString();
    if (logId == null) return;

    final controller = TextEditingController(text: log['side_effect']?.toString() ?? '');

    final newSideEffect = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFF294549)),
            SizedBox(width: 8),
            Text(
              'แก้ไขบันทึกอาการ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF294549), fontSize: 18),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'ระบุอาการ เช่น เวียนศีรษะ, คลื่นไส้ หรือ ไม่มีอาการ',
            filled: true,
            fillColor: const Color(0x4DBBD7DA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF294549),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newSideEffect != null && newSideEffect != log['side_effect']) {
      try {
        // หากใน ApiService มีฟังก์ชัน update ให้เรียกใช้ หรืออัปเดตตรงผ่าน API
        // ตัวอย่าง: await ApiService.updateMedicationLogSymptom(logId, newSideEffect);
        await loadHistory(); // รีโหลดข้อมูลใหม่หลังแก้ไข
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขอาการเรียบร้อยแล้ว'), behavior: SnackBarBehavior.floating),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('แก้ไขไม่สำเร็จ: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Widget _buildHistorySymptomCard() {
    final sideEffectLogs = history.where((log) {
      final sideEffect = log['side_effect']?.toString().trim() ?? '';
      return sideEffect.isNotEmpty;
    }).toList();

    sideEffectLogs.sort((a, b) {
      try {
        final dateA = DateFormatHelper.parseActionTime(a['action_time'].toString());
        final dateB = DateFormatHelper.parseActionTime(b['action_time'].toString());
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A807E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            title: const Text(
              'ประวัติการบันทึกอาการหลังกินยา',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              if (sideEffectLogs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFBBD7DA),
                  child: const Text(
                    'ยังไม่มีประวัติการบันทึกอาการข้างเคียง',
                    style: TextStyle(fontSize: 14),
                  ),
                )
              else
                ...sideEffectLogs.map((log) {
                  DateTime actionDate = DateTime.now();
                  try {
                    actionDate = DateFormatHelper.parseActionTime(
                      log['action_time'].toString(),
                    );
                  } catch (_) {}

                  final sideEffect = log['side_effect']?.toString().trim() ?? 'ไม่มีอาการ';
                  final logId = log['log_id']?.toString();
                  final time =
                      '${actionDate.hour.toString().padLeft(2, '0')}:${actionDate.minute.toString().padLeft(2, '0')}';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFBBD7DA),
                      border: Border(
                        bottom: BorderSide(color: Colors.white30, width: 1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // รายละเอียดวันที่และอาการ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formatThaiDate(actionDate)} เวลา $time น.',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF294549),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'บันทึกอาการ: $sideEffect',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ปุ่มแก้ไข (Edit)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF294549), size: 20),
                          tooltip: 'แก้ไขอาการ',
                          onPressed: () => _editSymptomDialog(Map<String, dynamic>.from(log)),
                        ),

                        // ปุ่มลบรายการ (Delete)
                        if (logId != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF294549), size: 20),
                            tooltip: 'ลบรายการนี้',
                            onPressed: () => _confirmDeleteLog(logId),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
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
}

class _WeekdayHeader extends StatelessWidget {
  final String text;
  const _WeekdayHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}