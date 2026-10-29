import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ดึงรายการยาทั้งหมด แล้วกรองตามคำค้นหา
  Future<List<Map<String, dynamic>>> searchMedicines({
    String query = '',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medicines'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'โหลดรายการยาไม่สำเร็จ: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    // รองรับ API ที่ส่ง List โดยตรง
    dynamic rawList = decoded;

    if (decoded is Map<String, dynamic>) {
      rawList = decoded['medicines'] ?? decoded['data'];
    }

    if (rawList is! List) {
      throw Exception('รูปแบบรายการยาจาก API ไม่ถูกต้อง');
    }

    final medicines = rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      return medicines;
    }

    // กรองชื่อยาและข้อมูลที่เกี่ยวข้อง
    return medicines.where((medicine) {
      final tradeName =
      (medicine['trade_name'] ?? '').toString().toLowerCase();

      final ingredient =
      (medicine['active_ingredient'] ?? '').toString().toLowerCase();

      final indications =
      (medicine['indications'] ?? '').toString().toLowerCase();

      return tradeName.contains(keyword) ||
          ingredient.contains(keyword) ||
          indications.contains(keyword);
    }).toList();
  }

  // ดึงรายละเอียดของยาจากรหัส TPU
  Future<Map<String, dynamic>> getMedicine(
      dynamic tpuCode,
      ) async {
    final uri = Uri.parse('$baseUrl/medicine').replace(
      queryParameters: {
        'tpu_code': tpuCode.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'โหลดรายละเอียดยาไม่สำเร็จ: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    // รองรับข้อมูลยา 1 รายการที่ส่งเป็น Map
    if (decoded is Map<String, dynamic>) {
      if (decoded['medicine'] is Map) {
        return Map<String, dynamic>.from(
          decoded['medicine'] as Map,
        );
      }

      if (decoded['medicines'] is List) {
        final list = decoded['medicines'] as List;

        if (list.isNotEmpty && list.first is Map) {
          return Map<String, dynamic>.from(list.first as Map);
        }
      }

      return decoded;
    }

    // รองรับ API ที่ส่งรายการยาเป็น List
    if (decoded is List && decoded.isNotEmpty) {
      if (decoded.first is Map) {
        return Map<String, dynamic>.from(decoded.first as Map);
      }
    }

    throw Exception('ไม่พบข้อมูลยาที่ต้องการ');
  }
}
