import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'screens/home_screen.dart';

void main() {
  // Sistem bilesenlerinin baslatilmasi (Flutter motoru ile iletisim icin gerekli olabilir)
  WidgetsFlutterBinding.ensureInitialized();

  // Windows ve Linux masaustu ortamlari icin SQLite FFI baslatmasi
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit(); // Sadece main'de cagrilir
    databaseFactory = databaseFactoryFfi; // Global atama yapilir
  }

  runApp(const YemekKitabiApp());
}

class YemekKitabiApp extends StatelessWidget {
  const YemekKitabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yemek Kitabı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}