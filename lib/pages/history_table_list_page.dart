import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/services/api.dart';

class MedicineTrack {
  final String dayName;
  int morning;
  int afternoon;
  int evening;
  int beforeSleep;

  MedicineTrack({
    required this.dayName,
    this.morning = 0,
    this.afternoon = 0,
    this.evening = 0,
    this.beforeSleep = 0,
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

  String formatThaiDate(DateTime date) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  List<MedicineTrack> buildTracksFromHistory(
      DateTimeRange range,
      ) {
    const weekdays = [
      'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี',
      'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์',
    ];

    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];

    final tracks = <MedicineTrack>[];

    for (
    var day = range.start;
    !day.isAfter(range.end);
    day = day.add(const Duration(days: 1))
    ) {
      tracks.add(
        MedicineTrack(
          dayName: '${weekdays[day.weekday - 1]}ที่ ${day.day} ${months[day.month - 1]}',
        ),
      );
    }

    for (final log in history) {
      debugPrint('status จาก API: ${log['status']}');
      try {
        final actionDate = DateFormatHelper.parseActionTime(
          log['action_time'].toString(),
        );

        if (actionDate.isBefore(range.start) ||
            actionDate.isAfter(
              range.end.add(const Duration(days: 1)),
            )) {
          continue;
        }

        final dayIndex = actionDate.difference(
          range.start,
        ).inDays;

        if (dayIndex < 0 || dayIndex >= tracks.length) {
          continue;
        }

        // จัดกลุ่มตามช่วงเวลาจาก action_time
        final hour = actionDate.hour;

        final statusText = log['status'].toString().trim();
        final int status;
        if (statusText == 'ยังไม่ได้กิน') {
          // ยังไม่ได้กินยา
          status = 2;
        } else if (statusText == 'กินแล้ว') {
          // กินยาแล้ว
          status = 1;
        } else {
          continue;
        }

        final track = tracks[dayIndex];

        if (hour >= 5 && hour < 12) {
          track.morning = status;
        } else if (hour >= 12 && hour < 17) {
          track.afternoon = status;
        } else if (hour >= 17 && hour < 21) {
          track.evening = status;
        } else {
          track.beforeSleep = status;
        }
      } catch (_) {
        // ข้ามรายการที่ action_time ไม่ตรงรูปแบบที่รองรับ
        continue;
      }
    }

    return tracks;
  }

  final int userId = 16;

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> history = [];

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
      final range = getDateRange();
      debugPrint('กำลังเรียก API: /schedules');

      final result = await ApiService.getMedicationLogHistory(
        userId: userId,
        startDate: range.start,
        endDate: range.end,
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

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monday = today.subtract(
      Duration(days: today.weekday - 1),
    );

    switch (dropdownTimeTrack) {
      case 'สัปดาห์นี้':
        return DateTimeRange(
          start: monday,
          end: monday.add(const Duration(days: 6)),
        );

      case 'สัปดาห์ก่อนหน้านี้':
        final start = monday.subtract(
          const Duration(days: 7),
        );

        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 6)),
        );

      case 'เดือนนี้':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );

      case 'เดือนก่อน':
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );

      default:
        return DateTimeRange(
          start: monday,
          end: monday.add(const Duration(days: 6)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            //กำหนด Margin ครอบทั้งหน้าจอ (ซ้าย-ขวา 32.0)
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'ประวัติการกินยา',
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

                        loadHistory();
                      },
                    ),
                  ),
                ),

            SizedBox(height: 16),

          Builder(
            builder: (context) {
              final range = getDateRange();
              final tracks = buildTracksFromHistory(range);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatThaiDate(range.start)} ถึง '
                        '${formatThaiDate(range.end)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (errorMessage != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('โหลดประวัติไม่สำเร็จ'),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: loadHistory,
                          child: const Text('ลองอีกครั้ง'),
                        ),
                      ],
                    )
                  else if (history.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('ไม่พบประวัติในช่วงวันที่เลือก'),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBD7DA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4A807E),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: double.infinity,
                            child: Table(
                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                              columnWidths: const {
                                0: FlexColumnWidth(1.5),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                                4: FlexColumnWidth(1),
                              },
                              border: TableBorder.all(
                                color: const Color(0xFF4A807E),
                                width: 1,
                              ),
                              children: [
                                _buildHeaderRow(),
                                ...tracks.map(_buildDataRow),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
            padding: const EdgeInsets.all(10),
            child: Text(
              track.dayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        _buildCheckCell(track.morning),
        _buildCheckCell(track.afternoon),
        _buildCheckCell(track.evening),
        _buildCheckCell(track.beforeSleep),
      ],
    );
  }

  Widget _buildCheckCell(int status) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: 50,
        child: Center(
          child: switch (status) {
            1 => const Icon(
              Icons.check,
              color: Colors.black,
              size: 24,
            ),
            2 => const Icon(
              Icons.close,
              color: Colors.black,
              size: 24
            ),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }

  Widget _buildHistorySymptomCard() {
    // เลือกเฉพาะรายการที่มีข้อมูล side_effect
    final sideEffectLogs = history.where((log) {
      final sideEffect = log['side_effect']?.toString().trim() ?? '';
      return sideEffect.isNotEmpty;
    }).toList();

    // เรียงจากรายการล่าสุดไปเก่าสุด
    sideEffectLogs.sort((a, b) {
      final dateA = DateFormatHelper.parseActionTime(
        a['action_time'].toString(),
      );
      final dateB = DateFormatHelper.parseActionTime(
        b['action_time'].toString(),
      );
      return dateB.compareTo(dateA);
    });

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
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              title: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'แสดงประวัติการบันทึกอาการหลังกินยา',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  ...sideEffectLogs.map((log) {
                    final actionDate =
                    DateFormatHelper.parseActionTime(
                      log['action_time'].toString(),
                    );

                    final sideEffect =
                    log['side_effect'].toString().trim();

                    final time =
                        '${actionDate.hour.toString().padLeft(2, '0')}:'
                        '${actionDate.minute.toString().padLeft(2, '0')}';

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFBBD7DA),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatThaiDate(actionDate)} '
                                'เวลา $time น.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'บันทึกอาการ: $sideEffect',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}