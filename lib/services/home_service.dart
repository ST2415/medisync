import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeService {
  // 💡 เปลี่ยน URL ตาม Server ของคุณ (ถ้าใช้ Desktop รันใช้ localhost ได้ครับ)
  static const String baseUrl = 'http://localhost:8000';

  // ดึงข้อมูลสรุปหน้า Home (ชื่อผู้ใช้, รายการยาประจำวัน ฯลฯ)
  Future<Map<String, dynamic>> fetchHomeSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/home-summary'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(' Failed to load home data');
      }
    } catch (e) {
      throw Exception(' Error connecting to server: $e');
    }
  }

  // API สำหรับกดปุ่ม "กินยาแล้ว"
  Future<bool> markAsTaken(int logId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/medications/log'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'log_id': logId, 'status': 'taken'}),
    );
    return response.statusCode == 200;
  }
}