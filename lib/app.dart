import 'package:flutter/material.dart';

import 'pages/login_page.dart';

class RentalApp extends StatelessWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '대학교 공용물품 대여 서비스',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF039BE5),
        ),
        useMaterial3: true,
      ),
      // 웹처럼 넓은 화면에서도 앱이 폰 너비로 가운데에 표시되도록 제한합니다.
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFE9F3F9),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: child,
            ),
          ),
        );
      },
      home: const LoginPage(),
    );
  }
}