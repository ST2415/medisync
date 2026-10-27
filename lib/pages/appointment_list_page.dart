import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/services/api.dart';

class Appointment {
  final String appid;
  final String dateStr;
  final String timeStr;
  String status; // เช่น 'รอยืนยัน', 'ยืนยันแล้ว'

  Appointment({
    required this.appid,
    required this.dateStr,
    required this.timeStr,
    required this.status,
  });
}

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

  Future<void> _loadAppointments() async {
    print('1. เริ่มเรียก API');

    try {
      final data = await ApiService.getAppointments(userId: 16,)
          .timeout(const Duration(seconds: 10));

      print('2. API ตอบกลับแล้ว');
      print('3. จำนวนรายการ: ${data.length}');

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

      print('4. แปลงข้อมูลเสร็จแล้ว');

      if (!mounted) return;

      setState(() {
        myAppointments = appointments;
        errorMessage = null;
      });

      print('5. อัปเดตหน้าจอแล้ว');
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');

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
    switch (value.toLowerCase()) {
      case 'pending':
        return 'รอยืนยัน';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'rescheduled':
        return 'เลื่อนแล้ว';
      default:
        return value;
    }
  }

  // 3. Logic การทำงานเมื่อกดปุ่มยืนยันนัดหมาย (เปลี่ยนข้อมูลเฉพาะบนหน้าจอเครื่อง)
  void _handleConfirmButton(String id) {
    setState(() {
      // ค้นหาตำแหน่งการ์ดใบที่ถูกกดใน List ผ่านค่า id
      int targetIndex = myAppointments.indexWhere((element) => element.appid == id);

      if (targetIndex != -1) {
        // อัปเดตสถานะของข้อมูลใบนั้นให้เปลี่ยนเป็น ยืนยันแล้ว
        myAppointments[targetIndex].status = 'ยืนยันแล้ว';
      }
    });

    // แสดงแถบป๊อปอัปแจ้งเตือนสั้นๆ ด้านล่างจอ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยืนยันรหัสนัดหมาย $id สำเร็จ (Local State)'),
        duration: const Duration(seconds: 1),
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
        title: const Text('ยืนยันการเลื่อนนัด'),
        content: Text(
          'วันที่ ${date.day}/${date.month}/${date.year}\n'
              'เวลา ${time.format(context)} น.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('ยืนยัน'),
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
            dateStr:
            '${date.day}/${date.month}/${date.year}',
            timeStr:
            '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}',
            status: 'เลื่อนแล้ว',
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เลื่อนวันนัดหมายสำเร็จ'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เลื่อนวันนัดหมายไม่สำเร็จ: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'แจ้งเตือนนัดหมายแพทย์',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // ปุ่ม Dropdown เลือกสัปดาห์
                Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A807E),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownAppointmentList,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    isExpanded: true, //สั่งให้เนื้อหาและไอคอนลูกศรกางขยายเต็มพื้นที่ Container
                    dropdownColor: Color(0xFF4A807E),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    items: appointmentList.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
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

              const SizedBox(height: 16),

              Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'ไม่สามารถโหลดรายการนัดหมายได้',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
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
                            child: const Text('ลองอีกครั้ง'),
                          ),
                        ],
                      ),
                    );
                  }

                  final appointments = _getFilteredAppointments();

                  if (appointments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text('ไม่มีรายการนัดหมาย'),
                      ),
                    );
                  }

                  return Column(
                    children: appointments.map((appointment) {
                      return _buildAppointmentCard(appointment);
                    }).toList(),
                  );
                },
              ),
              ],

            ),


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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBBD7DA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'นัดหมายครั้งถัดไป',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'วันที่ ${item.dateStr} ณ เวลา ${item.timeStr} น.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),

          Text(
            'สถานะ: ${item.status}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isConfirmed
                      ? null
                      : () => _handleReappointment(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0x75294549), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'เลื่อนวันนัดหมาย',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: isConfirmed
                      ? null
                      : () => _handleConfirmButton(item.appid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF294549),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0x75294549),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isConfirmed ? 'ยืนยันแล้ว' : 'ยืนยันวันนัดหมาย',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
