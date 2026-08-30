import 'package:flutter/material.dart';

import 'screens/auth/splash_screen.dart';
import 'theme/app_theme.dart';

/// จุดเริ่มต้นของแอป เรียกใช้ widget ราก [PreFoodApp]
void main() {
  runApp(const PreFoodApp());
}

/// กำหนดค่าระดับแอป เช่น ชื่อ ธีม และหน้าจอแรกที่จะแสดง
class PreFoodApp extends StatelessWidget {
  const PreFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PreFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

/// ชื่อเดิมของ widget ราก เก็บไว้เพื่อให้ test หรือโค้ดเก่ายัง import ได้
class MyApp extends PreFoodApp {
  const MyApp({super.key});
}
