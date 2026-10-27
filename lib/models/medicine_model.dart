// class MedicineModel {
//   final int id;
//   final String name;
//   final String dosage;
//
//   MedicineModel({
//     required this.id,
//     required this.name,
//     required this.dosage,
//   });
//
//   // แปลงจาก JSON Map เป็น Object
//   factory MedicineModel.fromJson(Map<String, dynamic> json) {
//     return MedicineModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       dosage: json['dosage'] ?? '',
//     );
//   }
//
//   // (Optional) แปลงจาก Object เป็น JSON สำหรับส่งไป Server (POST/PUT)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'dosage': dosage,
//     };
//   }
// }