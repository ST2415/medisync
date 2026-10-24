import 'pages/homepage_page.dart';
import 'package:flutter/material.dart';
import 'package:medisync/main.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediSync',
      theme: ThemeData(
        fontFamily: 'Kanit',
      ),
      home: HomePage(),
    );
  }
}
