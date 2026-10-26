import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';

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

  List<Appointment> myAppointments = [
    Appointment(appid: '01', dateStr: '10/11/2026', timeStr: '09:00', status: 'รอยืนยัน'),
    Appointment(appid: '02', dateStr: '17/11/2026', timeStr: '14:30', status: 'รอยืนยัน'),
    Appointment(appid: '03', dateStr: '24/11/2026', timeStr: '11:00', status: 'ยืนยันแล้ว'),
  ];

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
                      : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ระบบจำลองการเลื่อนวันนัดหมาย',
                        ),
                      ),
                    );
                  },
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
