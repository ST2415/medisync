import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HomeService {
  static const String baseUrl = "http://127.0.0.1:8000";

  // 1. ฟังก์ชันดึงข้อมูล Dashboard หลัก
  Future<Map<String, dynamic>> fetchDashboardData(int userId) async {
    try {
      final userResponse = await http.get(Uri.parse('$baseUrl/user?user_id=$userId'));
      final scheduleResponse = await http.get(Uri.parse('$baseUrl/schedule?user_id=$userId'));

      debugPrint("User Response Status: ${userResponse.statusCode}");
      debugPrint("User Body: ${userResponse.body}");

      if (userResponse.statusCode == 200 && scheduleResponse.statusCode == 200) {
        final rawUserData = jsonDecode(utf8.decode(userResponse.bodyBytes));
        final rawScheduleData = jsonDecode(utf8.decode(scheduleResponse.bodyBytes));

        Map<String, dynamic> userData = {};
        if (rawUserData is List && rawUserData.isNotEmpty) {
          userData = rawUserData.first;
        } else if (rawUserData is Map<String, dynamic>) {
          userData = rawUserData;
        }

        String userName = userData['name'] ??
            userData['user_name'] ??
            userData['username'] ??
            'ไม่ระบุชื่อ';

        // แปลงข้อมูล schedules ให้เป็น List
        List<dynamic> schedules = [];
        if (rawScheduleData is List) {
          schedules = rawScheduleData;
        } else if (rawScheduleData is Map && rawScheduleData.containsKey('data')) {
          schedules = rawScheduleData['data'] as List<dynamic>;
        }

        int mCount = 0;
        int lCount = 0;
        int dCount = 0;
        String firstMedDesc = "ไม่มีรายการยา";
        int firstDosage = 0;
        String firstMedImage = "";

        for (var item in schedules) {
          String time = item['time_to_take'] ?? item['time'] ?? item['meal_time'] ?? '';

          if (time.contains('เช้า')) {
            mCount++;
            if (firstMedDesc == "ไม่มีรายการยา") {
              firstDosage = item['dosage_amount'] ?? item['dosage'] ?? 1;
              firstMedDesc = item['trade_name'] ?? item['medicine_name'] ?? "รหัสยา TPU: ${item['tpu_code']}";
              firstMedImage = item['image_url'] ?? item['image'] ?? "";
            }
          } else if (time.contains('กลางวัน')) {
            lCount++;
          } else if (time.contains('เย็น')) {
            dCount++;
          }
        }

        // ดึงชื่อยาเพิ่มเติมจาก API /medicine ถ้ามี TPU Code
        if (schedules.isNotEmpty && (firstMedDesc.startsWith("รหัสยา TPU") || firstMedDesc == "ไม่มีรายการยา")) {
          var targetItem = schedules.firstWhere((element) => element['tpu_code'] != null, orElse: () => null);
          if (targetItem != null) {
            final medRes = await http.get(
              Uri.parse('$baseUrl/medicine?tpu_code=${targetItem['tpu_code']}'),
            );
            if (medRes.statusCode == 200) {
              final rawMedData = jsonDecode(utf8.decode(medRes.bodyBytes));
              Map<String, dynamic> medData = (rawMedData is List && rawMedData.isNotEmpty)
                  ? rawMedData.first
                  : (rawMedData is Map<String, dynamic> ? rawMedData : {});

              firstMedDesc = medData['trade_name'] ?? medData['name'] ?? firstMedDesc;
              firstMedImage = medData['image_url'] ?? medData['image'] ?? firstMedImage;
            }
          }
        }

        return {
          'userName': userName,
          'morningCount': mCount,
          'lunchCount': lCount,
          'dinnerCount': dCount,
          'currentMedicineName': firstMedDesc,
          'currentDosage': firstDosage,
          'currentMedicineImage': firstMedImage,
        };
      }
    } catch (e) {
      debugPrint("Error in HomeService: $e");
    }
    return {};
  }

  // 2. ฟังก์ชันแยกสำหรับดึงรายการยาวันนี้ตาม path /users/user_id/today-schedules
  Future<List<dynamic>> fetchTodaySchedules(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/today-schedules'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching today schedules: $e");
      return [];
    }
  }

  // บันทึก,อัปเดตสถานะการกินยา
  Future<bool> updateMedicationStatus({
    required int userId,
    required int scheduleId,
    required bool isTaken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medication_logs'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'user_id': userId,
          'schedule_id': scheduleId,
          'status': isTaken ? 'taken' : 'skipped',
          'logged_at': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error updating medication status: $e");
      return false;
    }
  }

  Future<String?> addMedicationLog({
    required int userId,
    required String scheduleId,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medication_logs'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'user_id': userId,
          'schedule_id': scheduleId.toString(),
          'status': status,
          'logged_at': DateTime.now().toIso8601String(),
        }),
      );

      debugPrint("POST Log Response Status: ${response.statusCode}");
      debugPrint("POST Log Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          return data['log_id']?.toString() ?? data['id']?.toString();
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error in addMedicationLog: $e");
      return null;
    }
  }

  // ลบข้อมูลการกินยาตาม log_id (ตรงตามตรรกะในประวัติการกินยา)
  Future<bool> deleteMedicationLog(String logId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/medication_logs/$logId'),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error deleting medication log: $e");
      return false;
    }
  }
}