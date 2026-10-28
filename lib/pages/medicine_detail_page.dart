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
  State<MedicineDetailPage> createState() =>
      _MedicineDetailPageState();
}

class _MedicineDetailPageState
    extends State<MedicineDetailPage> {
  final MedicineService _medicineService = MedicineService();

  static const String baseUrl = 'http://127.0.0.1:8000';

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
      backgroundColor: const Color(0xFF4A807E),

      appBar: AppBar(
        backgroundColor: const Color(0xFF294549),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
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
                  Icons.error_outline,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchMedicine,
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        )
            : buildMedicineDetails(),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: const Color(0xFF294549),
        indicatorColor: Colors.transparent,

        onDestinationSelected: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchMedicinePage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryTableListPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppointmentListPage(),
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
              color: Color(0xFF4A807E),
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

  Widget buildMedicineDetails() {
    final data = medicineData!;

    final name = getValue(data, 'trade_name', 'name',
        'ไม่ระบุชื่อยา');
    final treatment = getValue(
        data, 'indication', 'treatment');
    final timeToTake = getValue(
        data, 'time_to_take', 'category', 'ทานตามแพทย์สั่ง');
    final dosage = getValue(data, 'dosage', 'quantity', '1 เม็ด');
    final form = getValue(
        data, 'pharmaceutical_form', 'form');
    final sideEffects = getValue(data, 'side_effects', null);
    final precautions = getValue(data, 'precautions', null);
    final activeIngredient = getValue(
        data, 'active_ingredient', 'generic_name');

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
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imageUrl != null &&
                  imageUrl.toString().isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_outlined,
                      size: 80,
                      color: Color(0xFFDCDCDC),
                    );
                  },
                ),
              )
                  : const Icon(
                Icons.image_outlined,
                size: 80,
                color: Color(0xFFDCDCDC),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF294549),
              ),
            ),

            const SizedBox(height: 16),

            buildDetailRow('รักษา', treatment),
            buildDetailRow('รับประทานตอน', timeToTake),
            buildDetailRow('ขนาด', dosage),
            buildDetailRow('รูปแบบทางเภสัชกรรม', form),
            buildDetailRow('ผลข้างเคียง', sideEffects),
            buildDetailRow('ข้อควรระวัง', precautions),
            buildDetailRow('ตัวยาสำคัญ', activeIngredient),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
