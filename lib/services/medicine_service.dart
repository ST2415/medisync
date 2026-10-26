import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart';

class MedicineService {
  // ⚠️ ข้อควรระวังเรื่อง IP Address:
  // - ถ้าทดสอบบน Chrome/Mac Desktop ใช้: 'http://localhost:8000'
  // - ถ้าทดสอบบน Android Emulator ใช้: 'http://10.0.2.2:8000'
  // - ถ้าทดสอบบนเครื่องจริง (Mobile) ใช้: IP เครื่องคอมฯ ของคุณ เช่น 'http://192.168.1.X:8000'
  static const String baseUrl = 'http://localhost:8000';

  // ตัวอย่าง GET Request: ดึงรายการยา
  Future<List<MedicineModel>> fetchMedicines() async {
    final response = await http.get(Uri.parse('$baseUrl/medicines'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => MedicineModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load medicines: ${response.statusCode}');
    }
  }

  // ตัวอย่าง POST Request: เพิ่มยาใหม่
  Future<bool> addMedicine(String name, String dosage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/medicines'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'dosage': dosage,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}