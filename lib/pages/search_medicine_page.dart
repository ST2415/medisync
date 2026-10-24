import 'package:flutter/material.dart';

class SearchMedicinePage extends StatefulWidget {
  const SearchMedicinePage({super.key});

  @override
  State<SearchMedicinePage> createState() => _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'ค้นหายาของคุณ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ชื่อยา หรือ กลุ่มอาการ',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
      ),
    );
  }
}

