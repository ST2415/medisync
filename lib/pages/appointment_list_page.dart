import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/services/api.dart';
import 'package:medisync/models/appointment_model.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  String dropdownAppointmentList = 'รายการทั้งหมด';
  var appointmentList = [
    'รายการทั้งหมด',
    'รายการที่ยืนยัน',
    'รายการที่เลื่อน',
    'รายการที่ผ่านมาแล้ว',
  ];

  List<Appointment> myAppointments = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // ดึงข้อมูลการนัดหมาย (คงการทำงานเดิมไว้ทั้งหมด)
  Future<void> _loadAppointments() async {
    try {
      final data = await ApiService.getAppointments(userId: 16)
          .timeout(const Duration(seconds: 10));

      final appointments = data.map((json) {
        final map = Map<String, dynamic>.from(json as Map);

        return Appointment(
          appid: map['appointment_id'].toString(),
          dateStr: _formatDate(
            map['appointment_date'].toString(),
          ),
          timeStr: _formatTime(
            map['appointment_time'].toString(),
          ),
          status: _formatStatus(
            map['status']?.toString() ?? 'รอยืนยัน',
          ),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        myAppointments = appointments;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      return '${date.day}/${date.month}/${date.year}';
    }

    return value;
  }

  String _formatTime(String value) {
    final parts = value.split(':');

    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:'
          '${parts[1].padLeft(2, '0')}';
    }

    return value;
  }

  String _formatStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
      case 'รอยืนยัน':
        return 'รอยืนยัน';

      case 'confirmed':
      case 'ยืนยัน':
      case 'ยืนยันแล้ว':
        return 'ยืนยันแล้ว';

      case 'rescheduled':
      case 'เลื่อน':
      case 'เลื่อนแล้ว':
        return 'เลื่อนแล้ว';

      default:
        return value;
    }
  }

  void _handleConfirmButton(String id) {
    setState(() {
      int targetIndex =
          myAppointments.indexWhere((element) => element.appid == id);

      if (targetIndex != -1) {
        myAppointments[targetIndex].status = 'ยืนยันแล้ว';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยืนยันรหัสนัดหมาย $id สำเร็จ'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleReappointment(Appointment item) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        const Duration(days: 1),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      helpText: 'เลือกวันนัดหมายใหม่',
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'เลือกเวลานัดหมายใหม่',
    );

    if (selectedTime == null || !mounted) return;

    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final time = TimeOfDay(
      hour: selectedTime.hour,
      minute: selectedTime.minute,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'ยืนยันการเลื่อนนัด',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF294549),
          ),
        ),
        content: Text(
          'วันที่ ${date.day}/${date.month}/${date.year}\n'
          'เวลา ${time.format(context)} น.',
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
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.reappointment(
        appointmentId: item.appid,
        appointmentDate:
            '${date.year}-${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}',
        appointmentTime:
            '${time.hour.toString().padLeft(2, '0')}:'
            '${time.minute.toString().padLeft(2, '0')}',
      );

      setState(() {
        final index = myAppointments.indexWhere(
          (appointment) => appointment.appid == item.appid,
        );

        if (index != -1) {
          myAppointments[index] = Appointment(
            appid: item.appid,
            dateStr: '${date.day}/${date.month}/${date.year}',
            timeStr:
                '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}',
            status: 'เลื่อนแล้ว',
          );
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เลื่อนวันนัดหมายสำเร็จ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เลื่อนวันนัดหมายไม่สำเร็จ: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: Column(
        children: [
          // Top Header Banner สไตล์เดียวกับ homepage_page.dart
          Container(
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF294549),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: Color(0xFF90C2B7),
                                size: 26,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'นัดหมายแพทย์',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'แจ้งเตือนรายการนัดหมายของคุณ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF90C2B7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dropdown ปุ่มเลือกสถานะ (ดีไซน์เข้ากัน)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E7F90),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownAppointmentList,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white),
                          dropdownColor: const Color(0xFF294549),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          items: appointmentList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue == null) return;

                            setState(() {
                              dropdownAppointmentList = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // รายการแสดงผลนัดหมาย
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF294549),
                    ),
                  );
                }

                if (errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ไม่สามารถโหลดรายการนัดหมายได้',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF294549),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              _loadAppointments();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF294549),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ลองอีกครั้ง',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final appointments = _getFilteredAppointments();

                if (appointments.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีรายการนัดหมาย',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar อันเดียวกับหน้า homepage_page.dart
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
                  MaterialPageRoute(
                      builder: (context) => const SearchMedicinePage()),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'ประวัติ',
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryTableListPage()),
                );
              },
            ),
            _buildNavItem(
              icon: Icons.notifications_rounded,
              label: 'นัดหมาย',
              isSelected: true,
              onTap: () {},
            ),
            // Floating menu button ด้านขวา
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF90C2B7),
                shape: BoxShape.circle,
              ),
              child: const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF294549),
                  size: 22,
                ),
                constraints: BoxConstraints(
                  minWidth: 42,
                  minHeight: 42,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    switch (dropdownAppointmentList) {
      case 'รายการที่ยืนยัน':
        return myAppointments
            .where((item) => item.status == 'ยืนยันแล้ว')
            .toList();

      case 'รายการที่เลื่อน':
        return myAppointments
            .where((item) => item.status == 'เลื่อนแล้ว')
            .toList();

      case 'รายการที่ผ่านมาแล้ว':
        final now = DateTime.now();

        return myAppointments.where((item) {
          final parts = item.dateStr.split('/');
          if (parts.length != 3) return false;

          final date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );

          return date.isBefore(
            DateTime(now.year, now.month, now.day),
          );
        }).toList();

      default:
        return myAppointments;
    }
  }

  Widget _buildAppointmentCard(Appointment item) {
    final isConfirmed = item.status == 'ยืนยันแล้ว';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFBBD7DA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    color: Color(0xFF294549),
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'นัดหมายแพทย์',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFF294549)
                      : const Color(0xFF4E7F90),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // รายละเอียดวันที่และเวลาในกรอบขาวนุ่มนวล
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x99FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF294549),
                ),
                const SizedBox(width: 8),
                Text(
                  item.dateStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF294549),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Color(0xFF294549),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.timeStr} น.',
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

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      isConfirmed ? null : () => _handleReappointment(item),
                  icon: const Icon(
                    Icons.event_repeat_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'เลื่อนวันนัดหมาย',
                    textAlign: TextAlign.center,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF294549),
                    disabledForegroundColor: Colors.black38,
                    backgroundColor: const Color(0x66FFFFFF),
                    side: const BorderSide(color: Color(0xFF294549), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isConfirmed
                      ? null
                      : () => _handleConfirmButton(item.appid),
                  icon: Icon(
                    isConfirmed
                        ? Icons.check_circle_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isConfirmed ? 'ยืนยันแล้ว' : 'ยืนยันวันนัดหมาย',
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF294549),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0x66294549),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
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
}
