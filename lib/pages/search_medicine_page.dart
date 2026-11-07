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
  State<SearchMedicinePage> createState() => _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {
  final MedicineService _medicineService = MedicineService();
  final TextEditingController _searchController = TextEditingController();

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
      final results = await _medicineService.searchMedicines(query: query);

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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: Column(
        children: [
          // Header Banner
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
                const Row(
                  children: [
                    Text(
                      'ค้นหายาของคุณ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ช่องค้นหายา (Search TextField)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      color: Color(0xFF294549),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'พิมพ์ชื่อยา หรือ กลุ่มอาการ',
                      hintStyle:
                          TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF294549),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // รายการแสดงผลยา
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF294549),
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF294549),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  _fetchMedicines(_searchController.text);
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
                      )
                    : medicineList.isEmpty
                        ? const Center(
                            child: Text(
                              'ไม่พบรายการยาที่ค้นหา',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: medicineList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = Map<String, dynamic>.from(
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
              isSelected: true,
              onTap: () {},
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
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppointmentListPage()),
                );
              },
            ),
            // Floating menu button ด้านขวา
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

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const _MedicineCard({
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final String name = (itemData['trade_name'] ??
            itemData['name'] ??
            'ไม่ระบุชื่อยา')
        .toString();

    final String rawTime = (itemData['instructions'] ??
            itemData['time_to_take'] ??
            itemData['usage_time'] ??
            itemData['meal_time'] ??
            itemData['category'] ??
            '')
        .toString();
    final String time = rawTime.isNotEmpty ? rawTime : 'ทานตามแพทย์สั่ง';

    final String rawQuantity = (itemData['size'] ??
            itemData['dosage'] ??
            itemData['dose'] ??
            itemData['strength'] ??
            itemData['dose_amount'] ??
            itemData['amount'] ??
            itemData['tablet_count'] ??
            itemData['quantity'] ??
            '')
        .toString()
        .trim();

    final String quantity = rawQuantity.isNotEmpty
        ? (rawQuantity.startsWith('ขนาด') || rawQuantity.contains('เม็ด')
            ? rawQuantity
            : 'ขนาด : $rawQuantity')
        : 'ไม่ระบุขนาด';

    final dynamic imageValue = itemData['image_url'] ?? itemData['image'];
    final String? imageUrl = imageValue?.toString();

    return GestureDetector(
      onTap: () {
        final dynamic tpuCode = itemData['tpu_code'];

        if (tpuCode == null || tpuCode.toString().trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบรหัสยา tpu_code จากฐานข้อมูล'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

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
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพยา
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF294549),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
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
                          size: 40,
                          color: Color(0xFF90C2B7),
                        );
                      },
                    )
                  : const Icon(
                      Icons.medication_rounded,
                      size: 40,
                      color: Color(0xFF90C2B7),
                    ),
            ),

            const SizedBox(width: 14),

            // รายละเอียดบนการ์ด
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // แท็กเวลาทานยา
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF294549),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ข้อความปริมาณการทานยา
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4E7F90),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF294549),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
