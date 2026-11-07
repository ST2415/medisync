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
  bool _showFilters = false;
  final MedicineService _medicineService = MedicineService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<dynamic> allFetchedMedicines = [];
  List<dynamic> filteredMedicineList = [];
  bool isLoading = true;
  String? errorMessage;

  // รายการตัวเลือกในแต่ละ Dropdown ที่สกัดมาจากฐานข้อมูล
  List<String> dosageFormOptions = [];
  List<String> indicationOptions = [];
  List<String> sideEffectOptions = [];
  List<String> precautionOptions = [];

  // ค่าที่ผู้ใช้เลือกใน Dropdown แต่ละตัว (null คือเลือก 'ทั้งหมด')
  String? selectedDosageForm;
  String? selectedIndication;
  String? selectedSideEffect;
  String? selectedPrecaution;

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

  // ดึงรายการยาทั้งหมดจาก API / Database
  Future<void> _fetchMedicines([String query = '']) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await _medicineService.searchMedicines(query: query);

      if (!mounted) return;

      setState(() {
        allFetchedMedicines = results;
        _extractDropdownOptions(); // ดึงรายการตัวเลือกที่ไม่ซ้ำจากข้อมูลยา
        _applyClientFilter();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        allFetchedMedicines = [];
        filteredMedicineList = [];
        isLoading = false;
        errorMessage = 'ไม่สามารถโหลดข้อมูลยาได้\n$e';
      });
    }
  }

  // ดึงค่าที่ไม่ซ้ำจากคอลัมน์ใน DB มาใส่ใน Dropdown ทั้ง 4 เมนู
  void _extractDropdownOptions() {
    final Set<String> forms = {};
    final Set<String> indications = {};
    final Set<String> sideEffects = {};
    final Set<String> precautions = {};

    for (var item in allFetchedMedicines) {
      final map = Map<String, dynamic>.from(item as Map);

      final f = map['dosageform']?.toString().trim();
      if (f != null && f.isNotEmpty && f != 'null') forms.add(f);

      final ind = map['indications']?.toString().trim();
      if (ind != null && ind.isNotEmpty && ind != 'null') indications.add(ind);

      final se = map['side_effects']?.toString().trim();
      if (se != null && se.isNotEmpty && se != 'null') sideEffects.add(se);

      final pre = map['precautions']?.toString().trim();
      if (pre != null && pre.isNotEmpty && pre != 'null') precautions.add(pre);
    }

    dosageFormOptions = forms.toList()..sort();
    indicationOptions = indications.toList()..sort();
    sideEffectOptions = sideEffects.toList()..sort();
    precautionOptions = precautions.toList()..sort();
  }

  // กรองรายการยาตามค่าที่เลือกใน Dropdown ทั้ง 4 ตัว และช่องค้นหาชื่อ
  void _applyClientFilter() {
    final queryText = _searchController.text.trim().toLowerCase();

    setState(() {
      filteredMedicineList = allFetchedMedicines.where((item) {
        final map = Map<String, dynamic>.from(item as Map);

        final tradeName = (map['trade_name'] ?? map['name'] ?? '').toString().toLowerCase();
        final activeIngredient = (map['active_ingredient'] ?? '').toString().toLowerCase();
        final dosageForm = (map['dosageform'] ?? '').toString();
        final indications = (map['indications'] ?? '').toString();
        final sideEffects = (map['side_effects'] ?? '').toString();
        final precautions = (map['precautions'] ?? '').toString();

        // 1. เงื่อนไขช่องค้นหาชื่อยา/ตัวยาสำคัญ
        final matchSearch = queryText.isEmpty ||
            tradeName.contains(queryText) ||
            activeIngredient.contains(queryText);

        // 2. เงื่อนไข Dropdown 1: รูปแบบยา
        final matchForm = selectedDosageForm == null || dosageForm == selectedDosageForm;

        // 3. เงื่อนไข Dropdown 2: สรรพคุณ
        final matchIndication = selectedIndication == null || indications == selectedIndication;

        // 4. เงื่อนไข Dropdown 3: ผลข้างเคียง
        final matchSideEffect = selectedSideEffect == null || sideEffects == selectedSideEffect;

        // 5. เงื่อนไข Dropdown 4: ข้อควรระวัง
        final matchPrecaution = selectedPrecaution == null || precautions == selectedPrecaution;

        return matchSearch && matchForm && matchIndication && matchSideEffect && matchPrecaution;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyClientFilter();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      selectedDosageForm = null;
      selectedIndication = null;
      selectedSideEffect = null;
      selectedPrecaution = null;
      _applyClientFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bool hasActiveFilter = selectedDosageForm != null ||
        selectedIndication != null ||
        selectedSideEffect != null ||
        selectedPrecaution != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: Column(
        children: [
          // Header Banner
          Container(
            padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ค้นหายาของคุณ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (hasActiveFilter)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF90C2B7), size: 16),
                        label: const Text(
                          'ล้างตัวกรอง',
                          style: TextStyle(color: Color(0xFF90C2B7), fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ช่องค้นหาชื่อยา
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      color: Color(0xFF294549),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ชื่อยา หรือ ตัวยาสำคัญ...',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF294549)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.black38, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyClientFilter();
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

              ],
            ),
          ),

          // Filter Panel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE4ECEC),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list_rounded,
                          color: Color(0xFF294549),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'ตัวกรองยา',
                          style: TextStyle(
                            color: Color(0xFF294549),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (hasActiveFilter)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBBD7DA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'กำลังกรอง',
                              style: TextStyle(
                                color: Color(0xFF294549),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const Spacer(),

                        if (hasActiveFilter)
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text(
                              'ล้าง',
                              style: TextStyle(
                                color: Color(0xFF4E7F90),
                                fontSize: 12,
                              ),
                            ),
                          ),

                        Icon(
                          _showFilters
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF294549),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showFilters) ...[
                  const Divider(height: 1, color: Color(0xFFE4ECEC)),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterDropdown(
                                label: 'รูปแบบยา',
                                currentValue: selectedDosageForm,
                                items: dosageFormOptions,
                                onChanged: (val) {
                                  setState(() {
                                    selectedDosageForm = val;
                                    _applyClientFilter();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFilterDropdown(
                                label: 'สรรพคุณ / การรักษา',
                                currentValue: selectedIndication,
                                items: indicationOptions,
                                onChanged: (val) {
                                  setState(() {
                                    selectedIndication = val;
                                    _applyClientFilter();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterDropdown(
                                label: 'ผลข้างเคียง',
                                currentValue: selectedSideEffect,
                                items: sideEffectOptions,
                                onChanged: (val) {
                                  setState(() {
                                    selectedSideEffect = val;
                                    _applyClientFilter();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFilterDropdown(
                                label: 'ข้อควรระวัง',
                                currentValue: selectedPrecaution,
                                items: precautionOptions,
                                onChanged: (val) {
                                  setState(() {
                                    selectedPrecaution = val;
                                    _applyClientFilter();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // แสดงผลรายการยา
          Expanded(
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
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF294549), fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _fetchMedicines(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294549),
                      ),
                      child: const Text('ลองอีกครั้ง', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
                : filteredMedicineList.isEmpty
                ? const Center(
              child: Text(
                'ไม่พบรายการยาที่ตรงกับเงื่อนไข',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMedicineList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(
                  filteredMedicineList[index] as Map,
                );
                return _MedicineCard(itemData: item);
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
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
                  MaterialPageRoute(builder: (context) => const HistoryTableListPage()),
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
                  MaterialPageRoute(builder: (context) => const AppointmentListPage()),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white60,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ตัวช่วยสร้าง Dropdown แต่ละอัน
  Widget _buildFilterDropdown({
    required String label,
    required String? currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentValue != null
              ? const Color(0xFF4E7F90)
              : const Color(0xFFE0E8E8),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          isDense: true,
          menuMaxHeight: 350,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Colors.white,
          hint: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4E7F90),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF4E7F90),
            size: 22,
          ),
          selectedItemBuilder: (context) {
            return [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ทั้งหมด',
                  style: const TextStyle(
                    color: Color(0xFF294549),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...items.map(
                    (val) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    val,
                    style: const TextStyle(
                      color: Color(0xFF294549),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ];
          },
          onChanged: onChanged,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'ทั้งหมด',
                style: TextStyle(
                  color: Color(0xFF294549),
                  fontSize: 13,
                ),
              ),
            ),
            ...items.map(
                  (val) => DropdownMenuItem<String>(
                value: val,
                child: Text(
                  val,
                  style: const TextStyle(
                    color: Color(0xFF294549),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
    final String name = (itemData['trade_name'] ?? itemData['name'] ?? 'ไม่ระบุชื่อยา').toString();

    final String rawForm = (itemData['dosageform'] ?? itemData['instructions'] ?? itemData['category'] ?? '').toString();
    final String formText = rawForm.isNotEmpty ? rawForm : 'ยาตามแพทย์สั่ง';

    final String rawStrength = (itemData['strength'] ?? itemData['size'] ?? itemData['dosage'] ?? '').toString().trim();
    final String strengthText = rawStrength.isNotEmpty
        ? (rawStrength.startsWith('ขนาด') || rawStrength.contains('mg') ? rawStrength : 'ขนาด : $rawStrength')
        : 'ไม่ระบุขนาด';

    final dynamic imageValue = itemData['image_url'] ?? itemData['image'];
    final String? imageUrl = imageValue?.toString();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
          padding: const EdgeInsets.all(14),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // รูปภาพยา
              Container(
                width: 75,
                height: 75,
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
                      size: 34,
                      color: Color(0xFF90C2B7),
                    );
                  },
                )
                    : const Icon(
                  Icons.medication_rounded,
                  size: 34,
                  color: Color(0xFF90C2B7),
                ),
              ),

              const SizedBox(width: 12),

              // รายละเอียดตัวยา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF294549),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // แท็กรูปแบบยา
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        formText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF294549),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ขนาดความแรงของยา
                    Text(
                      strengthText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4E7F90),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ลูกศรชี้ขวามือ จัดกึ่งกลางแนวตั้งด้านขวาสุดของการ์ด
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0x29294549),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF294549),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}