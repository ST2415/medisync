import 'dart:convert';
import 'package:http/http.dart' as http;

// เปลี่ยน URL ให้ตรงกับแพลตฟอร์มที่ใช้รัน Flutter
const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://127.0.0.1:8000',
);

class ApiService {
  static const Duration timeout = Duration(seconds: 15);

  // ฟังก์ชันกลางสำหรับ GET และแปลง JSON
  static Future<dynamic> _get(
      String path, {
        Map<String, String>? queryParameters,
      }) async {
    final uri = Uri.parse('$apiBase$path').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(uri).timeout(timeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // ตรวจสอบว่า API ทำงานอยู่หรือไม่
  static Future<Map<String, dynamic>> getHome() async {
    return Map<String, dynamic>.from(await _get('/'));
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    return Map<String, dynamic>.from(await _get('/health'));
  }

  // USERS
  static Future<List<dynamic>> getUsers() async {
    return List<dynamic>.from(await _get('/users'));
  }

  static Future<Map<String, dynamic>> getUser({
    int? userId,
    String? name,
  }) async {
    if (userId == null && name == null) {
      throw ArgumentError('กรุณาระบุ userId หรือ name');
    }

    final query = <String, String>{};
    if (userId != null) query['user_id'] = '$userId';
    if (name != null) query['name'] = name;

    return Map<String, dynamic>.from(
      await _get('/user', queryParameters: query),
    );
  }

  // SCHEDULES
  static Future<List<dynamic>> getSchedules() async {
    return List<dynamic>.from(await _get('/schedules'));
  }

  static Future<Map<String, dynamic>> getSchedule({
    String? scheduleId,
    int? userId,
  }) async {
    if (scheduleId == null && userId == null) {
      throw ArgumentError('กรุณาระบุ scheduleId หรือ userId');
    }

    final query = <String, String>{};
    if (scheduleId != null) query['schedule_id'] = scheduleId;
    if (userId != null) query['user_id'] = '$userId';

    return Map<String, dynamic>.from(
      await _get('/schedule', queryParameters: query),
    );
  }

  // MEDICINES
  static Future<List<dynamic>> getMedicines() async {
    return List<dynamic>.from(await _get('/medicines'));
  }

  static Future<Map<String, dynamic>> getMedicine({
    int? tpuCode,
    String? tradeName,
  }) async {
    if (tpuCode == null && tradeName == null) {
      throw ArgumentError('กรุณาระบุ tpuCode หรือ tradeName');
    }

    final query = <String, String>{};
    if (tpuCode != null) query['tpu_code'] = '$tpuCode';
    if (tradeName != null) query['trade_name'] = tradeName;

    return Map<String, dynamic>.from(
      await _get('/medicine', queryParameters: query),
    );
  }

  // APPOINTMENTS
  static Future<List<dynamic>> getAppointments() async {
    return List<dynamic>.from(await _get('/appointments'));
  }

  static Future<Map<String, dynamic>> getAppointment({
    String? appointmentId,
    int? userId,
  }) async {
    if (appointmentId == null && userId == null) {
      throw ArgumentError('กรุณาระบุ appointmentId หรือ userId');
    }

    final query = <String, String>{};
    if (appointmentId != null) {
      query['appointment_id'] = appointmentId;
    }
    if (userId != null) query['user_id'] = '$userId';

    return Map<String, dynamic>.from(
      await _get('/appointment', queryParameters: query),
    );
  }

  // MEDICATION LOGS
  static Future<List<dynamic>> getMedicationLogs() async {
    return List<dynamic>.from(await _get('/medication_logs'));
  }

  static Future<dynamic> getMedicationLog({
    String? logId,
    String? scheduleId,
  }) async {
    if (logId == null && scheduleId == null) {
      throw ArgumentError('กรุณาระบุ logId หรือ scheduleId');
    }

    final query = <String, String>{};
    if (logId != null) query['log_id'] = logId;
    if (scheduleId != null) query['schedule_id'] = scheduleId;

    return _get('/medication_log', queryParameters: query);
  }
}
