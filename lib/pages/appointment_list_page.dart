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
      appBar: AppBar(
        title: Text("แจ้งเตือนนัดหมายแพทย์"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          //กำหนด Margin ครอบทั้งหน้าจอ (ซ้าย-ขวา 32.0)
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ปุ่ม Dropdown เลือกสัปดาห์
              Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                    setState(() {
                      dropdownAppointmentList = newValue!;
                    });
                  },
                ),
              ),
            ),

              // ListView.builder(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   itemCount: myAppointments.length,
              //   itemBuilder: (context, index) {
              //     return _buildWaitingAppointmentCard(myAppointments[index]);
              //   },
              // ),
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

  // Widget _buildWaitingAppointmentCard(Appointment item) {
  //   bool isAlreadyConfirmed = item.status == 'ยืนยันแล้ว';
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     padding: const EdgeInsets.all(16.0),
  //     decoration: BoxDecoration(
  //       color: const Color(0xffb0b0b0), // สีพื้นหลังเทาอ่อนตามรูป
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           "นัดหมายครั้งถัดไป",
  //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
  //         ),
  //         SizedBox(height: 8.0),
  //         Text(
  //           "วันที่ 10/11/2026 ณ เวลา 09:00 น.",
  //           style: const TextStyle(fontSize: 16, color: Colors.black),
  //         ),
  //         SizedBox(height: 8.0),
  //         Text(
  //           "สถานะ: รอยืนยัน",
  //           style: const TextStyle(fontSize: 16, color: Colors.black),
  //         ),
  //
  //         SizedBox(height: 16.0),
  //
  //         Row(
  //           children: [
  //             Expanded(
  //                 child: OutlinedButton(
  //                   onPressed: isAlreadyConfirmed ? null : () {
  //                     // Logic จำลองการกดเลื่อนนัด
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('ระบบจำลองการเลื่อนวันนัดหมายทำงาน')),);},
  //                   style: OutlinedButton.styleFrom(
  //                     side: const BorderSide(color: Colors.black54),
  //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //                     padding: const EdgeInsets.symmetric(vertical: 12.0),
  //                   ),
  //                   child: const Text("เลื่อนวันนัดหมาย", style: TextStyle(color: Colors.black)),
  //                   //child: const Text("เลื่อนวันนัดหมาย", style: TextStyle(color: Colors.black)),
  //                 ),
  //             ),
  //             const SizedBox(width: 12.0),
  //
  //             Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: isAlreadyConfirmed ? null : () => _handleConfirmButton(item.appid),
  //                   style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xff404040), // สีปุ่มเข้มตามรูป
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //                   padding: const EdgeInsets.symmetric(vertical: 12.0),
  //                 ),
  //                 child: Text(
  //                     isAlreadyConfirmed ? "ยืนยันแล้ว" : "ยืนยันวันนัดหมาย",
  //                     style: const TextStyle(color: Colors.white)
  //                 ),
  //             ),
  //           ),
  //         ],
  //     ),
  //   ],
  //   )
  //   );
  // }
}
