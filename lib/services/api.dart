import 'dart:convert';
import 'package:http/http.dart' as http;

//ตัวช่วยแปลงวันที่ วางไว้นอก ApiService
class DateFormatHelper {
  static DateTime parseActionTime(String value) {
    final parts = value.trim().split(' ');
    final dateParts = parts[0].split('/');
    final timeParts = parts[1].split(':');

    return DateTime(
      int.parse(dateParts[2]), // ปี
      int.parse(dateParts[1]), // เดือน
      int.parse(dateParts[0]), // วัน
      int.parse(timeParts[0]), // ชั่วโมง
      int.parse(timeParts[1]), // นาที
    );
  }
}

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
  static Future<List<dynamic>> getAppointments({
    required int userId,
  }) async {
    final response = await _get(
      '/appointments',
      queryParameters: {
        'user_id': userId.toString(),
      },
    );

    if (response is List) {
      return response;
    }

    throw Exception('รูปแบบข้อมูลนัดหมายไม่ถูกต้อง');
  }
  // static Future<List<dynamic>> getAppointments() async {
  //   return List<dynamic>.from(await _get('/appointments'));
  // }
  //
  // static Future<Map<String, dynamic>> getAppointment({
  //   String? appointmentId,
  //   int? userId,
  // }) async {
  //   if (appointmentId == null && userId == null) {
  //     throw ArgumentError('กรุณาระบุ appointmentId หรือ userId');
  //   }
  //
  //   final query = <String, String>{};
  //   if (appointmentId != null) {
  //     query['appointment_id'] = appointmentId;
  //   }
  //   if (userId != null) query['user_id'] = '$userId';
  //
  //   return Map<String, dynamic>.from(
  //     await _get('/appointment', queryParameters: query),
  //   );
  // }

  // เลื่อนวันและเวลานัดหมาย

  static Future<dynamic> _put(
      String path, {
        required Map<String, dynamic> body,
      }) async {
    final response = await http.put(
      Uri.parse('$apiBase$path'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    throw Exception(
      'PUT $path failed: ${response.statusCode} ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> reappointment({
    required String appointmentId,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    final response = await _put(
      '/appointments/$appointmentId/reappointment',
      body: {
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
      },
    );

    return Map<String, dynamic>.from(response);
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

  // GET: ประวัติการกินยาตามช่วงวันที่
  static Future<List<dynamic>> getMedicationLogHistory({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    String formatDate(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    if (startDate.isAfter(endDate)) {
      throw ArgumentError('startDate ต้องไม่เกิน endDate');
    }

    // 1. หาตารางการกินยาของ user ที่ต้องการ
    final schedules = await getSchedules();

    final userScheduleIds = schedules
        .where((s) => s['user_id'].toString() == userId.toString())
        .map((s) => s['schedule_id'].toString())
        .toSet();

    // 2. ดึง logs ทั้งหมด แล้วเลือกเฉพาะ schedule ของ user นี้
    final allLogs = await getMedicationLogs();

    final userLogs = allLogs.where(
          (log) => userScheduleIds.contains(
        log['schedule_id']?.toString(),
      ),
    );

    // 3. เรียก log_history ของแต่ละ log_id
    final results = await Future.wait(
      userLogs.map((log) async {
        final logId = log['log_id']?.toString();

        if (logId == null || logId.isEmpty) {
          return <dynamic>[];
        }

        final result = await _get(
          '/medication_log/$logId/log_history',
          queryParameters: {
            'start_date': formatDate(startDate),
            'end_date': formatDate(endDate),
          },
        );

        return List<dynamic>.from(result);
      }),
    );

    // 4. รวมและเรียงตามวันเวลา
    final history = results.expand((items) => items).toList();

    history.sort((a, b) {
      return DateFormatHelper.parseActionTime(
        a['action_time'].toString(),
      ).compareTo(
        DateFormatHelper.parseActionTime(
          b['action_time'].toString(),
        ),
      );
    });

    return history;
  }

  // DELETE: ลบประวัติการกินยาที่บันทึกผิดพลาด
  static Future<void> deleteMedicationLog(String logId) async {
    final uri = Uri.parse(
      '$apiBase/medication_log/${Uri.encodeComponent(logId)}',
    );

    final response = await http
        .delete(uri)
        .timeout(timeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'ลบข้อมูลไม่สำเร็จ: HTTP ${response.statusCode} '
            '${response.body}',
      );
    }
  }
}
