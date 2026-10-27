class MedicineTrack {
  final String dayName;
  int morning;
  int afternoon;
  int evening;
  int beforeSleep;

  MedicineTrack({
    required this.dayName,
    this.morning = 0,
    this.afternoon = 0,
    this.evening = 0,
    this.beforeSleep = 0,
  });
}