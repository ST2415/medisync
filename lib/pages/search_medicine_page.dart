
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/pages/medicine_detail_page.dart';
import 'package:medisync/services/medicine_service.dart';

class SearchMedicinePage extends StatefulWidget {
  const SearchMedicinePage({super.key});

  @override
  State<SearchMedicinePage> createState() =>
      _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {
  final MedicineService _medicineService = MedicineService();

  final TextEditingController _searchController =
  TextEditingController();

  Timer? _debounce;

  List<dynamic> medicineList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ดึงรายการยาจาก API
  Future<void> _fetchMedicines([String query = '']) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results =
      await _medicineService.searchMedicines(query: query);

      if (!mounted) return;

      setState(() {
        medicineList = results;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        medicineList = [];
        isLoading = false;
        errorMessage = 'ไม่สามารถโหลดข้อมูลยาได้\n$e';
      });
    }
  }

  // ค้นหายาขณะพิมพ์
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () {
        _fetchMedicines(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4E7F90),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Text(
                'ค้นหายาของคุณ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // ช่องค้นหายา
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'พิมพ์ชื่อยา หรือ กลุ่มอาการ',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF294549),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // แสดงรายการยา
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _fetchMedicines(
                            _searchController.text,
                          );
                        },
                        child: const Text('ลองอีกครั้ง'),
                      ),
                    ],
                  ),
                )
                    : medicineList.isEmpty
                    ? const Center(
                  child: Text(
                    'ไม่พบรายการยา',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )
                    : ListView.separated(
                  itemCount: medicineList.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item =
                    Map<String, dynamic>.from(
                      medicineList[index] as Map,
                    );

                    return _MedicineCard(
                      itemData: item,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // เมนูด้านล่าง
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,

        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const HistoryTableListPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const AppointmentListPage(),
              ),
            );
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Color(0xFF4A807E),
              size: 36,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search,
              color: Color(0xFF90C2B7),
              size: 36,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history,
              color: Color(0xFF4A807E),
              size: 36,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF4A807E),
              size: 36,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_rounded,
              color: Color(0xFF4A807E),
              size: 36,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const _MedicineCard({
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
    (itemData['trade_name'] ??
        itemData['name'] ??
        'ไม่ระบุชื่อยา')
        .toString();

    final String time =
    (itemData['time_to_take'] ??
        itemData['category'] ??
        'ทานตามแพทย์สั่ง')
        .toString();

    final String quantity =
    (itemData['dosage'] ??
        itemData['quantity'] ??
        'ไม่ระบุขนาด')
        .toString();

    final dynamic imageValue =
        itemData['image_url'] ?? itemData['image'];

    final String? imageUrl = imageValue?.toString();

    return GestureDetector(
      // กดการ์ดเพื่อเปิดหน้ารายละเอียดยา
      onTap: () {
        // อ่านรหัสยาจากข้อมูล API
        final dynamic tpuCode = itemData['tpu_code'];

        if (tpuCode == null ||
            tpuCode.toString().trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ไม่พบรหัสยา tpu_code จากฐานข้อมูล',
              ),
            ),
          );
          return;
        }

        // ส่งรหัสยาไปหน้า MedicineDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailPage(
              tpuCode: tpuCode,
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFBBD7DA),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพยา
            Container(
              width: 110,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageUrl != null &&
                  imageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_outlined,
                      size: 44,
                      color: Color(0xFFDCDCDC),
                    );
                  },
                ),
              )
                  : const Icon(
                Icons.image_outlined,
                size: 44,
                color: Color(0xFFDCDCDC),
              ),
            ),

            const SizedBox(width: 16),

            // รายละเอียดบนการ์ด
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
