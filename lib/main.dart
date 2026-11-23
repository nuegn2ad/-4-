import 'package:flutter/material.dart';

import 'app.dart';
import 'data/rental_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱을 껐다 켜도 저장된 물품·예약 데이터가 유지되도록 먼저 불러옵니다.
  await rentalStore.load();

  runApp(const RentalApp());
}