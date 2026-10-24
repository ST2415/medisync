import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:8000');
//เดี๋ยวต้องแก้ด้านล่างนี้หลังทำ server เสร็จ
    Future<List<dynamic>> fetchProducts() async {
  final res = await http.get(Uri.parse('$apiBase/products'));
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
  return jsonDecode(res.body) as List;
}

String imageUrl(String path) {
  final clean = path.replaceFirst(RegExp(r'^/+'), '');
  return '$apiBase/static/$clean';
}