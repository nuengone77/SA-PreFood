import 'package:flutter/material.dart';

import 'screens/auth/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PreFoodApp());
}

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

// Kept as an alias so older imports/tests still compile.
class MyApp extends PreFoodApp {
  const MyApp({super.key});
}
