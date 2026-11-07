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
  bool isSubmitting = false;

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
      final result = await _medicineService.getMedicine(widget.tpuCode);

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

  // ฟังก์ชันแสดง Bottom Sheet สำหรับเลือกรายละเอียดการทานยา
  void _showAddScheduleBottomSheet() {
    String selectedMealTime = 'ตอนเช้า';
    String selectedMealRelation = 'หลังอาหาร';
    int dosage = 1;
    String customTime = '08:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ขีดจับด้านบน
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1. หัวข้อและชื่อยา (ป้องกันข้อความยาวเบียดไอคอน)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.alarm_add_rounded,
                          color: Color(0xFF294549),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ตั้งเวลาเตือนยา',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              getValue(medicineData!, 'trade_name'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF294549),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. เลือกช่วงเวลารับประทาน (จัด Grid 4 ช่องเท่ากัน ไม่ตกแถวเดี่ยว)
                  const Text(
                    'ช่วงเวลารับประทาน',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['ตอนเช้า', 'ตอนกลางวัน', 'ตอนเย็น', 'ก่อนนอน'].map((period) {
                      final isSelected = selectedMealTime == period;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedMealTime = period;
                                if (period == 'ตอนเช้า') customTime = '08:00';
                                if (period == 'ตอนกลางวัน') customTime = '12:00';
                                if (period == 'ตอนเย็น') customTime = '18:00';
                                if (period == 'ก่อนนอน') customTime = '21:00';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF294549) : const Color(0xFFF7F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF294549) : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSelected) ...[
                                    // ไอคอนติ๊กถูกสีมิ้นต์สว่าง
                                    const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    period,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF294549),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 3. เงื่อนไขมื้ออาหาร (ก่อน / หลัง / พร้อมอาหาร)
                  const Text(
                    'เงื่อนไขมื้ออาหาร',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF294549),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['ก่อนอาหาร', 'หลังอาหาร', 'พร้อมอาหาร'].map((rel) {
                      final isSelected = selectedMealRelation == rel;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedMealRelation = rel;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF294549) : const Color(0xFFF7F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF294549) : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSelected) ...[
                                    // ไอคอนติ๊กถูกสีเขียวเข้มเข้าธีม
                                    const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    rel,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF294549),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 4. จำนวนที่รับประทาน (เม็ด/ครั้ง) พร้อมกล่องควมคุมระยะห่าง
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'จำนวนที่รับประทาน',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF294549),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: dosage > 1
                                  ? () => setModalState(() => dosage--)
                                  : null,
                              icon: Icon(
                                Icons.remove_circle_outline_rounded,
                                color: dosage > 1 ? const Color(0xFF294549) : Colors.black26,
                                size: 24,
                              ),
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 32),
                              alignment: Alignment.center,
                              child: Text(
                                '$dosage',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF294549),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setModalState(() => dosage++),
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Color(0xFF294549),
                                size: 24,
                              ),
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'เม็ด',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. ปุ่มยืนยันการเพิ่มตารางยา
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294549),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        Navigator.pop(modalContext);
                        await _submitSchedule(
                          timeToTakeStr: '$customTime • $selectedMealTime ($selectedMealRelation)',
                          amount: dosage,
                        );
                      },
                      child: isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'ยืนยันการเพิ่มตารางยา',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ส่งข้อมูลเข้าเซิร์ฟเวอร์
  Future<void> _submitSchedule({
    required String timeToTakeStr,
    required int amount,
  }) async {
    setState(() => isSubmitting = true);

    try {
      final success = await _medicineService.addMedicineToSchedule(
        userId: 16, // User ID เป้าหมาย
        tpuCode: widget.tpuCode,
        timeToTake: timeToTakeStr,
        dosageAmount: amount,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มยา ${getValue(medicineData!, 'trade_name')} ลงในตารางยาเรียบร้อยแล้ว'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF294549),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
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
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF294549)),
        )
            : errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: Color(0xFF294549)),
                const SizedBox(height: 12),
                Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF294549), fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF294549),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('ลองอีกครั้ง', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        )
            : buildMedicineDetails(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF294549),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            _buildNavItem(
              icon: Icons.medication_rounded,
              label: 'ยา',
              isSelected: true,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SearchMedicinePage()));
              },
            ),
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'ประวัติ',
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryTableListPage()));
              },
            ),
            _buildNavItem(
              icon: Icons.notifications_rounded,
              label: 'นัดหมาย',
              isSelected: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppointmentListPage()));
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Icon(Icons.person_rounded, color: Colors.white60, size: 24),
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
    final timeToTake = getValue(data, 'time_to_take', 'category', 'ทานตามแพทย์สั่ง');
    final dosage = getValue(data, 'strength');
    final form = getValue(data, 'dosageform');
    final sideEffects = getValue(data, 'side_effects');
    final precautions = getValue(data, 'precautions');
    final activeIngredient = getValue(data, 'active_ingredient');
    final imageUrl = data['image_url'] ?? data['image'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFF294549),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? Image.network(
                    imageUrl.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.medication_rounded,
                      size: 64,
                      color: Color(0xFF90C2B7),
                    ),
                  )
                      : const Icon(
                    Icons.medication_rounded,
                    size: 64,
                    color: Color(0xFF90C2B7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF294549)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTagChip(icon: Icons.medication_liquid_rounded, text: form),
                    _buildTagChip(icon: Icons.scale_rounded, text: dosage),
                    _buildTagChip(icon: Icons.access_time_filled_rounded, text: timeToTake),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. หมวดสรรพคุณ
          _buildSectionCard(
            icon: Icons.healing_rounded,
            title: 'สรรพคุณ / ข้อบ่งใช้',
            accentColor: const Color(0xFF294549),
            child: Text(
              treatment,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 14),

          // 3. หมวดตัวยาสำคัญ
          _buildSectionCard(
            icon: Icons.biotech_rounded,
            title: 'ตัวยาสำคัญ (Active Ingredient)',
            accentColor: const Color(0xFF4E7F90),
            child: Text(
              activeIngredient,
              style: const TextStyle(fontSize: 14, color: Color(0xFF294549), fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 14),

          // 4. หมวดข้อควรระวังและผลข้างเคียง
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD4D0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD9534F), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'ข้อควรระวัง & ผลข้างเคียง',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD9534F)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSafetyItem(label: 'ข้อควรระวัง', desc: precautions),
                const Divider(height: 18, color: Color(0xFFFFE3E1)),
                _buildSafetyItem(label: 'ผลข้างเคียง', desc: sideEffects),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. ปุ่มเพิ่มรายการยา -> เรียก Bottom Sheet
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : _showAddScheduleBottomSheet,
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: const Text(
                'เพิ่มลงตารางยาของฉัน',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294549),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF294549)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF294549)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildSafetyItem({required String label, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8E6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD9534F)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),
        ),
      ],
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
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}