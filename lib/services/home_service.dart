import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HomeService {

  static const String baseUrl = "http://127.0.0.1:8000";

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

        // Schedules
        List<dynamic> schedules = [];
        if (rawScheduleData is List) {
          schedules = rawScheduleData;
        } else if (rawScheduleData is Map<String, dynamic>) {
          // กรณี backend ส่งมาเป็น { "data": [...] } หรือ { "schedules": [...] }
          schedules = rawScheduleData['data'] ??
              rawScheduleData['schedules'] ??
              rawScheduleData['schedule'] ??
              rawScheduleData['results'] ?? [];
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
              firstMedDesc = item['medicine_name'] ?? "รหัสยา TPU: ${item['tpu_code']}";
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
}