class Appointment {
  final String appid;
  final String dateStr;
  final String timeStr;
  String status;

  Appointment({
    required this.appid,
    required this.dateStr,
    required this.timeStr,
    required this.status,
  });
}