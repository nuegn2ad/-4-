import 'package:flutter/material.dart';

import 'pages/login_page.dart';

class RentalApp extends StatelessWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '학교 물품 대여 시스템',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3157D5),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
