import 'package:flutter/material.dart';

void main() {
  runApp(const YemekKitabiApp());
}

class YemekKitabiApp extends StatelessWidget {
  const YemekKitabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Yemek Kitabi'),
        ),
        body: SizedBox.shrink(),
      ),
    );
  }
}
