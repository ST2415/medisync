class MedicineTrack {
  final String dayName;

  int morning;
  int afternoon;
  int evening;
  int beforeSleep;

  String? morningLogId;
  String? afternoonLogId;
  String? eveningLogId;
  String? beforeSleepLogId;

  MedicineTrack({
    required this.dayName,
    this.morning = 0,
    this.afternoon = 0,
    this.evening = 0,
    this.beforeSleep = 0,
    this.morningLogId,
    this.afternoonLogId,
    this.eveningLogId,
    this.beforeSleepLogId,
  });
}