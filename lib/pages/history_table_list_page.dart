import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';


class MedicineTrack {
  final String dayName;
  bool morning;
  bool afternoon;
  bool evening;
  bool beforeSleep;

  MedicineTrack({
    required this.dayName,
    this.morning = false,
    this.afternoon = false,
    this.evening = false,
    this.beforeSleep = false,
  });
}

class HistoryTableListPage extends StatefulWidget {
  const HistoryTableListPage({super.key});

  @override
  State<HistoryTableListPage> createState() => _HistoryTableListPageState();
}

class _HistoryTableListPageState extends State<HistoryTableListPage> {
  String dropdownTimeTrack = 'สัปดาห์นี้';
  var timeTrack = [
    'สัปดาห์นี้',
    'สัปดาห์ก่อนหน้านี้',
    'เดือนนี้',
    'เดือนก่อน',
  ];

  List<MedicineTrack> weeklyTracks = [
    MedicineTrack(dayName: 'จันทร์', morning: true),
    MedicineTrack(dayName: 'อังคาร'),
    MedicineTrack(dayName: 'พุธ', morning: true, afternoon: true, evening: true),
    MedicineTrack(dayName: 'พฤหัสบดี'),
    MedicineTrack(dayName: 'ศุกร์', morning: true, evening: true),
    MedicineTrack(dayName: 'เสาร์'),
    MedicineTrack(dayName: 'อาทิตย์'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ประวัติการกินยา"),
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
                      value: dropdownTimeTrack,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      isExpanded: true, //ั่งให้เนื้อหาและไอคอนลูกศรกางขยายเต็มพื้นที่ Container
                      dropdownColor: Color(0xFF4A807E),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      items: timeTrack.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownTimeTrack = newValue!;
                        });
                      },
                    ),
                  ),
                ),

            SizedBox(height: 16),

            Text(
              "18 ตค. ถึง 25 ตค. 2569",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
            ,),

            SizedBox(height: 16,),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFBBD7DA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFF4A807E)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(1.0),
                        2: FlexColumnWidth(1.0),
                        3: FlexColumnWidth(1.0),
                        4: FlexColumnWidth(1.0),
                      },
                      border: TableBorder.all(color: Color(0xFF4A807E), width: 2),
                      children: [
                        _buildHeaderRow(),
                        ...weeklyTracks.map((track) => _buildDataRow(track)),
                      ],
                    ),
                  ),
                ),

                _buildHistorySymptomCard(),
              ],
            ),

          ),
        ),

      //Bottom NavBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
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
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppointmentListPage()),
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
              selectedIcon: Icon(Icons.history, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.history, color: Color(0xFF90C2B7), size: 36),
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

  //สร้างตาราง
  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF4A807E)),
      children: [' ', 'เช้า', 'กลางวัน', 'เย็น', 'ก่อนนอน'].map((text) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildDataRow(MedicineTrack track) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(track.dayName, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        _buildCheckCell(track.morning, (val) => setState(() => track.morning = val)),
        _buildCheckCell(track.afternoon, (val) => setState(() => track.afternoon = val)),
        _buildCheckCell(track.evening, (val) => setState(() => track.evening = val)),
        _buildCheckCell(track.beforeSleep, (val) => setState(() => track.beforeSleep = val)),
      ],
    );
  }

  Widget _buildCheckCell(bool isTaken, Function(bool) onTap) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap(!isTaken);
        },
        child: SizedBox(
          height: 45,
          child: isTaken
              ? const Icon(Icons.check, color: Colors.black, size: 20) // แสดงติ๊กถูกถ้ากินแล้ว
              : const SizedBox(), // ปล่อยว่างถ้ายังไม่ได้กิน
        ),
      ),
    );
  }

  Widget _buildHistorySymptomCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF4A807E),
            borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                tilePadding: const EdgeInsets.symmetric(horizontal: 32.0),
                title: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: const Color(0xFF4A807E),
                  child: const Text(
                    "แสดงประวัติการบันทึกอาการหลังกินยา",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: const Color(0xFFBBD7DA),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "18/10-2569 ณ เวลา 18:10:12 น.",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                            "บันทึกอาการ: มึนหัว",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}