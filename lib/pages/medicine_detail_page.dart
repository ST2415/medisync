import 'package:flutter/material.dart';
import 'package:medisync/pages/homepage_page.dart';
import 'package:medisync/pages/history_table_list_page.dart';
import 'package:medisync/pages/search_medicine_page.dart';
import 'package:medisync/pages/appointment_list_page.dart';
import 'package:medisync/services/medicine_service.dart';

class MedicineDetailPage extends StatefulWidget {
  final dynamic tpuCode;

  const MedicineDetailPage({
    super.key,
    required this.tpuCode,
  });

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineService _medicineService = MedicineService();

  Map<String, dynamic>? medicineData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMedicine();
  }

  Future<void> fetchMedicine() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _medicineService.getMedicine(
        widget.tpuCode,
      );

      if (!mounted) return;

      setState(() {
        medicineData = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String getValue(
    Map<String, dynamic> data,
    String key1, [
    String? key2,
    String fallback = 'ไม่ระบุ',
  ]) {
    final value = data[key1] ?? (key2 == null ? null : data[key2]);

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF294549),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'รายละเอียดยา',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
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
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 60,
                            color: Color(0xFF294549),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF294549),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchMedicine,
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
                : buildMedicineDetails(),
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

  Widget buildMedicineDetails() {
    final data = medicineData!;

    final name = getValue(data, 'trade_name');
    final treatment = getValue(data, 'indications');
    final timeToTake =
        getValue(data, 'time_to_take', 'category', 'ทานตามแพทย์สั่ง');
    final dosage = getValue(data, 'strength');
    final form = getValue(data, 'dosageform');
    final sideEffects = getValue(data, 'side_effects');
    final precautions = getValue(data, 'precautions');
    final activeIngredient = getValue(data, 'active_ingredient');

    final imageUrl = data['image_url'] ?? data['image'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFBBD7DA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพยาแบบกรอบโค้งมนสไตล์เดียวกับ homepage_page.dart
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF294549),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.toString().isNotEmpty
                  ? Image.network(
                      imageUrl.toString(),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF90C2B7),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.medication_rounded,
                          size: 70,
                          color: Color(0xFF90C2B7),
                        );
                      },
                    )
                  : const Icon(
                      Icons.medication_rounded,
                      size: 70,
                      color: Color(0xFF90C2B7),
                    ),
            ),
            const SizedBox(height: 20),

            // ชื่อยา
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF294549),
              ),
            ),
            const SizedBox(height: 16),

            // รายละเอียดของยา
            buildDetailRow('รักษา', treatment),
            buildDetailRow('รับประทานตอน', timeToTake),
            buildDetailRow('ขนาด', dosage),
            buildDetailRow('รูปแบบทางเภสัชกรรม', form),
            buildDetailRow('ผลข้างเคียง', sideEffects),
            buildDetailRow('ข้อควรระวัง', precautions),
            buildDetailRow('ตัวยาสำคัญ', activeIngredient),

            const SizedBox(height: 24),

            // ปุ่มเพิ่มรายการยา
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เพิ่มยา $name เรียบร้อยแล้ว'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'เพิ่มรายการยา',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF294549),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x99FFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: '$label : ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF294549),
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
