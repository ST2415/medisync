import 'package:flutter/material.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'สวัสดี !',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF294549),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'คุณแอปเปิล',
                          style: TextStyle(
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
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF294549)),
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
                          _buildMealItem('เช้า', '1'),
                          _buildMealItem('กลางวัน', '1'),
                          _buildMealItem('เย็น', '1'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, color: Color(0xFF294549)),
                                label: const Text('เพิ่มรายการยา', style: TextStyle(color: Color(0xFF294549))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF294549)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E7F90),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('ดูตารางยาทั้งหมด', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // กล่องล่าง
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
                            children: const [
                              Text(
                                'ตอนเช้า (หลังอาหาร)',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF294549),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'ยา(ชื่อยา) 1 เม็ด',
                                style: TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
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
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('กินยาแล้ว', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E7F90),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              label: const Text('บันทึกอาการ', style: TextStyle(color: Colors.black87)),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black54),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      )


                      ],
                  ),
                ),
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
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
              selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
              icon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
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




// import 'package:flutter/material.dart';
// import 'package:medisync/pages/search_medicine_page.dart';
// import 'package:medisync/pages/history_table_list_page.dart';
// import 'package:medisync/pages/appointment_list_page.dart';
// import 'package:medisync/services/home_service.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final HomeService _homeService = HomeService();
//   late Future<Map<String, dynamic>> _homeDataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   void _loadData() {
//     setState(() {
//       _homeDataFuture = _homeService.fetchHomeSummary();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: FutureBuilder<Map<String, dynamic>>(
//           future: _homeDataFuture,
//           builder: (context, snapshot) {
//             // 1. ระหว่างรอข้อมูลจาก Backend
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             // 2. ถ้าเกิด ข้อผิดพลาด ในการดึงข้อมูล
//             if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: _loadData,
//                       child: const Text('ลองใหม่อีกครั้ง'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             // 3. ดึงข้อมูลสำเร็จ (นำ Data ออกมาใช้งาน)
//             final data = snapshot.data ?? {};
//             final userName = data['user_name'] ?? 'ผู้ใช้งาน';
//             final dateText = data['date_text'] ?? 'ยาวันนี้';
//
//             // ข้อมูลมื้อยา (เช่น {"morning": 1, "afternoon": 1, "evening": 1})
//             final mealCounts = data['meal_counts'] ?? {'morning': 0, 'afternoon': 0, 'evening': 0};
//
//             // ข้อมูลยามื้อถัดไปที่ต้องทาน
//             final nextDose = data['next_dose'] ?? {};
//             final String dosePeriod = nextDose['period'] ?? 'ไม่พบข้อมูล';
//             final String medicineInfo = nextDose['medicine_info'] ?? 'ไม่มีรายการยาที่ต้องกิน';
//             final int? logId = nextDose['log_id'];
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // --- Header ส่วนทักทาย ---
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'สวัสดี !',
//                             style: TextStyle(
//                               fontSize: 40,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF294549),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'คุณ$userName',
//                             style: const TextStyle(
//                               fontSize: 24,
//                               color: Color(0xFF4E7F90),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const CircleAvatar(
//                         radius: 45,
//                         backgroundColor: Color(0xFF294549),
//                         child: Icon(
//                           Icons.person,
//                           size: 55,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//
//                   // --- กล่องสรุปยาวันนี้ ---
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFBBD7DA),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'ยาวันนี้',
//                           style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF294549)),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           dateText,
//                           style: const TextStyle(fontSize: 16, color: Color(0xFF294549)),
//                         ),
//                         const SizedBox(height: 20),
//
//                         // แสดงจำนวนมื้อยาจาก API
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildMealItem('เช้า', '${mealCounts['morning'] ?? 0}'),
//                             _buildMealItem('กลางวัน', '${mealCounts['afternoon'] ?? 0}'),
//                             _buildMealItem('เย็น', '${mealCounts['evening'] ?? 0}'),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed: () {
//                                   // TODO: ไปยังหน้าเพิ่มรายการยา
//                                 },
//                                 icon: const Icon(Icons.add, color: Color(0xFF294549)),
//                                 label: const Text('เพิ่มรายการยา', style: TextStyle(color: Color(0xFF294549))),
//                                 style: OutlinedButton.styleFrom(
//                                   side: const BorderSide(color: Color(0xFF294549)),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF4E7F90),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                                 child: const Text('ดูตารางยาทั้งหมด', style: TextStyle(color: Colors.white)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // --- กล่องแสดงรายการยาที่ต้องกินรอบถัดไป ---
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFBBD7DA),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   dosePeriod,
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF294549),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   medicineInfo,
//                                   style: const TextStyle(fontSize: 15, color: Colors.black54),
//                                 ),
//                               ],
//                             ),
//                             InkWell(
//                               onTap: () {},
//                               child: const CircleAvatar(
//                                 radius: 18,
//                                 backgroundColor: Color(0xFF294549),
//                                 child: Icon(Icons.edit, size: 18, color: Colors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 onPressed: logId == null
//                                     ? null
//                                     : () async {
//                                   bool success = await _homeService.markAsTaken(logId);
//                                   if (success && context.mounted) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('บันทึกการกินยาเรียบร้อยแล้ว!')),
//                                     );
//                                     _loadData(); // รีโหลดหน้าจอเพื่ออัปเดตข้อมูล
//                                   }
//                                 },
//                                 icon: const Icon(Icons.check, color: Colors.white),
//                                 label: const Text('กินยาแล้ว', style: TextStyle(color: Colors.white)),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF4E7F90),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed: () {
//                                   // TODO: บันทึกอาการ
//                                 },
//                                 label: const Text('บันทึกอาการ', style: TextStyle(color: Colors.black87)),
//                                 icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
//                                 style: OutlinedButton.styleFrom(
//                                   side: const BorderSide(color: Colors.black54),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                                   padding: const EdgeInsets.symmetric(vertical: 12),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//
//       // Bottom NavBar
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: 0,
//         backgroundColor: const Color(0xFF294549),
//         indicatorColor: Colors.transparent,
//         onDestinationSelected: (int index) {
//           if (index == 1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SearchMedicinePage()),
//             );
//           } else if (index == 2) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
//             );
//           } else if (index == 3) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AppointmentListPage()),
//             );
//           }
//         },
//         destinations: const <Widget>[
//           NavigationDestination(
//               selectedIcon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
//               icon: Icon(Icons.home_outlined, color: Color(0xFF90C2B7), size: 36),
//               label: ""
//           ),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
//               icon: Icon(Icons.search, color: Color(0xFF4A807E), size: 36),
//               label: ""
//           ),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
//               icon: Icon(Icons.history, color: Color(0xFF4A807E), size: 36),
//               label: ""
//           ),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
//               icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF4A807E), size: 36),
//               label: ""
//           ),
//           NavigationDestination(
//               selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
//               icon: Icon(Icons.person_rounded, color: Color(0xFF4A807E), size: 36),
//               label: ""
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Widget _buildMealItem(String title, String count) {
//   return Column(
//     children: [
//       Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             width: 86,
//             height: 86,
//             decoration: const BoxDecoration(
//               color: Color(0xFFD6D6D6),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.image_outlined, size: 38, color: Colors.black54),
//           ),
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF294549),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Text(
//                 'x$count',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 8),
//       Text(
//         title,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF294549),
//         ),
//       ),
//     ],
//   );
// }
